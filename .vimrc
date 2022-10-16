" This my configuration for the Vim. Some of the pieces of configurations I took
" from different places on the internet some of them I write myself.
"
" To see local settings look at the `~/.vimrc.local`. That files contains syntax
" theme setup, plugin manager settings, configuration of different plugins.
"
" @date: 06.01.18
" @author: Andrey Albershteyn
"
" Set line number
set number

" Set encoding of vim
set encoding=utf-8

" Byte order mark
set nobomb

" Highlight search item
set hlsearch

" Use utf-8 for writing
set fileencoding=utf-8
set termencoding=utf-8

" Use .vimrc if it is appear in current folder. !!!DANGER!!!
set exrc
set secure

" Split navigation witouh CTRL+W
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Navigation in insert mode
" imap <C-j> <Down>
" imap <C-k> <Up>
" imap <C-h> <Left>
" imap <C-l> <Right>

" Set Splits more natural (vsplit open new window to the right...)
set splitbelow
set splitright

" Tabs to spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4
" Tabs for makefiles
autocmd FileType make   set noexpandtab

" Fix backspace
set nocompatible
set backspace=2

" Set paste to mode to F5
nnoremap <F5> :set invpaste paste?<Enter>
imap <F5> <C-O><F5>
set pastetoggle=<F5>

" Build
nnoremap <C-b> :make!<CR>

" Folding
setlocal foldmethod=indent
setlocal foldlevel=20

" Space to goggle folds.
nnoremap <Space> za
vnoremap <Space> za

" Undo history
set undofile
set undodir=~/.vim/undo//
set backupdir=~/.vim/backup//
set directory=~/.vim/swp//

" Highlight current line
set cursorline
"==============================================================================
" Coloring
"==============================================================================
" Set word wrapping
set tw=80
set textwidth=80

" Set the textwidth to 68 characters for guilt commit messages
au BufEnter,BufNewFile,BufRead guilt.msg.*,.gitsendemail.*,git.*,*/.git/* set tw=68

" Set color column at 80 symbol
set cc=+1
highlight ColorColumn ctermbg=150

" highlight whitespace damage
autocmd ColorScheme * highlight RedundantSpaces ctermbg=red guibg=red
autocmd ColorScheme * match RedundantSpaces /\s\+$\| \+\ze\t/

" Set up color scheme and syntax highlighting
set t_Co=256
syntax enable

if &term =~ '256color'
    " Disable Background Color Erase (BCE) so that color schemes
    " work properly when Vim is used inside tmux and GNU screen.
    set t_ut=
endif

" Syntax coloring lines that are too long just slows down the world
set synmaxcol=128

" Speed up terminal
set ttyfast
if !has('nvim')
    set ttyscroll=3
endif
set lazyredraw

"==============================================================================
" Spell Check
"==============================================================================
" Toggle spell checking on and off with `,s`
let mapleader = ","
nmap <silent> <leader>s :set spell!<CR>

" Turn spelling on for Markdown, text, Latex files
autocmd BufRead,BufNewFile *.md,*.txt,*.tex setlocal spell

" Auto correct last word in insert mode by CTRL+e
imap <C-e> <Esc>[s1z=`]a

" Load local machine's settings
if filereadable(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif

" Move .viminfo to ~/.vim
set viminfo+=n~/.vim/viminfo
if has('nvim')
	let &viminfo .= '.nvim'
endif
