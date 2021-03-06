set nocp
execute pathogen#infect()
syntax on
filetype plugin indent on
set runtimepath^=~/.vim/bundle/ctrlp.vim
set t_Co=256
set encoding=utf-8
set background=dark
set colorcolumn=80
colorscheme hybrid
set tabstop=4
set shiftwidth=4
set expandtab
set pastetoggle=<F2>
nmap <F3> ysiw
nmap <F4> cs
nmap <F5> ds
" navigate between panes in a more natural way
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
" split panes to the right and below
set splitbelow
set splitright
autocmd BufWritePre * StripWhitespace
hi Normal ctermbg=none
highlight NonText ctermbg=none
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_flow = 1

nmap <F3> ysiw
nmap <F4> cs
nmap <F5> ds

let mapleader = "\<Space>"
nmap <Leader><Leader> :YcmCompleter GoTo<CR>

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:jsx_ext_required = 0
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_typescript_checkers = ['tslint']
set rtp+=/usr/local/lib/python2.7/dist-packages/powerline/bindings/vim/
let g:Powerline_symbols = 'fancy'
set laststatus=2
let g:numbers_exclude = ['nerdtree']
highlight LineNr ctermbg=39

let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1

au BufNewFile *.py 0r ~/.vim/templates/python.template
