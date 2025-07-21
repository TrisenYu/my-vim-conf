#!/usr/bin/env zsh
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月06日 星期日 18时04分20秒
# Last modified at 2025年07月22日 星期二 01时01分35秒

#
# TODO: 当前主机探测目前给定的云服务器是否可达
# 然后自动修改 autoplug 内的 plug.vim 插件
# 没有实际的跑过，需要测一测
#
set -ue

# github
raw_github='raw.githubusercontent.com'
main_github='https://github.com'
# 本地配置
vimdir="$HOME/.vim"
color_path="$vimdir/colors"
plugman="$vimdir/autoload"
fonts_dir="$vimdir/fonts/"

url_prefix="$main_github"
famous_servers=(
	'wget.la'
	'gh-proxy.com'
)
main_mirror=''

# 有点奇怪，这里和下面又用raw_github
# TODO: 在国外的设备就不需要替换为镜像站，但需要提供参数显示说明
function get_color_scheme() {
	mkdir -p "$color_path"
	wget "$raw_github/morhetz/gruvbox/master/colors/gruvbox.vim" -O "$color_path/gruvbox.vim"
}


# ping 所有给定的镜像站，取时长最小的一个
function probe() {
	rtt=()
	declare -A rtt_dict
	rtt_dict=()
	for cur_mirror in ${famous_servers[@]}; do
		rtt_val=`ping -c 2 $cur_mirror  | grep '^rtt' | awk -F'/' '{ print $6 }'`
		rtt+=($rtt_val)
		rtt_dict["$rtt_val"]="$cur_mirror"
	done
	rtt=`printf "%s\n" ${rtt[@]} | sort -n | head -n 1 | awk -F'\n' '{ print $1 }'`
	main_mirror=${rtt_dict["$rtt"]}
	unset rtt_dict
}


function alter_src_via_mirror() {
	select obj in "mirror url" "origin url"; do
		if [[ -n $obj ]]; then
			break
		fi
	done
	if [[ $obj == '2' ]]; then
		url_prefix="$main_github"
		return
	fi
	"probe"
	res="https://$main_mirror"
	# \ '^https://git::@github\.com', 'https://wget.la/https://github.com', '')
	# 需要备份，防止意外
	mv "$plugman" "$plugman.backup"
	# 注意下面的引号
	sed -i "s#'$main_github#'$res#g" "$plugman"
	url_prefix="$res/$main_github"
}

function get_fonts() {
	# TODO: 如果能在这里换最新的字体也不错
	jetbrain="$url_prefix/JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip"
	firacode="$url_prefix/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip"
	curr_dir=`pwd`
	mkdir -p "$fonts_dir"
	cd "$fonts_dir" && mkdir -p 'JetBrains' 'FiraCode'
	# TODO: 如果有就不要下
	cd 'JetBrains' && wget "$jetbrain" && tar -xf 'JetBrainsMono-2.304.zip' && cd ..
	cd 'FiraCode' && wget "$firacode" && tar -xf 'Fira_Code_v6.2.zip' && cd ..
	# TODO: 压缩包解压没问题以后直接删掉
	# 最后刷新字体
	fc-cache -fv # | tee -a './tmp.log'
	# cat 'tmp.log' | grep -ic 'Fira Code'
	cd "$curr_dir"
}

function get_plug_manager() {
	curl -fLo "$plugman/plug.vim" --create-dirs \
		 "https://$raw_github/junegunn/vim-plug/master/plug.vim"
}

function set_up_config() {
	# TODO: 下面两个都用rawgithub
	"get_plug_manager"
	"get_color_scheme"
	# TODO: 镜像源是否需要的检查 应该一开始就做了
	"get_fonts"
	echo 'done...'
}

# 整个shellscript的入口
"alter_src_via_mirror"
"set_up_config"
# 剩下就是自己进vim里面:PlugInstall
