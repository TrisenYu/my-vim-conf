" 第一次看到配置当script来写
" 属实是大无语
" 不会可以看这个 https://yongfu.name/Learn-Vim/
" 预计占用30MB
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
	Plug 'vim-airline/vim-airline'				" status/tab line
	" 其实可以直接在这里用, {'do': './install_gadget.py --enable-c ...'}
	" 但是奈何这个配置没有那么智能，并不能折行，
	" 另外就是国内访问github速度感人，还得依靠镜像站加速
	" 所以还得移动到init.sh去做这件事
	Plug 'puremourning/vimspector'				" realtime-debug
	" Plug 'lkebin/vim-terwin'					" terminal设置
call plug#end()

":help PEP
" 这样就直接用这个vimrc内对缩进的设置了
let g:python_recommended_style = 0


let g:_plug_dir="$HOME/.vim/plugged"
" if filereadable(expand(_plug_dir."/vim-terwin/plugin/terwin.vim"))
" 	let g:TerWinSize = 8
" 	let g:TerWinLocation = 'botright'
" 	nnoremap <leader>term :TerWinToggle<CR>
" endif


" 语法关键字自动补全
if filereadable(expand(g:_plug_dir."/ale/autoload/ale.vim"))
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
endif

if filereadable(expand(g:_plug_dir."/YouCompleteMe/autoload/youcompleteme.vim"))
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
		\ "typescript": ['re!\w{2}'],
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
		\ "sh": 1,
		\ "zsh": 1,
		\ "rust": 1,
		\ "javascript": 1,
		\ "typescript": 1,
		\ "cmake": 1,
		\ "make": 1,
		\ }
	let g:ycm_seed_identifiers_with_sytanx = 1
	" 字符串和注释内可用自动补全
	let g:ycm_complete_in_string = 1
	let g:ycm_complete_in_comments = 1
	map <F3> :call Toggle_ycm() <CR>
	" 回车选中当前项
	" 有点复杂, 参见 github.com/ycm-core/YouCompleteMe/issues/232
	" 然而冇用
	" let g:ycm_key_list_select_completion = ['<TAB>']
	" let g:ycm_key_list_previous_completion = ['<S-TAB>']
	" let g:ycm_key_list_stop_completion = ['<CR>', '<C-y>']
	if expand("$HOME/.vim") == getcwd()
        let g:ycm_auto_trigger = 0
        let g:ycm_show_diagnostics_ui = 0
	endif
endif

" 启动nerdTree并把光标留在第二个窗口
if filereadable(expand(g:_plug_dir."/nerdtree/autoload/nerdtree.vim")) 
	let g:NERDSpaceDelims			 = 1		" 在注释符号后加一个空格
	let g:NERDCompactSexyComs		 = 1		" 紧凑排布多行注释
	let g:NERDToggleCheckAllLines	 = 1		" 检查选中项是否有没被注释的项，有则全部注释
	let g:NERDDefaultAlign			 = 'left'	" 逐行注释左对齐
	let g:NERDCommentEmptyLines		 = 1		" 允许空行注释
	let g:NERDTrimTrailingWhitespace = 1		" 取消注释时删除行尾空格
	let g:NERDToggleCheckAllLines	 = 1		" 检查选中的行操作是否成功
	let g:NERDTreeWinSize			 = 16		" 侧边栏大小
	let g:NERDTreeHidden			 = 0		" 不隐藏.文件
	let g:NERDTreeShowHidden		 = 1
	autocmd VimEnter * :NERDTree | wincmd p
	autocmd BufEnter * exec "call Config_NerdTree()"
	map <silent> <C-&> :NERDTreeToggle<CR>
endif

if filereadable(expand(g:_plug_dir."/tarbar/autoload/tarbar.vim"))
	" 换为 F1
	nmap <F1> :TagbarToggle<CR>
endif
if filereadable(expand(g:_plug_dir."/emmet-vim/autoload/emmet.vim"))
	let g:user_emmet_install_global = 0
	let g:user_emmet_expandabbr_key = '<C-e>'
	autocmd FileType html,css,xml EmmetInstall
endif
" 自动闭合
if filereadable(expand(g:_plug_dir."/lexima.vim/autoload/lexima.vim"))
	let g:lexima_enable_basic_rules = 1
endif
" RGB彩色括号
if filereadable(expand(g:_plug_dir."/rainbow/autoload/rainbow.vim"))
	let g:rainbow_active = 1
endif
if filereadable(expand(g:_plug_dir."/vim-indent-guides/autoload/indent_guides.vim"))
	let g:indent_guides_enable_on_vim_startup = 1
endif

if filereadable(expand(g:_plug_dir."/vim-airline/autoload/airline.vim"))
	let g:airline_powerline_fonts = 0

	let g:airline#extensions#tabline#enabled = 1
	let g:airline#extensions#tabline#tab_nr_type = 1 " tab number
	let g:airline#extensions#tabline#formatter = 'default'
	let g:airline#extensions#tabline#show_tab_nr = 1
	let g:airline#extensions#tabline#left_sep = ' '
	let g:airline#extensions#tabline#left_alt_sep = '|'
	let g:airline#extensions#tabline#buffer_nr_show = 1

	let g:airline#extensions#whitespace#enabled = 0
	silent! call airline#extensions#whitespace#disable()

	let g:airline_theme="dark"
	if !exists('g:airline_symbols')
		let g:airline_symbols = {}
	endif

	let g:airline_symbols_ascii = 1
	let g:airline_symbols.linenr = ' r:'
	let g:airline_symbols.colnr = ' c:'
	let g:airline_symbols.dirty = 'x'
	let g:airline_symbols.readonly = '[RO]'
endif

" 这个调试插件需要配置「调试适配器, Debug Adapter, DA」以联通vimspector和实际的调试器
" 配置只需要遵循微软的 DA Protocol, DAP 就行。 
" https://microsoft.github.io/debug-adapter-protocol/overview
" '你需要创建一个 .vimspector.json 文件，放在项目的根目录中，定义你的调试配置'
"	TODO: 每次都需要手写未免过于蛋疼, 搞个自动生成吧
"  - vscode-cpptools
" - debugpy
" - vscode-java-debug
" - vscode-bash-debug
" - vscode-go
" - vscode-js-debug
" - CodeLLDB
if filereadable(expand(g:_plug_dir.'/vimspector/autoload/vimspector.vim'))
	nnoremap <leader>debug :call vimspector#Launch()<CR>
	nnoremap <leader>dR :call vimspector#Reset()<CR>
	nnoremap <leader>dc :call vimspector#Continue()<CR>
	nnoremap <Leader>dk :call vimspector#ToggleBreakpoint()<CR>
	nnoremap <Leader>dK :call vimspector#ClearBreakpoints()<CR>
	" restart 
	nmap <Leader>dr <Plug>VimspectorRestart 
	" skip
	nmap <Leader>ds <Plug>VimspectorStepOut
	" into
	nmap <Leader>di <Plug>VimspectorStepInto
	" over
	nmap <Leader>do <Plug>VimspectorStepOver
	" diassembling
	nmap <Leader>disassem	<Plug>VimspectorDisassemble 
	nmap <Leader><F11>		<Plug>VimspectorUpFrame
	nmap <Leader><F12> 		<Plug>VimspectorDownFrame
	nmap <Leader>breakp     <Plug>VimspectorBreakpoints
endif

" TOFIX: 如果在非常大的项目里面(比如下载过插件后的这个仓库的目录下)用 youcompleteme 会巨卡，
"	prompt: long latency vim youcompleteme
" 
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
endfunc

" vimscript 要求函数名首字母大写
func Config_NerdTree()
	if (winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree())
		call feedkeys(":quit\<CR>:\<BS>")
	endif
endfunc

func Ret_to_last_pos()
	if line("'\"") <= 0
		return
	endif
	let ch = "'\""
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
		return "<!-- "
	elseif &filetype == 'dosbatch'
		return ":: "
	elseif &filetype != 'rust'
		return '/// '
	else
		return '// '
	endif
endfunc

func Pad_header()
	" TODO: license name
	let license = "SPDX-LICENSE-IDENTIFIER: GPL2.0"
	let [header_comment, sign] = ['', Get_sign()]
	" addtion, comment_ed email_bracket end_of_email_bracket
	let [addt, cloz, br, ebr] = ['', '', '<', '>']

	" 难以吐槽这个python
	if (&filetype == 'sh' || &filetype == 'zsh' || &filetype == 'python')
		if &filetype == 'python'
			let &filetype = 'python3'
		endif
		let header_comment .= "#!/usr/bin/env ".&filetype."\n"
		let header_comment .= "# -*- coding: utf-8 -*-"."\n"
		if &filetype == 'python3'
			let &filetype = 'python'
		endif
	elseif (&filetype == 'xml' || &filetype == 'html')
		" xml 似乎存在尖括号冲突
		let [cloz, br, ebr] = [' -->', '{', '}']
	else
		let addt = sign."\n"
	endif
	
	let time_format = "%Y/%m/%d %A %H:%M:%S"
	let header_comment .= sign.license.cloz."\n".addt
	let header_comment .= sign."(C) All rights reserved. "
	" TODO: 别人如果要用，邮箱难道还要到这个函数里面来改吗？
	let header_comment .= "Author: ".br."kisfg@hotmail.com"
	let header_comment .= ebr." in ".strftime("%Y").cloz."\n"
	let header_comment .= sign."Created at ".strftime(time_format).cloz."\n"
	let header_comment .= sign."Last modified at ".strftime(time_format).cloz."\n"
	" TODO: 加 prompt 用于辅助构建，比如 cmake --help-command-list
	exec "normal i".header_comment | exec "normal G"
endfunc

func Update_info() 
	let [sign, payload, prefix] = [Get_sign(), strftime("%Y/%m/%d %A %H:%M:%S"), 'Last modified at ']
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
	" TODO: 似乎有光标错位的情况
	silent! %s/\s\+$//ge
	silent! %s/^$\n\+\%$//ge
endfunc

autocmd BufNewFile 
	\ *.{c[cu]\=,java,lua,[ch]pp,[ch],[hs]h,py,go,[jrt]s,html\=,xml,ya\=ml,bat,zig},makefile,CMakeLists.txt 
	\ exec "call Pad_header()"
autocmd BufWritePre,filewritepre 
	\ *.{c[cu]\=,java,lua,[ch]pp,[ch],[hs]h,py,go,[jrt]s,html\=,xml,ya\=ml,bat,zig},makefile,CMakeLists.txt 
	\ exec "call Update_info()"

" https://vim.fandom.com/wiki/Make_views_automatic
autocmd BufWinLeave * 
	\	if expand('%') != '' && &buftype !~ 'nofile'
    \|		mkview
    \|	endif
autocmd BufWinEnter,BufRead *
	\	if expand('%') != '' && &buftype !~ 'nofile'
    \|		silent loadview 
    \|	endif

" 这里来主动删掉
if filereadable(expand("$HOME/.vim/clean_vimview.py"))
	autocmd BufWritePre vimrc silent exec "!python ~/.vim/clean_vimview.py -ra true"
endif

" 返回上一次对该文件的编辑位置
autocmd BufReadPost * exec "call Ret_to_last_pos()"

" 控制何时自动加注释
let g:comment_status = 0
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

func AutoComment()
	if g:comment_status == 0
		let g:comment_status = 1
		set formatoptions+=c formatoptions+=r formatoptions+=o
		return
	endif
	let g:comment_status = 0
	set formatoptions-=c formatoptions-=r formatoptions-=o
endfunc
map <leader>comments :call AutoComment() <CR>

"" 其它内置的配置选项
filetype on
filetype plugin on
filetype indent on

" ctrl+A 为全选
map <C-A> ggVGY
" 调整窗口的映射
" TOFIX: 不过还是没有和tmux一样好用orz
map <C-W><UP> <ESC><C-W>-
map <C-W><DOWN> <ESC><C-W>+
map <C-W><LEFT> <ESC><C-W>>
map <C-W><RIGHT> <ESC><C-W><

" <leader> <=> \
nnoremap <leader>$ :term<CR>

" 上一个标签页
nnoremap <C-S-tab> :bp<CR>
" 下一个标签页
nnoremap <C-tab> :bn<CR>
" ctrl+x 关闭当前buffer
nnoremap <C-X> :bd<CR>


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
:syntax enable
:syntax on

set tabstop=4
set softtabstop=4
set shiftwidth=4
set cindent
set smartindent
" 不管如何默认用tab缩进
set noexpandtab
set autoindent

" 总是显示状态行
set laststatus=2
set completeopt-=preview
set textwidth=256

set showtabline=2
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

set selectmode=mouse,key
set t_Co=256 " 二百五十六色支持
set backspace=indent,eol,start

if has("unix")
	set guifont=Fira\ Code\ Medium\ 12,JetBrains\ Mono\ Medium\ 12
elseif has("win32") || has("win64") || has("mac")
	set guifont=Fira_Code_Medium:h12,JetBrains_Mono_Medium:h12
endif
	

set cursorline
highlight CursorLine guibg=lightgrey 
" 透明背景
highlight Normal ctermbg=none

