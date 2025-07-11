" 不会可以看这个 https://yongfu.name/Learn-Vim/
" 预计占用30MB
set runtimepath+=~/.vim/autoload/
call plug#begin()
	Plug 'preservim/nerdtree'					" 目录树
	Plug 'preservim/nerdcommenter', {'on': []}	" 注释工具
	Plug 'luochen1990/rainbow'					" 括号高亮
	Plug 'ycm-core/YouCompleteMe'				" 自动补全
	Plug 'nathanaelkane/vim-indent-guides'		" tab高亮
	Plug 'cohama/lexima.vim'					" 自动闭合括号
call plug#end()

let g:ycm_semantic_triggers = {
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
" 字符串和注释内可用自动补全
let g:ycm_complete_in_string = 1
let g:ycm_complete_in_comments = 1

" 回车选中当前项
" 有点复杂, 参见 github.com/ycm-core/YouCompleteMe/issues/232
" 然而冇用
let g:ycm_key_list_select_completion = ['<TAB>']
let g:ycm_key_list_previous_completion = ['<S-TAB>']
let g:ycm_key_list_stop_completion = ['<CR>', '<C-y>']

" 自动闭合
let g:lexima_enable_basic_rules = 1
" RGB彩色括号
let g:rainbow_active = 1

let g:NERDSpaceDelims			= 1		" 在注释符号后加一个空格
let g:NERDCompactSexyComs		= 1		" 紧凑排布多行注释
let g:NERDToggleCheckAllLines	= 1		" 检查选中项是否有没被注释的项，有则全部注释
let g:NERDDefaultAlign			= 'left'	" 逐行注释左对齐
let g:NERDCommentEmptyLines		= 0		" 允许空行注释
let g:NERDTrimTrailingWhitespace= 1		" 取消注释时删除行尾空格
let g:NERDToggleCheckAllLines	= 1		" 检查选中的行操作是否成功
let g:NERDTreeWinSize = 16

let g:indent_guides_enable_on_vim_startup = 1

""" 自动命令配置
" TODO: 检查插件是否存在，如果不存在则安装

" 启动nerdTree并把光标留在第二个窗口
autocmd VimEnter * NERDTree | wincmd p
autocmd BufEnter * exec "call Config_NerdTree()"
" 返回上一次对该文件的编辑位置
autocmd BufReadPost * exec "call Ret_to_last_pos()"
autocmd Filetype * setlocal formatoptions-=cro " 不会自动增加注释

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
func Get_sign() 
	if &filetype == 'sh' || &filetype == 'python'
		return '# '
	elseif &filetype == 'lua'
		return '-- '
	else
		return '/// '
	endif
endfunc

func Pad_header()
	let license = "SPDX-LICENSE-IDENTIFIER: GPL2.0\n"
	let header_comment = ''
	let sign = Get_sign()
	let tail = ''

	if &filetype == 'sh'
		let header_comment .= "#!/usr/bin/env zsh"."\n"
		let header_comment .= "# -*- coding: utf-8 -*-"."\n"
	" 难以吐槽这个python
	elseif &filetype == 'python'
		let header_comment .= "#!/usr/bin/env python3"."\n"
		let header_comment .= "# -*- coding: utf-8 -*-"."\n"
	else
		let tail .= sign."\n"
	endif

	let header_comment .= sign.license.tail
	let header_comment .= sign."(C) All rights reserved. "
	let header_comment .= "Author: <kisfg@hotmail.com> in ".strftime("%Y")."\n"
	let header_comment .= sign."Created at ".strftime("%c")."\n"
	let header_comment .= sign."Last modified at ".strftime("%c")."\n"
	exec "normal i".header_comment
	exec "normal G"
endfunc

func Update_info() 
	let sign = Get_sign()
	let payload = strftime("%c")
	let prefix = 'Last modified at '
	let exam = sign.prefix.'.*'
	let st = 0
	let ed = 8
	let flag = 0
	while st < ed
		let linum = getline(st)
		let test = match(linum, exam)
		if (test != -1)
			let res = substitute(linum, exam, sign.'Last modified at '.payload, '')
			call setline(st, res) 
			let flag = 1
			break
		endif
		let st = st + 1
	endwhile
	if (flag == 0)
		call append(0, sign.prefix.payload)
	endif
endfunc

autocmd BufNewFile *.{cc,java,lua,[ch]pp,[ch],[hs]h,py,go,[jt]s} exec "call Pad_header()"
autocmd BufWritePre,filewritepre,BufDelete *.{cc,java,lua,[ch]pp,[ch],[hs]h,py,go,[jt]s} exec "call Update_info()"


"" 其它内置的配置选项
filetype on
filetype plugin on
filetype indent on
filetype plugin indent on

" ctrl+A 为全选
" map <C-A> ggVGY

colorscheme gruvbox
set background=dark

" 无需下发命令延时
set notimeout

set number relativenumber
set mouse=a

" 竖直滚动时光标离底部18行
set scrolloff=18
set completeopt-=preview

set encoding=utf-8
set fileencodings=utf-8,gbk,shift-jis,latin1
set helplang=cn
set langmenu=zh_CN.UTF-8

set title

set showcmd
set showmode

set showmatch
" 括号高亮的时间设置为1ms
set matchtime=1
set autoread

" 这个滴滴滴有点像叮叮叔爆炸
set noerrorbells

" 没有这个比较辣眼睛
set novisualbell


" 移动光标遇到空行后不会重置到开头
set nostartofline

set smartcase
set incsearch
set nowrap " 不自动折行
set linebreak " 遇到特殊符号才折行
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
" set completeopt-=preview
set textwidth=256


" 显示不可见字符，并定制行尾空格、tab键显示符号
" set list
" u+2423
" TODO: 如果有缩进，这个复制还会把+---给一块复制进来
"		如果不能解决这个问题，上一个命令和下面这一条listchars
"		命令就不能开
" ,space:␣, 空格多看着有点眼花
" set listchars=tab:\+-,precedes:«,extends:»,nbsp:␣

" 如果设置不兼容，就看不到切换模式时的命令
" set nocompatible
" 下面这个不应该出现，从最开始用vim就是在可视模式下包含光标。
" set selection=exclusive

set selectmode=mouse,key
set t_Co=256 " 二百五十六色支持
set guifont=Fira\ Code\ Medium\ 12,JetBrains\ Mono\ Medium\ 12

set cursorline
highlight CursorLine guibg=lightgray
