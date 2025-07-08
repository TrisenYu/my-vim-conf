#!/usr/bin/env zsh
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月06日 星期日 18时04分20秒

# TODO: 当前主机探测目前给定的云服务器是否可达
# 然后自动修改 autoplug 内的 plug.vim 插件
# 没有实际的跑过，需要测一测

set -ue

# github
raw_github='raw.githubusercontent.com'
# 本地配置
color_path='~/.vim/colors'
plugman='~/.vim/autoload'

famous_servers=(
	'wget.la'
	'gh-proxy.com'
)
choice_mirror=''

# 有点奇怪，这里和下面又用raw_github
function get_color_scheme() {
	mkdir -p "$color_path" 
	wget "$raw_github"/morhetz/gruvbox/master/colors/gruvbox.vim -O "$color_path/gruvbox.vim"
	return
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
	choice_mirror=${rtt_dict["$rtt"]}
	unset rtt_dict
}


function alter_src_via_mirror() {
	proto='https://'
	"probe"
	res="$proto$choice_mirror/https://github.com"
	#        \ '^https://git::@github\.com', 'https://wget.la/https://github.com', '')
	# 注意下面的引号
	sed -i "s#'https://github.com#'$res" "$plugman"
}


# TODO: 加入一个失败选镜像站重做的逻辑
function get_plug_manager() {
	curl -fLo "$plugman/plug.vim" --create-dirs \
		 "https://$raw_github/junegunn/vim-plug/master/plug.vim" 
}

"get_plug_manager"
"get_color_scheme"
"alter_src_via_mirror"
# 剩下就是自己进vim里面:PlugInstall
