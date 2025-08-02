#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月06日 星期日 18时04分20秒
# Last modified at 2025年08月03日 星期日 00时37分21秒
# 我的评价是不如直接编程
# TODO: 这么复杂的脚本居然没有getopts?
set -u

######################### 常量定义
# github
raw_github='https://raw.githubusercontent.com'
main_github='https://github.com'
res_mirror=''
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
fonts_dir="$HOME/.fonts/"
color_path="$vimdir/colors"
init_dir="$vimdir/autoload"
vim_target="$vimdir/vimrc"
plugman="$init_dir/plug.vim"

curr_dir=`pwd`
vimrc_hash=`sha256sum "$curr_dir/vimrc"`
color_schash='040138616bec342d5ea94d4db296f8ddca17007a'
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

########################################################## 函数定义
function help() {
	cat << END_OF_LINE
辅助配置vim的shellscript
END_OF_LINE
}

# ping 所有给定的镜像站，取时长最小、丢包数最小的一个
function _probe() {
	mirr_str=""
	for cur_mirr in ${famous_mirrors[@]}; do
		# TODO: ping的次数搞成配置 ping也并发
		mid_rtt_val=`ping -c 2 $cur_mirr`
		loss_rate=`echo "$mid_rtt_val" | grep -oP '([0-9\.]+)(?=% packet loss)'`
		rtt_val=`\
			echo "$mid_rtt_val" | grep 'rtt min/avg/max/mdev = [0-9\./]\+ ms$' | \
			awk -F'/' '{ print $6 }'
		`
		# issue1: ping包比较小就不会携带rtt信息
		#	例如 2 packets transmited, 0 received, 100% packet loss , time 1022ms
		# issue2: ping失败后返回1触发set -e的满足条件，导致整个shellscript挂了
		if [[ "$rtt_val" == "" ]]; then
			rtt_val=`echo "$mid_rtt_val" | grep -o ' [0-9\.]\+ms$' | awk -F'ms' '{ print $1 }'`
			rtt_val=`echo "scale=6;$rtt_val/2" | bc`
		fi
		# 否则认为站点不可达
		[[ "$rtt_val" == "" ]] && rtt_val=31415926535897932384626433
		mirr_str+="$cur_mirr,$rtt_val,$loss_rate\n"
	done
	# 策略:
	#	时间小的优先
	# 	时间一致的前提下选丢包率靠近零的
	mirror_tbl=(`echo -e "${mirr_str:0:-2}" | sort -n -t ' ' -k2 -k3 | tr -n "\n" ' '`)
	mirr_check=`echo -e "$mirror_tbl" | awk -F' ' '{ print $3 }' | head -n 1`
	choice_rec=31415926535897932384626433
	for item in ${mirror_tbl[@]}; do
		curr_mirr=(`echo "$item" | tr ',' ' '`)
		mirr_check=${curr_mirr[2]}
		mirr_speed=${curr_mirr[1]}
		[[ "$mirr_check" -ge 90 ]] && continue
		if [[ "$choice_rec" -gt "$mirr_speed" ]]; then
			choice_rec="$mirr_speed"
			res_mirror=${curr_mirr[0]}
		fi
	done
	unset rtt_dict mirr_str mirror_tbl mirr_check choice_rec
}


function alter_src_via_mirror() {
	# TODO: 或者自己建代理
	select obj in "mirror url" "origin url"; do
		[[ -n $obj ]] && break
	done
	# 如果本身处在gfw外就不需要用镜像源，也不需要更改plugman内的内容
	if [[ "$obj" == 'origin url' ]]; then
		res_mirror="" # 这里会影响后面去下 plugman
		return
	fi
	# 在这里设置是否需要镜像源
	"_probe"
	[[ "$res_mirror" == '' ]] && return
	res_mirror="https://$res_mirror"
	url_prefix="$res_mirror/$main_github"
	raw_github="$res_mirror/$raw_github"
	echo "choice: $res_mirror" "$url_prefix" "$raw_github"
}

# 入参:  压缩包名称 url
function _detect_font() {
	mkdir -p "$fonts_dir" && cd "$fonts_dir"
	font_urls=($@)
	fontname_list=("$mononame" "$firaname" "$lxgwname")
	tar_list=("$mono_zip" "$fira_zip" "$lxgw_zip")
	for ((i=0; i<${#font_urls[@]}; i++)); do
		payload="$fonts_dir${fontname_list[i]}/"
		function unzipper() {
			unzip "${tar_list[i]}" -d "$payload"
			rm ${tar_list[i]} && unset payload
			cd ..
		}

		if [[ -d "$payload" ]]; then
			# 只要字典序的哈希结果，这个 -df 太阴了
			ret=`\
				find "$payload" -type f | sort -df | xargs sha256sum | \
				awk -F' ' '{ printf $1"\n" }' | sha256sum | \
				awk -F' ' '{ print $1 }' \
			`
			# 文件有而且齐全
			[[ "$ret" == "${sha256_list[i]}" ]] && continue
		elif [[ -f "$fonts_dir${tar_list[i]}" ]]; then
			# 不存在但有tar/zip
			# 这里可以并行着做啊
			{"unzipper"}&
		fi
		{
			wget "${font_urls[i]}" &> /dev/null
			"unzipper"
		}&
	done
	wait
	cd "$curr_dir"
}

function get_fonts() {
	# 直接固定写死用这些版本的字体
	jetbrain="$url_prefix/JetBrains/JetBrainsMono/$release_path/v2.304/$mono_zip"
	firacode="$url_prefix/tonsky/FiraCode/$release_path/6.2/$fira_zip"
	lxgw="$url_prefix/lxgw/LxgwWenkai/$release_path/v1.520/$lxgw_zip"
	link_list=("$jetbrain" "$firacode" "$lxgw")

	"_detect_font" ${link_list[@]}
	fc-cache -fv
	ret=`fc-list | grep -Ei "$lxgwname|$firaname|$mononame"`
	if [[ "$ret" == '' || $? != 0 ]]; then
		echo "it seems that shell script can not fetch fonts properly..."
		exit 1
	fi
}


function get_color_scheme() {
	# 加入判断，避免重复下载
	[[ -d "$color_path" && -f "$color_path/gruvbox.vim" ]] && return
	{
		wget -P "$color_path" \
			"$raw_github/morhetz/gruvbox/$color_schash/colors/gruvbox.vim" &> /dev/null
	}&
}


function get_plug_manager() {
	[ -f "$plugman" ] && return # 加入判断，避免重复下载
	{
		wget -P "$init_dir" \
			"$raw_github/junegunn/vim-plug/$plugman_hash/plug.vim" &> /dev/null
		[[ "$res_mirror" == '' ]] && return
		cp "$plugman" "$plugman.backup"
		# 不可将以下关系合并到上面的判断
		# 需要备份plugman，防止意外. 后面自己删
		# 注意下面的引号
		# \ '^https://git::@github\.com', 'https://wget.la/https://github.com', '')
		sed -i "s#'$main_github#'$url_prefix#g" "$plugman"
	}&
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
		# issue:
		sed -i "/<\\/fontconfig>/i\\$payload" "$fontconf"
		return
	fi
	mkdir -p "$tonfpath" && touch "$fontconf"
	# 需要额外补充
	pre_process="\
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
<fontconfig>
$payload
</fontconfig>\
"
	echo "$pre_process" > "$fontconf"
}

####################################################################### shellscript入口
# 准备创建管道文件
# trap oops SIGINT SIGILL
# 剩下就是自己进vim里面:PlugInstall
# TODO: sync for mirror list
"alter_src_via_mirror"
"get_plug_manager"
"get_color_scheme"
"get_fonts"
"set_font_conf"

## TODO: 确定vim版本而决定是否需要从头开始编译，并编写可用的编译脚本
# vim --version

if [[ ! -s "$vim_target" || `cat "$vim_target" | sha256sum` != "$vimrc_hash" ]]; then
	# 经过color后已经创建~/.vim/目录
	cp "$curr_dir/vimrc" "$vimdir/vimrc"
	vim -u "$vimdir/vimrc" +PlugInstall! +wa! &> /dev/null
fi
echo 'done...'

## 计算加载插件耗时
# vim --startuptime vim.log

