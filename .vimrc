set nocompatible
filetype off

if has("win32")
	set rtp+=$HOME/.vim/bundle/Vundle.vim
else
	set rtp+=~/.vim/bundle/Vundle.vim
endif

"Vundle Plugin Manager
"========================
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'jeaye/color_coded'

Plugin 'blockloop/vim-codeschool'
Plugin 'tikhomirov/vim-glsl'
call vundle#end()
"==============================

filetype plugin indent on

syntax on
set number
colorscheme codeschool

set tabstop=4
set shiftwidth=4
set autoindent
set smartindent
set smarttab
set cindent

set textwidth=0
set wrapmargin=0 

set hlsearch
set incsearch

set nobackup
set nowb
set noswapfile

set fileformats=unix
set autoread

"C/C++ Autocompletion
"===============================
set completeopt-=preview
let g:ycm_goto_buffer_command = 'same-buffer'
let g:ycm_confirm_extra_conf = 0
let g:ycm_add_preview_to_completeopt = 0
map <Leader>g :YcmCompleter GoTo <CR>
"===============================

if has("gui_running")
	if has("win32")
		set guifont=consolas:h12
	else
		set guifont=inconsolata\ 12
	endif
	set guioptions-=m
	set guioptions-=T
	set guioptions-=r
	set guioptions-=L
endif

" set autoindent
set backspace=indent,eol,start

imap <S-Space> <Esc>
inoremap {<CR> {<CR>}<Esc>:call SmartBrace()<CR>O

if has("win32")
	noremap <F3> :!D:/workspace/tjw/msbuild/Debug/tjw.exe % 
else
	map <Leader>\ :call TJWManip() <CR> :echo g:tjw_output <CR>
endif


let g:glsl_default_version = 'glsl450'
let g:glsl_file_extensions = '*.glsl,*.vert,*.frag,*.geom'

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ycm_global_ycm_extra_conf = '/home/torin/.ycm_global_ycm_extra_conf.py'

function! TJWManip()
	:w
	let shellcmd = '~/workspace/ductus/a.out ' .bufname("%")
	let g:tjw_output = system(shellcmd)
	:e!
endfunction

function! SmartBrace()
	let line_number = line(".") - 1
	if getline(line_number) !~ "^\\s*struct"
		return
	endif
	execute "normal! a;"
endfunction
