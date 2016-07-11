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

# only install the required scripts
read -p "Copy vim config file? [Y/n] " install_vim
if [[ ${install_vim} != "n" && ${install_vim} != "N" ]]; then
    cp .vimrc ~/
fi

read -p "Install vim pathogen (required for plugins)? [Y/n] " install_pathogen
if [[ ${install_pathogen} != "n" && ${install_pathogen} != "N" ]]; then
    mkdir -p ~/.vim/autoload ~/.vim/bundle && \
        curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
fi

read -p "Install vim powerline? [Y/n] " install_powerline
if [[ ${install_powerline} != "n" && ${install_powerline} ]]; then
    pip install --user powerline-status
    if [[ ${is_mac_os} == "0" ]]; then
       cp "Droid Sans Mono for Powerline.otf" ~/.fonts/
       run_as_root fc-cache -vf ~/.fonts/
    else
        echo "Install Droid Sans Mono for Powerline using Finder"
    fi
else
    if [[ -f ~/.vimrc ]]; then
        sed -i.bak '/statusline/d' ~/.vimrc
    fi
fi

read -p "Install vim Syntastic? [Y/n] " install_syntastic
if [[ ${install_syntastic} == "n" && ${install_syntastic} == "N" ]]; then
    if [[ -f ~/.vimrc ]]; then
        sed -i.bak 'let g:/d' ~/.vimrc
    fi
fi

read -p "Install ZSH? [Y/n] " install_zsh
if [[ ${install_zsh} != "n" && ${install_zsh} != "N" ]]; then
    run_as_root apt-get install zsh
    sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    cp .zshrc ~/
    cp -r .zsh ~/
fi

echo "All done! \0/"
