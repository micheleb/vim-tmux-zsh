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

script_dir=$(pwd)
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

function os_install() {
    if [[ ${is_mac_os} == "1" ]]; then
        sudo brew install "$@"
    else
        sudo apt-get install "$@"
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

function check_node_installed() {
    if [[ ! $(command -v npm) ]]; then
        if prompt "Install nodeJS? (needed for JS autocomplete) [Y/n]"; then
            if [[ ${is_mac_os} == "1" ]]; then
                brew install node
            else
                cd ~
                wget https://deb.nodesource.com/setup_4.x -O node_setup
                chmod +x node_setup
                run_as_root ./node_setup
                os_install nodejs
            fi
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
    if [[ ! -e ~/.vim/bundle/"$1" ]]; then
        if prompt_install "$1"; then
            install_vim_plugin "$2" "$1"
        fi
    fi
}

function install_you_complete_me() {
    cd ~/.vim/bundle
    if [[ -e YouCompleteMe ]]; then
        if prompt "A YouCompleteMe folder exists. Overwrite it? [Y/n] "; then
            rm -rf YouCompleteMe
        else
            echo "YouCompleteMe installation is SKIPPED"
            return
        fi
    fi
    git clone "https://github.com/Valloric/YouCompleteMe.git" YouCompleteMe
    cd YouCompleteMe
    git submodule update --init --recursive
    os_install build-essential cmake
    os_install python-dev
    if prompt "Install JS support for YouCompleteMe? [Y/n] "; then
        check_node_installed
        cd ~/.vim/bundle
        git clone "https://github.com/ternjs/tern_for_vim.git" tern_for_vim
        cd tern_for_vim
        npm install tern
        cd ~/.vim/bundle/YouCompleteMe
        ./install.py --clang-completer --tern-completer
    else
        ./install.py --clang-completer
    fi
}

function install_vim() {
    if [[ ${is_mac_os} == "1" ]]; then
        brew install macvim --with-override-system-vim
        brew linkapps
    else
        os_install libncurses5-dev libgnome2-dev libgnomeui-dev libgtk2.0-dev libatk1.0-dev libbonoboui2-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev python${py_version}-dev git
        if [[ ! -e ~/git ]]; then
            mkdir ~/git
        fi
        cd ~/git
        os_install build-dep vim-common
        git clone https://github.com/vim/vim.git
        cd vim
        ./configure --with-features=huge --enable-multibyte \
            --enable-pythoninterp \
            --with-python-config-dir=/usr/lib/python${py_version}/config \
            --enable-cscope --prefix=/usr
        make
        run_as_root make install
        run_as_root update-alternatives --install /usr/bin/editor editor /usr/bin/vim 1
        run_as_root update-alternatives --set editor /usr/bin/vim
        run_as_root update-alternatives --install /usr/bin/vi vi /usr/bin/vim 1
        run_as_root update-alternatives --set vi /usr/bin/vim
    fi
}

function install_vim_plugins() {
    if prompt_install "vim plugins"; then
        if [[ ! -f ~/.vim/autoload/pathogen.vim ]]; then
            if prompt_install "pathogen (required for plugins)"; then
                mkdir -p ~/.vim/autoload ~/.vim/bundle && \
                    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
            else
                if [[ -f ~/.vimrc ]]; then
                    sed -i.bak '/pathogen/d' ~/.vimrc
                fi
            fi
        fi

        all_plugins=(
            "vim-sensible:tpope"
            "vim-unimpaired:tpope"
            "vim-better-whitespace:ntpeters"
            "vim-python-pep8-indent:hynek"
            "tagbar:majutsushi"
            "vim-surround:tpope"
            "vim-misc:xolox"
            "vim-fugitive:tpope"
            "nerdtree:scrooloose"
            "syntastic:scrooloose"
            "numbers.vim:myusuf3"
            "vim-javascript:pangloss"
            "vim-jsx:mxw"
            "typescript-vim:leafgarland"
            "vim-snipmate:garbas"
            "ctrlp.vim:kien" )

        if prompt_install "all plugins"; then
            for plugin in "${all_plugins[@]}"; do
                plugin_name=${plugin%%:*}
                author=${plugin#*:}
                install_vim_plugin "https://github.com/"${author}/${plugin_name}".git" ${plugin_name}
            done
        else
            for plugin in "${all_plugins[@]}"; do
                plugin_name=${plugin%%:*}
                author=${plugin#*:}
                prompt_vim_plugin_install ${plugin_name} "https://github.com/"${author}/${plugin_name}".git"
            done
        fi
        if prompt "Install YouCompleteMe? [Y/n] "; then

            install_you_complete_me
        fi
    fi
}

py_version=$(python -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')

if prompt_install "ZSH"; then
    os_install zsh
    sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    if prompt "Make ZSH the default shell? [Y/n] "; then
        chsh -s $(which zsh)
    fi
    cd ${script_dir}
    cp .zshrc ~/
fi

if prompt_install "tmux"; then
    os_install tmux
    cp .tmux.conf ~/
    cp -r .tmux ~/
fi

if prompt_install "virtualenvwrapper"; then
    check_pip_installed
    pip install virtualenvwrapper
fi

# before installing vim-related stuff, check whether vim is installed
has_vim=1
if [[ ! $(command -v vim) ]]; then
    has_vim=0
    if prompt_install "vim"; then
        install_vim
        has_vim=1
    fi
fi

# we need vim with python support for pathogen
if [[ ${has_vim} == "0" || $(vim --version | grep -c '+python') == 0 ]]; then
    if prompt "we need a modern version of vim with python support. Install it? [Y/n] "; then
        if [[ ${has_vim} == "1" ]]; then
            # uninstall it first
            if [[ ${is_mac_os} == "1" ]]; then
                run_as_root brew rm vim
            else
                run_as_root apt-get remove vim
            fi
        fi
        install_vim
        has_vim=1
    fi
fi

cd ${script_dir}

# don't install vim stuff if vim isn't installed
if [[ "${has_vim}" == "1" ]]; then
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
        pip install powerline-status
        if [[ ${is_mac_os} == "0" ]]; then
            run_as_root cp "Droid Sans Mono for Powerline.otf" /usr/share/fonts/
            run_as_root fc-cache -vf /usr/share/fonts/
        else
            echo "Install Droid Sans Mono for Powerline using Finder"
        fi
        # make sure that we're referencing the correct version of python in vimrc
        if [[ -f ~/.vimrc ]]; then
            sed -i.bak "s/python2.7/python${py_version}/g" ~/.vimrc
        fi
    else
        if [[ -f ~/.vimrc ]]; then
            sed -i.bak '/statusline/d' ~/.vimrc
        fi
    fi

    install_vim_plugins
fi

echo "All done! \O/"
