" This must be first, because it changes other options as side effect
set nocompatible

set tabstop=3      " The width of tab is set to 3
                   " Still it is a \t. It is just that
                   " Vim will interpret it to be having
                   " a width of 3.
 
set shiftwidth=3  " Indents will have a width of 3
 
set softtabstop=3 " Seta the number of columns for a tab
set expandtab     " Expand TABs to spaces

set cindent       " autoindent for C like syntax

"set number        " Display line number
set title         " change terminal's title

set hidden        " hide buffers instead of closing them this
                  " means that the current buffer can be put
                  " to background without bein written; and

set relativenumber
set nowrap
set history=1000
set undolevels=1000

"
" Highlight current line
"
color desert
set cursorline
hi CursorLine term=bold cterm=bold guibg=Grey40

"
" Search
"

set wildignore=*.swp,*.bak,*.pyc,*.class,*.exe,*.bat,*.obj,*.dll,*.swp,*.lib,*.pdb,*.idb,*.d,*.o,*.so,.hg,.git,.svn,CVS

set incsearch     " show search matches as you type
set hlsearch      " highlight search terms

set showmatch     " set show matching parenthesis
set ignorecase    " ignore case when searching
set smartcase     " ignore case if search pattern is all lowercase,
                  "    case-sensitive otherwise


"
" Vundle
" Plugin manager
" https://github.com/VundleVim/Vundle.vim
"

filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
   " alternatively, pass a path where Vundle should install plugins
   "call vundle#begin('~/some/path/here')

   " let Vundle manage Vundle, required
   Plugin 'VundleVim/Vundle.vim'

   Plugin 'git://github.com/powerline/powerline.git', {'rtp': 'powerline/bindings/vim/'}

   Plugin 'https://github.com/ctrlpvim/ctrlp.vim.git'


   " All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required



"
" Plugins
"

"
"" powerline
"
set laststatus=2 " show status line always
set noshowmode   " disable mode message on the last line
set t_Co=256     " number of colors

"
" Key bindings
"

"search word under cursor in code"
map <F4> :execute "vimgrep /" . expand("<cword>") . "/j **.cc **.h" <Bar> cw<CR>
"build and rebuild
map <F5> :make <CR>
map <C-F5> :!make clobber; make <CR>

set nobackup
set noswapfile

" use ; instead of :
nnoremap ; :
inoremap <TAB> <ESC>

"
" cscope
"
set cscopetag

"
" hard mode
"
noremap <Up>    <NOP>
noremap <Down>  <NOP>
noremap <Left>  <NOP>
noremap <Right> <NOP>
