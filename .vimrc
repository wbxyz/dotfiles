" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
syntax on

" Maintain undo history after vim is closed
set undofile

" Store the undo files somewhere hidden
set undodir=~/.config/nvim/undodir

" Number of undos to save in the undofile
set undolevels=1000

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch
 
" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase
 
" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start
 
" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent
 
" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler
 
" Show the hidden characters such as tab, newlines, and other whitespace "
set list

" Choose the characters to ilustrate the whitespace hidden characters
set listchars=tab:»\ ,extends:›,precedes:‹,nbsp:·,trail:·

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm
 
" Use visual bell instead of beeping when doing something wrong
set visualbell
 
" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=
 
" Enable use of the mouse for all modes
set mouse=a
 
" Display line numbers on the left
" set number
 
" Display the relative line numbers.
" When number is set, the number at the current line will be the absolute line
" number.
" set relativenumber

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F11>
 
 
" Indentation settings for using hard tabs for indent. Display tabs as
" two characters wide.
set shiftwidth=2
set tabstop=2
 
 
" Map <C-L> (redraw screen) to also turn off search highlighting until the
" next search
nnoremap <C-L> :nohl<CR><C-L>

" Make vim wrap long lines between words.
set wrap lbr

" Move visual lines instead of hard lines when a line is wrapped
noremap j gj
noremap k gk
