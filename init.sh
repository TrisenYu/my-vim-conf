#!/usr/bin/env sh
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月06日 星期日 18时04分20秒
# Last modified at 2025年07月30日 星期三 13时47分13秒
set -u

# github
raw_github='https://raw.githubusercontent.com'
main_github='https://github.com'
release_path='releases/download'
url_prefix="$main_github"

# 字体包名称
mononame="JetBrainsMono-2.304"
firaname="Fira_Code_v6.2"
lxgwname="lxgw-wenkai-v1.520"
# 这两个只有 zip
mono_zip="$mononame.zip"
fira_zip="$firaname.zip"
lxgw_zip="$lxgwname.zip"
# 有点难办
sha256_list=(
	'5ecb50e9f5aa644d0aebba93881183f0a7b9aaf829bac9dbadaf348f557e0029'
	'b9caa260fde3cb5681711f91dbfc2d6ec7ecf2fabbf92cef4432fc19c9a73816'
	'25d806b8ac55e21cddd3a1fdcbc929d3a232a1cac277ae606158824d803d2d09'
)

# 本地配置
vimdir="$HOME/.vim"
color_path="$vimdir/colors"
init_dir="$vimdir/autoload"
plugman="$init_dir/plug.vim"
fonts_dir="$HOME/.fonts/"


# TODO: 如何获取镜像主机名单？
famous_mirrors=(
	'wget.la'
	'gh-proxy.com'
	'gh.xmly.dev'
	'gh.llkk.cc'
)
main_mirror=''

# ping 所有给定的镜像站，取时长最小的一个
function _probe() {
	rtt=()
	declare -A rtt_dict
	rtt_dict=()
	for cur_mirror in ${famous_mirrors[@]}; do
		mid_rtt_val=`ping -c 2 $cur_mirror`
		echo "$mid_rtt_val"
		rtt_val=`echo $mid_rtt_val | grep '^rtt' | awk -F'/' '{ print $6 }'`
		# issue1: ping包比较小就不会携带rtt信息
		# 2 packets transmited, 0 received, ... , time 1022ms
		# issue2: ping失败后返回1触发set -e的满足条件，导致整个shellscript挂了
		if [[ "$rtt_val" == "" ]]; then
			rtt_val=`echo $mid_rtt_val | grep 'time [0-9]\+ms$' | awk -F' ' ' {print $2 } '`
		fi
		# 否则认为站点不可达
		[[ "$rtt_val" == "" ]] && rtt_val=31415926535897932384626433
		rtt+=("$rtt_val")
		[ -n "$rtt_val" ] && rtt_dict[$rtt_val]="$cur_mirror"
	done
	rtt=`printf "%s\n" ${rtt[@]} | sort -n | head -n 1 | awk -F'\n' '{ print $1 }'`
	main_mirror=${rtt_dict[$rtt]}
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
	# 在这里设置是否需要镜像源
	res="https://$main_mirror"
	url_prefix="$res/$main_github"
	raw_github="$res/$raw_github"
	echo "$res" "$url_prefix" "$raw_github"
}

# 入参:  压缩包名称 url
function _detect_font() {
	font_urls=($@)
	fontname_list=("$mononame" "$firaname" "$lxgwname")
	# op_list=('unzip' 'unzip' 'unzip')
	tar_list=("$mono_zip" "$fira_zip" "$lxgw_zip")
	for ((i=0; i<${#font_urls[@]}; i++)); do
		if [[ ${fontname_list[i]} != '' &&  -d "./${fontname_list[i]}" ]]; then
			ret=`tar -c ${fontname_list[i]} | sha256sum | awk -F' ' ' { print $1 } '`
			# 文件有而且齐全
			[[ "$ret" == ${sha256_list[i]} ]] && continue
		elif [[ -f ${tar_list[i]} ]]; then
			# 不存在但有tar/zip
			# ${op_list[i]} ${tar_list[i]} && rm ${tar_list[i]}
			unzip ${tar_list[i]} && rm ${tar_list[i]}
			continue
		fi
		# ${op_list[i]} ${tar_list[i]} && rm ${tar_list[i]}
		wget ${font_urls[i]} && unzip ${tar_list[i]} && rm ${tar_list[i]}
	done
}

function get_fonts() {
	# TODO: 如果能在这里换最新的字体也不错
	jetbrain="$url_prefix/JetBrains/JetBrainsMono/$release_path/v2.304/$mono_zip"
	firacode="$url_prefix/tonsky/FiraCode/$release_path/6.2/$fira_zip"
	lxgw="$url_prefix/lxgw/LxgwWenkai/$release_path/v1.520/$lxgw_zip"
	curr_dir=`pwd`

	# 到HOME目录
	mkdir -p "$fonts_dir" && cd "$fonts_dir"
	link_list=("$jetbrain" "$firacode" "$lxgw")
	"_detect_font" ${link_list[@]}
	fc-cache -f -v
	ret=`fc-list | grep -Ei "$lxgwname|$firaname|$mononame"`
	if [[ "$ret" == '' || "$?" != 0 ]]; then
		echo "it seems that shell script can not fetch fonts properly..."
		exit 1
	fi
	cd ..
	echo "$ret"
}

function get_color_scheme() {
	[[ -d "$color_path" && -f "$color_path/gruvbox.vim" ]] && return # 加入判断，避免重复下载
	mkdir -p "$color_path"
	wget "$raw_github/morhetz/gruvbox/master/colors/gruvbox.vim" -O "$color_path/gruvbox.vim"
}

function get_plug_manager() {
	[ -f "$plugman" ] && return # 加入判断，避免重复下载
	curl -fLo "$plugman" --create-dirs \
		 "$raw_github/junegunn/vim-plug/baa66bcf349a6f6c125b0b2b63c112662b0669e1/plug.vim"
	# 不可将以下关系合并到上面的判断
	[[ "$res" == '' ]] && return
	# 需要备份plugman，防止意外
	# 后面自己删
	cp "$plugman" "$plugman.backup"
	# 注意下面的引号
	# \ '^https://git::@github\.com', 'https://wget.la/https://github.com', '')
	sed -i "s#'$main_github#'$res#g" "$plugman"
}


# 整个shellscript的入口
# 剩下就是自己进vim里面:PlugInstall
"alter_src_via_mirror"
"get_plug_manager"
"get_color_scheme"
"get_fonts"
echo 'done...'
