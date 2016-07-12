#!/bin/bash

# cd into the script's folder; on Mac OS: readlink doesn't have the -f option
# by default, but package coreutils contains a greadlink command that does
is_mac_os=0
if [[ "${OSTYPE}" == "darwin"* ]]; then
  cd "$(dirname "$(greadlink -f "$0")")"
  is_mac_os=1
else
  cd "$(dirname "$(readlink -f "$0")")"
fi

is_root=0

if [[ "$(id -u)" == "0" ]]; then
    is_root=1
fi

function run_as_root() {
    if [[ ${is_root} == "1" ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

function check_pip_installed() {
    if [[ ! $(command -v pip) ]]; then
        read -p "Install pip? [Y/n] " i_pip
        if [[ ${i_pip} != "n" && ${i_pip} != "N" ]]; then
            wget https://bootstrap.pypa.io/get-pip.py
            python get-pip.py
        fi
    fi
}

function prompt_install() {
    read -p "Install $1? [Y/n] " do_install
    [[ ${do_install} == "" || ${do_install} == "y" || ${do_install} == "Y" ]]
}

function prompt_vim_plugin_install() {
    if prompt_install "$1"; then
        cp -r ~/.vim/bundle/"$1" ~/.vim/bundle
    fi
}

# only install the required scripts
read -p "Copy vim config file? [Y/n] " install_vim
if [[ ${install_vim} != "n" && ${install_vim} != "N" ]]; then
    cp .vimrc ~/
fi

if prompt_install "vim powerline"; then
    check_pip_installed
    pip install --user powerline-status
    if [[ ${is_mac_os} == "0" ]]; then
        mkdir -p ~/.fonts
        cp "Droid Sans Mono for Powerline.otf" ~/.fonts/
        run_as_root fc-cache -vf ~/.fonts/
    else
        echo "Install Droid Sans Mono for Powerline using Finder"
    fi
    # make sure that we're referencing the correct version of python in vimrc
    py_version=$(python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    if [[ -f ~/.vimrc ]]; then
        sed -i.bak "/python2.7/python${py_version}/g" ~/.vimrc
    fi
else
    if [[ -f ~/.vimrc ]]; then
        sed -i.bak '/statusline/d' ~/.vimrc
    fi
fi

if prompt_install "vim Syntastic"; then
    if [[ -f ~/.vimrc ]]; then
        sed -i.bak 'let g:/d' ~/.vimrc
    fi
fi

if prompt_install "ZSH"; then
    run_as_root apt-get install zsh
    sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    cp .zshrc ~/
    cp -r .zsh ~/
    read -p "Make ZSH the default shell? [Y/n] " make_default
    if [[ ${make_default} != "n" && ${make_default} != "N" ]]; then
        chsh -s $(which zsh)
    fi
fi

if prompt_install "tmux"; then
    run_as_root apt-get install tmux
    cp .tmux.conf ~/
    cp -r .tmux ~/
fi

if prompt_install "virtualenvwrapper"; then
    check_pip_installed
    pip install virtualenvwrapper
fi

if prompt_install "vim plugins"; then
    if prompt_install "pathogen (required for plugins)"; then
        mkdir -p ~/.vim/autoload ~/.vim/bundle && \
            curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
    else
        if [[ -f ~/.vimrc ]]; then
            sed -i.bak '/pathogen/d' ~/.vimrc
        fi
    fi

    all_plugins=( "vim-sensible" "vim-better-whitespace" "vim-surround" \
        "vim-misc" "vim-fugitive" "nerdtree" "syntastic" "YouCompleteMe" \
        "numbers" "vim-javascript" "vim-jsx" "typescript-vim" "vim-snipmate" \
        "ctrlp.vim" )
    if prompt_install "all plugins"; then
        for plugin in "${all_plugins[@]}"; do
            cp -r .vim/bundle/${plugin} ~/.vim/bundle
        done
    else
        for plugin in "${all_plugins[@]}"; do
            prompt_vim_plugin_install ${plugin}
        done
    fi
fi

echo "All done! \0/"
