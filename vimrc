" 不会可以看这个 https://yongfu.name/Learn-Vim/
" 预计占用30MB
" 需要解决这个问题
set runtimepath+=$HOME/.vim/autoload/
call plug#begin()
	Plug 'preservim/nerdtree'					" 目录树
	Plug 'preservim/nerdcommenter', {'on': []}	" 注释工具
	Plug 'luochen1990/rainbow'					" 括号高亮
	Plug 'ycm-core/YouCompleteMe'				" 自动补全
	Plug 'nathanaelkane/vim-indent-guides'		" tab高亮
	Plug 'cohama/lexima.vim'					" 自动闭合括号
	Plug 'rust-lang/rust.vim'
	Plug 'preservim/tagbar'						" 层级目录显示
	Plug 'boydos/emmet-vim'						" xml, html 尖括号补全
	Plug 'dense-analysis/ale'					" 语法错误检查
call plug#end()

let g:ycm_semantic_triggers = {
\ 'c': ['re!\w{2}'],
\ "cpp": ['re!\w{2}'],
\ "python": ['re!\w{2}'],
\ "rust": ['re!\w{2}'],
\ "java": ['re!\w{2}'],
\ "go": ['re!\w{2}'],
\ "erlang": ['re!\w{2}'],
\ "perl": ['re!\w{2}'],
\ "cs": ['re!\w{2}'],
\ "lua": ['re!\w{2}'],
\ "javascript": ['re!\w{2}'],
\ }
let g:ycm_filetype_whitelist = {
\ "c": 1,
\ "cpp": 1,
\ "hpp": 1,
\ "cc": 1,
\ "cu": 1,
\ "h": 1,
\ "lua": 1,
\ "python": 1,
\ "go": 1,
\ "typescript": 1,
\ "sh": 1,
\ "zsh": 1,
\ "rust": 1,
\ "javascript": 1,
\ "cmake": 1,
\ "make": 1,
\ }
" 语法关键字自动补全
let g:ycm_seed_identifiers_with_sytanx = 1
" 字符串和注释内可用自动补全
let g:ycm_complete_in_string = 1
let g:ycm_complete_in_comments = 1

" 回车选中当前项
" 有点复杂, 参见 github.com/ycm-core/YouCompleteMe/issues/232
" 然而冇用
" let g:ycm_key_list_select_completion = ['<TAB>']
" let g:ycm_key_list_previous_completion = ['<S-TAB>']
" let g:ycm_key_list_stop_completion = ['<CR>', '<C-y>']

" 自动闭合
let g:lexima_enable_basic_rules = 1
" RGB彩色括号
let g:rainbow_active = 1

let g:NERDSpaceDelims			 = 1		" 在注释符号后加一个空格
let g:NERDCompactSexyComs		 = 1		" 紧凑排布多行注释
let g:NERDToggleCheckAllLines	 = 1		" 检查选中项是否有没被注释的项，有则全部注释
let g:NERDDefaultAlign			 = 'left'	" 逐行注释左对齐
let g:NERDCommentEmptyLines		 = 1		" 允许空行注释
let g:NERDTrimTrailingWhitespace = 1		" 取消注释时删除行尾空格
let g:NERDToggleCheckAllLines	 = 1		" 检查选中的行操作是否成功
let g:NERDTreeWinSize			 = 16		" 侧边栏大小

let g:indent_guides_enable_on_vim_startup = 1

let g:user_emmet_install_global = 0
let g:user_emmet_expandabbr_key = '<C-e>'

let g:ale_lint_on_text_changed = 'never'
let g:ale_completion_delay = 100 " ms
let g:ale_lint_on_enter = 0
let g:ale_sign_error = 'x'
let g:ale_sign_warning = '!'
" 这几个得提前去下才行
" 其他怎么办？
let g:ale_linters = {
\   'c++': ['clang'],
\   'c': ['clang'],
\   'python': ['pylint'],
\	'go': ['gofmt', 'golint', 'gopls', 'govet'],
\}
let g:ale_c_clangtidy_checks = ['-*', 'cppcoreguidelines-*']
let g:ale_fix_on_save = 1

autocmd FileType html,css,xml EmmetInstall


" TOFIX: 如果在非常大的项目里面(比如下载过插件后的这个仓库的目录下)用 youcompleteme 会巨卡，
"	prompt: long latency vim youcompleteme
" YouCompleteMe on and off with F3
" thanks https://vi.stackexchange.com/a/36667
func Toggle_ycm()
    if g:ycm_show_diagnostics_ui == 0
        let g:ycm_auto_trigger = 1
        let g:ycm_show_diagnostics_ui = 1
        :YcmRestartServer
        :e
        :echo "YCM on"
    elseif g:ycm_show_diagnostics_ui == 1
        let g:ycm_auto_trigger = 0
        let g:ycm_show_diagnostics_ui = 0
        :YcmRestartServer
        :e
        :echo "YCM off"
    endif
endfunction
map <F3> :call Toggle_ycm() <CR>


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
	let ch="'\""
	if line("'\"") > line("$")
		let ch = "$"
	endif
	exec "norm ".ch
endfunc


" 设置文件头
func Get_sign() 
	let sharp_list = [
		\ 'sh', 'python', 
		\ 'zsh', 'make', 
		\ 'cmake', 'yaml'
	\ ]
	for item in sharp_list
		if &filetype == item
			return '# '
		endif
	endfor
	if &filetype == 'lua'
		return '-- '
	elseif (&filetype == 'xml' || &filetype == 'html')
		return "<--! "
	elseif &filetype != 'rust'
		return '/// '
	else
		return '// '
	endif
endfunc

func Pad_header()
	let license = "SPDX-LICENSE-IDENTIFIER: GPL2.0"
	let [header_comment, sign] = ['', Get_sign()]
	" addtion, comment_ed email_bracket end_of_email_bracket
	let [addt, cloz, br, ebr] = ['', '', '<', '>']

	" 难以吐槽这个python
	if (&filetype == 'sh' || &filetype == 'zsh' || &filetype == 'python')
		let header_comment .= "#!/usr/bin/env ".&filetype."\n"
		let header_comment .= "# -*- coding: utf-8 -*-"."\n"
	elseif (&filetype == 'xml' || &filetype == 'html')
		" xml 尖括号冲突
		let [cloz, br, ebr] = [' -->', '{', '}']
	else
		let addt = sign."\n"
	endif

	let header_comment .= sign.license.cloz."\n".addt
	let header_comment .= sign."(C) All rights reserved. "
	" TODO: 别人如果要用，邮箱难道还要到这个函数里面来改吗？
	let header_comment .= "Author: ".br."kisfg@hotmail.com"
	let header_comment .= ebr." in ".strftime("%Y").cloz."\n"
	let header_comment .= sign."Created at ".strftime("%c").cloz."\n"
	let header_comment .= sign."Last modified at ".strftime("%c").cloz."\n"
	" TODO: 加 prompt 用于辅助构建，比如 cmake --help-command-list
	exec "normal i".header_comment | exec "normal G"
endfunc

func Update_info() 
	let [sign, payload, prefix] = [Get_sign(), strftime("%c"), 'Last modified at ']
	let exam = sign.prefix.'.*'
	let repl = sign.prefix.payload
	let [st, ed, flag] = [0, 8, 0]
	while st < ed
		let linum = getline(st)
		let test = match(linum, exam)
		if (test == -1)
			let st = st + 1
			continue
		endif
		let res = substitute(linum, exam, repl, '')
		call setline(st, res) 
		let flag = 1
		break
	endwhile

	if (flag == 0)
		call append(0, sign.prefix.payload)
	endif

	" 更新后自动去除行末空格和空行
	silent! %s/\s\+$//ge
	silent! %s/^$\n\+\%$//ge
	" TODO: 更新后似乎光标错位
endfunc

autocmd BufNewFile 
	\ *.{c[cu],java,lua,[ch]pp,[ch],[hs]h,py,go,[jrt]s,html\=,xml,yaml},makefile,CMakeLists.txt 
	\ exec "call Pad_header()"
autocmd BufWritePre,filewritepre 
	\ *.{c[cu],java,lua,[ch]pp,[ch],[hs]h,py,go,[jrt]s,html\=,xml,yaml},makefile,CMakeLists.txt 
	\ exec "call Update_info()" | silent mkview
autocmd BufWinEnter 
	\ *.{c[cu],java,lua,[ch]pp,[ch],[hs]h,py,go,[jrt]s,html\=,xml,yaml},makefile,CMakeLists.txt 
	\ silent loadview

" 这里来主动删掉
autocmd BufWritePre vimrc silent exec "!python ~/.vim/clean_vimview.py -ra true"
" 修改后自动修改
autocmd! BufWritePost vimrc source %
""" 自动命令配置
" TODO: 检查插件是否存在，如果不存在则安装

" 启动nerdTree并把光标留在第二个窗口
autocmd VimEnter * NERDTree | wincmd p
autocmd BufEnter * exec "call Config_NerdTree()"
" 返回上一次对该文件的编辑位置
autocmd BufReadPost * exec "call Ret_to_last_pos()"
" 不会自动增加注释
" TODO: 不过有时候也挺麻烦的，还是用一个键位来控制这个的使能吧
autocmd Filetype * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
"" 其它内置的配置选项
filetype on
filetype plugin on
filetype indent on

" ctrl+A 为全选
map <C-A> ggVGY
map <silent> <C-&> :NERDTreeToggle<CR>
nmap <F8> :TagbarToggle<CR>
" 调整窗口的映射
map <C-W><UP> <ESC><C-W>-
map <C-W><DOWN> <ESC><C-W>+
map <C-W><LEFT> <ESC><C-W>>
map <C-W><RIGHT> <ESC><C-W><

colorscheme gruvbox
" color morning
set background=dark
set viminfo='1000,<999

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
set ignorecase
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
" 高亮一直显示
" set hlsearch
" set nowrap " 不自动折行
set linebreak " 遇到特殊符号才折行
syntax enable
syntax on

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

if has("gui_gtk2")
	set guifont=Fira\ Code\ Medium\ 12,JetBrains\ Mono\ Medium\ 12
elseif (has("gui_macvim") || has("gui_win32"))
	set guifont=Fira_Code_Medium:h12,JetBrains_Mono_Medium:h12
endif
	

set cursorline
highlight CursorLine guibg=lightgrey 
" 透明背景
highlight Normal ctermbg=none
