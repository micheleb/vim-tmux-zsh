# vim-tmux-zsh
utilities, conf files and plugins ready to be checked out and installed on servers.

# usage
clone the repo, and run `install.sh`:

    git clone https://github.com/micheleb/vim-tmux-zsh
    cd vim-tmux-zsh
    ./install.sh

the script will ask what to install

# things that can be installed
- ZSH (using [oh my zsh][1])
- tmux (with a vim-friendly configuration copied by [this repo][2])
- pip (if not installed)
- [virtualenvwrapper][3]
- vim (if not installed, or if the installed version doesn't have python support)
- [pathogen][4]
- a bunch of vim plugins:
    - [vim powerline](https://github.com/powerline/powerline), using Droid a
    patched version of Droid Sans Mono to display fancy characters when using
    ZSH
    - [vm-sensible](https://github.com/tpope/vim-sensible)
    - [vm-better-whitespace](https://github.com/ntpeters/vim-better-whitespace)
    - [tagbar](https://github.com/majutsushi/tagbar)
    - [vim-surround](https://github.com/tpope/vim-surround)
    - [vim-misc](https://github.com/xolox/vim-misc)
    - [vim-fugitive](https://github.com/tpope/vim-fugitive)
    - [nerdtree](https://github.com/scrooloose/nerdtree)
    - [syntastic](https://github.com/scrooloose/syntastic)
    - [numbers.vim](https://github.com/myusuf3/numbers.vim)
    - [vim-javascript](https://github.com/pangloss/vim-javascript)
    - [vim-jsx](https://github.com/mxw/vim-jsx)
    - [typescript-vim](https://github.com/leafgarland/typescript-vim)
    - [vim-snipmate](https://github.com/garbas/vim-snipmate)
    - [ctrlp.vim](https://github.com/ctrlpvim/ctrlp.vim)
    - [YouCompleteMe](https://github.com/Valloric/YouCompleteMe.git)
        - with the optional [tern for vim][5] to support Javascript
        - if node is not installed, the script installs it, as well

# supported platforms
So far, the script works on Linux (Debian Wheezy and up, Ubuntu 14 and up) and
Mac OSX 11.

# YMMV
Some things will inevitably not work on some machines (especially when a compile
phase is involved, such as when installing vim).

[1]: https://github.com/robbyrussell/oh-my-zsh/
[2]: https://github.com/nicknisi/vim-workshop/blob/master/tmux.conf
[3]: http://virtualenvwrapper.readthedocs.io/
[4]: https://github.com/tpope/vim-pathogen
[5]: https://github.com/ternjs/tern\_for\_vim.git
