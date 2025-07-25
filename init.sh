#!/usr/bin/env zsh
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月06日 星期日 18时04分20秒
# Last modified at 2025年07月25日 星期五 17时33分02秒
set -e

# github
raw_github='https://raw.githubusercontent.com'
main_github='https://github.com'
release_path='release/download'

# 字体包名称
mono_zip="JetBrainsMono-2.304.zip"
fira_zip="Fira_Code_v6.2.zip"
lxgw_zip="lxgw-wenkai-v1.520.zip"

# 本地配置
vimdir="$HOME/.vim"
color_path="$vimdir/colors"
init_dir="$vimdir/autoload"
plugman="$init_dir/plug.vim"
fonts_dir="$vimdir/fonts/"

url_prefix="$main_github"
# TODO: 如何获取镜像主机名单？
famous_servers=(
	'wget.la'
	'gh-proxy.com'
	'gh.xmly.dev'
)
main_mirror=''



# ping 所有给定的镜像站，取时长最小的一个
function _probe() {
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
		[[ -n $obj ]] && break
	done
	# 如果本身处在gfw外就不需要用镜像源，也不需要更改plugman内的内容
	if [[ $obj == 'origin url' ]]; then
		url_prefix="$main_github"
		res="" # 这里会影响后面去下 plugman
		return
	fi

	"_probe"
	res="https://$main_mirror"
	url_prefix="$res/$main_github"
	raw_github="$res/$raw_github"
}

# 入参: 字体文件夹名称 压缩包名称 url
function _detect_font() {
	fira_code_zip_sha256="0949915ba8eb24d89fd93d10a7ff623f42830d7c5ffc3ecbf960e4ecad3e3e79"
	mono_zip_sha256="6f6376c6ed2960ea8a963cd7387ec9d76e3f629125bc33d1fdcd7eb7012f7bbf"
	# TODO: 关键在于怎么根据已有的文件来计算匹配这些哈希
	#		有具体的文件也不下载，直接退出
	cd "$1"
	ls "./$2"
	if [[ $? != 0 ]]; then
		wget "$3"
	fi
	unzip "$mono_zip" && rm "$mono_zip"
	cd ..
}

function get_fonts() {
	# TODO: 如果能在这里换最新的字体也不错
	jetbrain="$url_prefix/JetBrains/JetBrainsMono/$release_path/v2.304/$mono_zip"
	firacode="$url_prefix/tonsky/FiraCode/$release_path/6.2/$fira_zip"
	lxgw="$url_prefix/lxgw/LxgwWenkai/$release_path/v1.520/$lxgw_zip"
	curr_dir=`pwd`
	mkdir -p "$fonts_dir"
	cd "$fonts_dir" && mkdir -p 'JetBrains' 'FiraCode' 'lxgw'
	# TODO: 更改为_detect_font() 函数
	cd 'JetBrains' && wget "$jetbrain" && unzip "$mono_zip" && rm "$mono_zip" && cd ..
	cd 'FiraCode' && wget "$firacode" && unzip "$fira_zip" && rm "$fira_zip" && cd ..
	cd 'lxgw' && wget "$lxgw" && unzip "$lxgw_zip" && rm "$lxgw_zip" && cd ..
	# 最后刷新字体
	fc-cache -fv # | tee -a './tmp.log'
	cd "$curr_dir"
}

function get_color_scheme() {
	mkdir -p "$color_path"
	wget "$raw_github/morhetz/gruvbox/master/colors/gruvbox.vim" -O "$color_path/gruvbox.vim"
}


function get_plug_manager() {
	curl -fLo "$plugman" --create-dirs \
		 "$raw_github/junegunn/vim-plug/baa66bcf349a6f6c125b0b263c112662b0669e1/plug.vim"
	if [[ "$res" != '' ]]; then
		# 需要备份plugman，防止意外
		cp "$plugman" "$plugman.backup"
		# 注意下面的引号
		# \ '^https://git::@github\.com', 'https://wget.la/https://github.com', '')
		sed -i "s#'$main_github#'$res#g" "$plugman"
	fi
}


# 整个shellscript的入口
# 剩下就是自己进vim里面:PlugInstall
"alter_src_via_mirror"
"get_plug_manager"
"get_color_scheme"
"get_fonts"
echo 'done...'
