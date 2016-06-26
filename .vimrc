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

set number        " Display line number
set title         " change terminal's title

set hidden        " hide buffers instead of closing them this
                  " means that the current buffer can be put
                  " to background without bein written; and

set relativenumber

set history=1000
set undolevels=1000

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

"set statusline=2 " show statusline always

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
