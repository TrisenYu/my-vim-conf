" 不会可以看这个 https://yongfu.name/Learn-Vim/
set runtimepath+=~/.vim/autoload/
call plug#begin()
	Plug 'preservim/nerdtree'
	Plug 'preservim/nerdcommenter', {'on': []}
	Plug 'luochen1990/rainbow' 
	Plug 'ycm-core/YouCompleteMe'
	Plug 'nathanaelkane/vim-indent-guides'
	Plug 'cohama/lexima.vim' " 自动闭合括号
	Plug 'vim-scripts/vcscommand.vim'
	" 下面两个插件还是不够好
	" Plug 'pocke/keycast.vim'
	" Plug 'pocke/vanner'
call plug#end()

let g:ycm_semantic_triggers =  {
	\ 'c,cpp,python,java,go,erlang,perl,cs,lua,javascript': ['re!\w{2}'],
	\ }
let g:ycm_filetype_whitelist = {
	\ "c": 1,
	\ "cpp": 1,
	\ "hpp": 1,
	\ "cc": 1,
	\ "h": 1,
	\ "py": 1,
	\ "go": 1,
	\ "js": 1,
	\ "ts": 1,
	\ "objc": 1,
	\ "sh": 1,
	\ "zsh": 1,
	\ }
" 语法关键字自动补全
let g:ycm_seed_identifiers_with_sytanx = 1
" 自动补全字符串和注释
let g:ycm_complete_in_string = 1
let g:ycm_complete_in_comments = 1

" 回车选中当前项
" 有点复杂,参见 github.com/ycm-core/YouCompleteMe/issues/232
" 然而冇用
let g:ycm_key_list_select_completion = ['<TAB>']
let g:ycm_key_list_previous_completion = ['<S-TAB>']
let g:ycm_key_list_stop_completion = ['<CR>', '<C-y>', '<Up>', '<Down>']

" 自动闭合
let g:lexima_enable_basic_rules = 1
" RGB彩色括号
let g:rainbow_active = 1

let g:NERDSpaceDelims            = 1		" 在注释符号后加一个空格
let g:NERDCompactSexyComs        = 1		" 紧凑排布多行注释
let g:NERDToggleCheckAllLines    = 1		" 检查选中项是否有没被注释的项，有则全部注释
let g:NERDDefaultAlign           = 'left' 	" 逐行注释左对齐
let g:NERDCommentEmptyLines      = 0		" 允许空行注释
let g:NERDTrimTrailingWhitespace = 1		" 取消注释时删除行尾空格
let g:NERDToggleCheckAllLines    = 1		" 检查选中的行操作是否成功
let g:NERDTreeWinSize = 20


""" 自动命令配置
" TODO: 检查插件是否存在，如果不存在则安装

" 启动nerdTree并把光标留在第二个窗口
autocmd VimEnter * NERDTree | wincmd p
autocmd BufEnter * exec "call Config_NerdTree()"
" 返回上一次对该文件的编辑位置
autocmd BufReadPost * exec "call Ret_to_last_pos()" 

" vimscript 要求函数名首字母大写
func Config_NerdTree() 
	if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree()
		call feedkeys(":quit\<CR>:\<BS>")
	endif
endfunc

func Ret_to_last_pos() 
	if line("'\"") <= 0
		return
	endif
	if line("'\"") <= line("$")
		exec "norm '\""
	else
		exec "norm $"
	endif
endfunc


" 设置文件头
autocmd BufNewFile *.cc,*.java,*.[ch]pp,*.[ch],*.[hs]h,*.py,*.go,*.[jt]s exec "call Pad_header()"
func Pad_header()

	if &filetype == 'sh'
		call setline(1, "\#!/usr/bin/env zsh")
	elseif &filetype == 'python'
		call setline(1, "\#!/usr/bin/env python3")
	endif

	" 难以吐槽这个python
	if &filetype == 'sh' || &filetype == 'python'
		call append(line("."), "\# -*- coding: utf-8 -*-") 
		call append(line(".")+1, "\# SPDX-LICENSE-IDENTIFIER: GPL2.0")
		call append(line(".")+2, "\# (C) All rights reserved. Author: <kisfg@hotmail.com> in ".strftime("%Y"))
		call append(line(".")+3, "\# Created at ".strftime("%c"))
		call append(line(".")+4, "")
	endif

	let target_src=['cpp', 'hpp', 'cc', 'c', 'h', 'hh', 'java', 'javascript', 'go', 'typescript']
	for _filetype in target_src
		" 直接用if竟然不能跨行，吐了
		if &filetype == _filetype
			call setline(1, "/// SPDX-LICENSE-IDENTIFIER: GPL2.0")
			call append(line("."), "///")
			call append(line(".")+1, "/// (C) All rights reversed.")
			call append(line(".")+2, "/// Author: <kisfg@hotmail.com> in ".strftime("%Y"))
			call append(line(".")+3, "/// FileName: ".expand("%"))
			call append(line(".")+4, "/// Created at ".strftime("%c"))
			call append(line(".")+5, "")
			break
		endif
	endfor
endfunc


" TODO: 设置最后的修改时间
func Set_last_modified_time() 
endfunc 

"" 其它内置的配置选项
filetype on
filetype plugin on
filetype indent on
filetype plugin indent on


colorscheme gruvbox
set background=dark

" 无需下发命令延时
set notimeout

set nu rnu
set mouse=a

" 竖直滚动时光标离底部18行
set scrolloff=18


set encoding=utf-8
set fileencodings=utf-8,gbk,shift-jis,latin1
set helplang=cn
" set langmenu=zh_CN.UTF-8

set title

set showcmdloc=statusline
set showcmd
set showmode

" 这个滴滴滴有点像叮叮叔爆炸
set noerrorbells
" 没有这个比较辣眼睛
set novisualbell

set showmatch
" 括号高亮的时间设置为1ms
set matchtime=1
set autoread

" 移动光标遇到空行后不会重置到开头
set nostartofline

set smartcase
set incsearch
set wrapscan
set ignorecase
syntax enable

set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set cindent
set smarttab
set noexpandtab

" 总是显示状态行
set laststatus=2
set completeopt-=preview
set linebreak
set tw=256

" 显示不可见字符，并定制行尾空格、tab键显示符号
set list
set listchars=tab:\+-,precedes:«,extends:»

set selection=exclusive
set selectmode=mouse,key
" 如果设置不兼容，就看不到命令

