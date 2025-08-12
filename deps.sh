#!/usr/bin/env sh
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月22日 星期二 15时40分07秒
# Last modified at 2025年08月10日 星期日 01时05分53秒

pkg_man=''
_update=''
_search=''
_append=''
_upgrad=''
_remove=''
arch=`uname -m`

function check_packman() {
	if command -v apt-get &> /dev/null; then
		# Debian
		pkg_man="apt-get"
		_update='update'
		_upgrad='upgrade'
		_search='search'
		_append='install'
		_remove='remove'
	elif command -v yum &> /dev/null; then
		pkg_man="yum"
		_update='update'
		_upgrad='upgrade'
		_search='search'
		_append='install'
		_remove='remove'
	elif command -v pacman &> /dev/null; then
		# arch
		pkg_man="pacman"
		_update='-Syy'
		_upgrad=''
		_search='-Q'
		_append='-Syy'
		_remove='-r'
	elif command -v dnf &> /dev/null; then
		pkg_man="dnf"
		# TODO: 没用过
	else
		echo "unable to find package manager!"
		exit 1
	fi
	echo "$pkg_man is the package manager currently used in this linux release"
}

# 安装一些必要的软件
function install_deps() {
	# 凡事先更新
	# TODO: 需要保证是root权限
	`$pkg_man $_update`
	`$pkg_man $_append cmake make python wget curl zsh git llvm`
	`$pkg_man $_append fctix5-mozc fctix5`
	# 还有网络之类的软件
	# 应该马上视情况安装 oh-my-zsh
}

function setup_input_meth() {
	# TODO: 如果找不到再去做这个操作
	payload="GTK_IM_MODULE=fcitx\nQT_IM_MODULE=fcitx\nXMODIFIERS=@im=fcitx\n"
	echo -e "$payload" >> "$HOME/.zshrc"
}

function setup_shell() {
	chsh -s `which zsh`
	git clone --depth=1 https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh
	cd ./ohmyzsh/tools
	REMOTE=https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git
	sh install.sh
	cd ..
	# 卸磨杀驴
	rm -rf ./ohmyzsh
}

function setup_golang {
	# TODO
	curl https://github.com/golang/go/releases
}

function setup_nodejs() {
	# TODO
	curl https://nodejs.org/en/download/current
}

# shellscript 的入口
"check_os"
"check_packman"

"install_deps"
"setup_shell"
"setup_golang"
