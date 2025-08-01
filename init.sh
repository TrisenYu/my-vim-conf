#!/usr/bin/env sh
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月06日 星期日 18时04分20秒
# Last modified at 2025年08月02日 星期六 00时46分36秒
# 我的评价是不如直接编程
# TODO: 这么复杂的脚本居然没有getopts和help?
set -u

######################### 常量定义
# github
raw_github='https://raw.githubusercontent.com'
main_github='https://github.com'
release_path='releases/download'
url_prefix="$main_github"

# 字体包名称
mononame='JetBrainsMono-2.304'
firaname='Fira_Code_v6.2'
lxgwname='lxgw-wenkai-v1.520'
# 这两个只有 zip
mono_zip="$mononame.zip"
fira_zip="$firaname.zip"
lxgw_zip="$lxgwname.zip"
# 有点难办
sha256_list=(
	'b20a708bfe76897bd4ad1e07521c657aca8f6ad0b07c5c13a9436969fb96a6ca'
	'f80cbcaa8e827d2d0f693cc2188be746caa7d641ac7db6dece1cd49c1eec343a'
	'f8c8e678ff3856de7bad2f37e896e0811fbc9b282bd74bae7b777226bf090170'
)

# 本地配置
vimdir="$HOME/.vim"
color_path="$vimdir/colors"
init_dir="$vimdir/autoload"
plugman="$init_dir/plug.vim"
fonts_dir="$HOME/.fonts/"

plugman_hash='baa66bcf349a6f6c125b0b2b63c112662b0669e1'

# TODO: 如何获取镜像主机名单？
famous_mirrors=(
	'wget.la'
	'gh-proxy.com'
	'gh.xmly.dev'
	'gh.llkk.cc'
	'ghproxy.net'
	'ghproxy.homeboyc.cn'
)
main_mirror=''

########################################################## 函数定义
# ping 所有给定的镜像站，取时长最小的一个
function _probe() {
	rtt=()
	declare -A rtt_dict
	rtt_dict=()
	for cur_mirror in ${famous_mirrors[@]}; do
		mid_rtt_val=`ping -c 2 $cur_mirror`
		rtt_val=`\
			echo $mid_rtt_val | grep 'rtt min/avg/max/mdev = [0-9\./]\+ ms$' | \
			awk -F'/' '{ print $6 }'
		`
		# issue1: ping包比较小就不会携带rtt信息
		#	例如 2 packets transmited, 0 received, ... , time 1022ms
		# issue2: ping失败后返回1触发set -e的满足条件，导致整个shellscript挂了
		if [[ "$rtt_val" == "" ]]; then
			rtt_val=`\
				echo $mid_rtt_val | grep 'time [0-9]\+ms$' | \
				awk -F' ' ' {print $2 } ' \
			`
		fi
		# 否则认为站点不可达
		[[ "$rtt_val" == "" ]] && rtt_val=31415926535897932384626433
		rtt+=("$rtt_val")
		[ -n "$rtt_val" ] && rtt_dict[$rtt_val]="$cur_mirror"
	done
	rtt=`printf "%s\n" ${rtt[@]} | sort -n | head -n 1 | awk -F'\n' '{ print $1 }'`
	# TODO: 这种写法总能保证可以选出一个镜像站，但没有看是否可达
	# 导致后面做网络请求存在隐患
	main_mirror=${rtt_dict[$rtt]}
	unset rtt_dict
}


function alter_src_via_mirror() {
	# TODO: 自己建代理
	select obj in "mirror url" "origin url"; do
		[[ -n $obj ]] && break
	done
	# 如果本身处在gfw外就不需要用镜像源，也不需要更改plugman内的内容
	if [[ $obj == 'origin url' ]]; then
		url_prefix="$main_github"
		res="" # 这里会影响后面去下 plugman
		return
	fi
	# 在这里设置是否需要镜像源
	"_probe"
	# TODO: 如果全部失败，需要换为源下载方式
	res="https://$main_mirror"
	url_prefix="$res/$main_github"
	raw_github="$res/$raw_github"
	echo "choice: $res" "$url_prefix" "$raw_github"
}

# 入参:  压缩包名称 url
function _detect_font() {
	font_urls=($@)
	fontname_list=("$mononame" "$firaname" "$lxgwname")
	tar_list=("$mono_zip" "$fira_zip" "$lxgw_zip")
	for ((i=0; i<${#font_urls[@]}; i++)); do
		payload="$fonts_dir${fontname_list[i]}/"
		if [[ -d "$payload" ]]; then
			# 只要字典序的哈希结果
			# 这个 -df 太阴了
			ret=`\
				find "$payload" -type f | sort -df | xargs sha256sum | \
				awk -F' ' '{ printf $1"\n" }' | sha256sum | \
				awk -F' ' '{ print $1 }' \
			`
			# 文件有而且齐全
			[[ "$ret" == ${sha256_list[i]} ]] && continue
		elif [[ -f "$fonts_dir${tar_list[i]}" ]]; then
			# 不存在但有tar/zip
			mkdir -p "$payload" && cd "$payload"
			unzip ${tar_list[i]} && rm ${tar_list[i]}
			cd ..
			continue
		fi
		mkdir -p "$payload" && cd "$payload"
		# TODO: wget 改为向工作进程提交请求
		#		下载完毕后再通知这里正常执行
		wget ${font_urls[i]} && unzip ${tar_list[i]} && rm ${tar_list[i]}
		cd ..
	done
}

function get_fonts() {
	# 直接固定写死用这些版本的字体
	jetbrain="$url_prefix/JetBrains/JetBrainsMono/$release_path/v2.304/$mono_zip"
	firacode="$url_prefix/tonsky/FiraCode/$release_path/6.2/$fira_zip"
	lxgw="$url_prefix/lxgw/LxgwWenkai/$release_path/v1.520/$lxgw_zip"

	curr_dir=`pwd`
	mkdir -p "$fonts_dir" && cd "$fonts_dir"
	link_list=("$jetbrain" "$firacode" "$lxgw")
	# TODO: 此处调整为提交并发请求
	"_detect_font" ${link_list[@]}
	fc-cache -f -v
	ret=`fc-list | grep -Ei "$lxgwname|$firaname|$mononame"`
	if [[ "$ret" == '' || "$?" != 0 ]]; then
		echo "it seems that shell script can not fetch fonts properly..."
		exit 1
	fi
	cd "$curr_dir"
}


function get_color_scheme() {
	# 加入判断，避免重复下载
	[[ -d "$color_path" && -f "$color_path/gruvbox.vim" ]] && return
	mkdir -p "$color_path"
	wget "$raw_github/morhetz/gruvbox/master/colors/gruvbox.vim" \
		-O "$color_path/gruvbox.vim"
}


function get_plug_manager() {
	[ -f "$plugman" ] && return # 加入判断，避免重复下载
	curl -fLo "$plugman" --create-dirs \
		 "$raw_github/junegunn/vim-plug/$plugman_hash/plug.vim"
	# 不可将以下关系合并到上面的判断
	[[ "$res" == '' ]] && return
	# 需要备份plugman，防止意外. 后面自己删
	cp "$plugman" "$plugman.backup"
	# 注意下面的引号
	# \ '^https://git::@github\.com', 'https://wget.la/https://github.com', '')
	sed -i "s#'$main_github#'$res/$main_github#g" "$plugman"
	# TODO: cat "$plugmain" | grep -i "$res/$main_github"
}


function set_font_conf() {
	payload="\
	<!-- modified by vim-conf/init.sh at `date \"+%Y-%m-%d %H:%M:%S\"` -->
	<alias>
		<family>sans-serif</family>
   		<prefer>
			<family>Fira Code Medium</family>
			<family>LXGW WenKai Mono</family>
			<family>JetBrains Mono</family>
   		</prefer>
	</alias>\
"
	tonfpath="$HOME/.config/fontconfig"
	fontconf="$tonfpath/fonts.conf"
	if [ -f "$fontconf" ]; then
		check_dup=`\
			cat "$fontconf" | \
			grep -Ei "fira code medium|lxgw wenkai mono|jetbrains mono" \
		`
		# 不重复定义
		[[ "$check_dup" != '' ]] && return
		# 否则插入到</fontconfig>所在的上一行
		sed -i "/</fontconfig>/i\\$payload" "$fontconf"
		return
	fi
	mkdir -p "$tonfpath"
	touch "$fontconf"
	# 需要额外补充
	pre_process="\
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
<fontconfig>
</fontconfig>\
"
	echo "$pre_process" > "$fontconf"
	sed -i "/</fontconfig>/i\$payload" "$fontconf"
}

####################################################################### shellscript入口
# 剩下就是自己进vim里面:PlugInstall
# TODO: sync for mirror list
"alter_src_via_mirror"

# TODO: 并发下载
# 信号捕获正常退出
# 这里有 5  个网络请求
"get_plug_manager"
"get_color_scheme"
"get_fonts"
"set_font_conf"

# 经过color后已经创建~/.vim/目录
cp vimrc "$HOME/.vim/vimrc"
source "$HOME/.vim/vimrc"
echo 'done...'

## 计算加载插件耗时
# vim --startuptime vim.log
## TODO: 确定vim版本而决定是否需要从头开始编译
# vim --version
