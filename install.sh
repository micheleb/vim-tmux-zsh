#!/bin/bash

# we need bash 4 to use associative arrays
if ((BASH_VERSINFO[0] < 4)); then
    echo "Sorry, we need bash version 4 or higher to run this script"
fi

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

function prompt() {
    read -p "$1" confirm
    [[ ${confirm} == "" || ${confirm} == "y" || ${confirm} == "Y" ]]
}

function check_pip_installed() {
    if [[ ! $(command -v pip) ]]; then
        if prompt "Install pip? [Y/n] "; then
            wget https://bootstrap.pypa.io/get-pip.py
            python get-pip.py
        fi
    fi
}

function prompt_install() {
    read -p "Install $1? [Y/n] " do_install
    [[ ${do_install} == "" || ${do_install} == "y" || ${do_install} == "Y" ]]
}

function install_vim_plugin() {
    cd ~/.vim/bundle
    git clone "$1" "$2"
}

function prompt_vim_plugin_install() {
    if prompt_install "$1"; then
        install_vim_plugin "$2" "$1"
    fi
}

function install_you_complete_me() {
    cd ~/.vim/bundle
    git clone "https://github.com/Valloric/YouCompleteMe.git" YouCompleteMe
    cd YouCompleteMe
    run_as_root apt-get install build-essential cmake
    run_as_root apt-get install python-dev
    ./install.py --clang-completer --tern-completer
}

# only install the required scripts
if prompt "Copy vim configuration? [Y/n] "; then
    cp .vimrc ~/
    if [[ ! -e ~/.vim ]]; then
        mkdir ~/.vim
    fi
    cp -r .vim/colors ~/.vim/
    cp -r .vim/syntax ~/.vim/
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

if prompt_install "ZSH"; then
    run_as_root apt-get install zsh
    sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    cp .zshrc ~/
    cp -r .zsh ~/
    if prompt "Make ZSH the default shell? [Y/n] "; then
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
        if [[ -f ~/.vimrc && ! -f ~/.vim/autoload/pathogen.vim ]]; then
            sed -i.bak '/pathogen/d' ~/.vimrc
        fi
    fi

    declare -A all_plugins

    all_plugins=( \
        ["vim-sensible"]="git://github.com/tpope/vim-sensible.git" \
        ["vim-better-whitespace"]="git://github.com/ntpeters/vim-better-whitespace.git" \
        ["vim-surround"]="git://github.com/tpope/vim-surround.git" \
        ["vim-misc"]="https://github.com/xolox/vim-misc.git" \
        ["vim-fugitive"]="https://github.com/tpope/vim-fugitive.git" \
        ["nerdtree"]="https://github.com/scrooloose/nerdtree.git" \
        ["syntastic"]="https://github.com/scrooloose/syntastic.git" \
        ["numbers.vim"]="https://github.com/myusuf3/numbers.vim.git" \
        ["vim-javascript"]="https://github.com/pangloss/vim-javascript.git" \
        ["vim-jsx"]="https://github.com/mxw/vim-jsx.git" \
        ["typescript-vim"]="https://github.com/leafgarland/typescript-vim.git" \
        ["vim-snipmate"]="https://github.com/garbas/vim-snipmate.git" \
        ["ctrlp.vim"]="https://github.com/ctrlpvim/ctrlp.vim.git" )

    if prompt_install "all plugins"; then
        for plugin_name in "${!all_plugins[@]}"; do
            install_vim_plugin ${all_plugins[${plugin_name}]} ${plugin_name}
        done
    else
        for plugin_name in "${!all_plugins[@]}"; do
            prompt_vim_plugin_install ${plugin_name} ${all_plugins[${plugin_name}]}
        done
    fi
    if prompt "Install YouCompleteMe? [Y/n] "; then
        install_you_complete_me
    fi
fi

echo "All done! \0/"
