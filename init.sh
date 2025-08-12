#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月06日 星期日 18时04分20秒
# Last modified at 2025年08月12日 星期二 22时19分31秒
#
# 我的评价是不如直接编程
# TODO: 这么复杂的脚本居然没有getopts?
#		感觉过于繁琐，还要在shellscript内验参
set -u

######################### 常/变量定义

# 本地配置
curr_dir=`pwd`
vimdir="$HOME/.vim"
fonts_dir="$HOME/.fonts/"
color_path="$vimdir/colors"
init_dir="$vimdir/autoload"
ycm_dir="$vimdir/plugged/YouCompleteMe/"
vim_target="$vimdir/vimrc"
plugman="$init_dir/plug.vim"

ping_dev='mdev'
font_key=false
gsed='sed'
# file-hash
vimrc_hash=`sha256sum "$curr_dir/vimrc" | awk -F' ' '{ print $1 }'`
# github
raw_github='https://raw.githubusercontent.com'
main_github='https://github.com'
res_mirror=''
release_path='releases/download'
url_prefix="$main_github"
vim_src_suf="vim/vim.git"

# 字体包名称
mononame='JetBrainsMono-2.304'
firaname='Fira_Code_v6.2'
lxgwname='lxgw-wenkai-v1.520'
maplname='MapleMonoNormal-TTF'
# TODO: 要不直接附在这个仓库作为assets算了
mono_zip="$mononame.zip"
fira_zip="$firaname.zip"
lxgw_zip="$lxgwname.zip"
mapl_zip="$maplname.zip"
sha256_list=(
	'b20a708bfe76897bd4ad1e07521c657aca8f6ad0b07c5c13a9436969fb96a6ca'
	'f80cbcaa8e827d2d0f693cc2188be746caa7d641ac7db6dece1cd49c1eec343a'
	'f8c8e678ff3856de7bad2f37e896e0811fbc9b282bd74bae7b777226bf090170'
	'62bf9761500e1a09753c06cbfd1cd9057904b61ea4a2a590d09b7fc7cb108d31'
)

# git-commit-hash
color_schash='040138616bec342d5ea94d4db296f8ddca17007a'
plugman_hash='baa66bcf349a6f6c125b0b2b63c112662b0669e1'
past_inihash='5521a1922785c852707e40303d6394d4044caf83'

# TODO: 如何获取镜像主机名单？
famous_mirrors=(
	'gh-proxy.com'
	'gh-proxy.net'
	'gh.xmly.dev'
	'gh.llkk.cc'
	'ghproxy.net'
	'ghproxy.homeboyc.cn'
	'wget.la'
	# https://cdn.jsdelivr.net/gh/ github-repository-suffix
)

########################################################## 函数定义
function help() {
	cat << END_OF_LINE
辅助配置vim的shellscript
END_OF_LINE
}

# TODO: 搞成配置
ping_times=3
inf_val=31415926535897932384626433
get_self="$raw_github/TrisenYu/my-vim-conf/$past_inihash/init.sh"

# ping 所有给定的镜像站，取时长最小、丢包数最小的一个
function _probe() {
	mirr_str=""
	tot_ping=0
	tot_wget=0
	for cur_mirr in ${famous_mirrors[@]}; do
		# TODO: ping和wget也并发
		mid_rtt_val=`ping -c $ping_times $cur_mirr`
		[[ "$?" != 0 ]] && continue
		loss_rate=`echo "$mid_rtt_val" | grep -oP '([0-9\.]+)(?=% packet loss)'`
		rtt_val=`\
			echo "$mid_rtt_val" | grep " min/avg/max/$ping_dev = [0-9\\./]\\+ ms\$" | \
			awk -F'/' '{ print $6 }'
		`
		if [[ "$rtt_val" == "" ]]; then
			rtt_val=`\
				echo "$mid_rtt_val" | grep -o ' [0-9\.]\+ms$' | \
				awk -F'ms' '{ print $1 }'\
			`
			[[ "$rtt_val" != "" ]] && rtt_val=`echo "scale=6;$rtt_val/$ping_times" | bc`
		fi
		# 否则认为站点不可达
		[[ "$rtt_val" == "" ]] && rtt_val=$inf_val

		st_time=`date +%s.%N`
		wget "https://$cur_mirr/$get_self" -O - &> /dev/null
		ret_num=$?
		ed_time=`date +%s.%N`
		interval=`echo "scale=9; $ed_time-$st_time" | bc`
		[[ "$ret_num" != 0 ]] && loss_rate=100
		mirr_str+="$cur_mirr,$interval,$rtt_val,$loss_rate\n"
		tot_wget=`echo "$tot_wget+$interval" | bc`
		tot_ping=`echo "$tot_ping+$rtt_val" | bc`
	done
	[[ "mirr_str" == "" ]] && return
	mirror_tbl=(`echo -e "${mirr_str:0:-2}" | sort -n -t ' ' -k2 -k3 -k4 | tr "\n" ' '`)
	mirr_check=`echo -e "$mirror_tbl" | awk -F' ' '{ print $3 }' | head -n 1`
	choice_val=0
	for item in ${mirror_tbl[@]}; do
		curr_mirr=(`echo "$item" | tr ',' ' '`)
		conn_score=${curr_mirr[3]}
		ping_val=${curr_mirr[2]}
		wget_val=${curr_mirr[1]}
		[[ "$conn_score" -ge 90 ]] && continue
		mid_val=`echo "scale=2; $wget_val/$tot_wget*0.7+0.3*$ping_val/$tot_ping" | bc`
		if [[ "$choice_val" -lt "$mid_val" ]]; then
			choice_val="$mid_val"
			res_mirror="${curr_mirr[0]}"
		fi
	done
	unset rtt_dict mirr_str mirror_tbl mirr_check choice_rec
}


function alter_src_via_mirror() {
	# TODO: 或者自己建代理
	select obj in 'mirror url' 'origin url'; do
		[[ -n $obj ]] && break
	done
	select can_get_font in 'need fonts' 'not need'; do
		[[ -n $can_get_font ]] && break
	done
	if [[ "$can_get_font" == 'need fonts' ]]; then
		font_key=true
	fi
	# 如果本身处在gfw外就不需要用镜像源，也不需要更改plugman内的内容
	if [[ "$obj" == 'origin url' ]]; then
		res_mirror=""
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
	fontname_list=("$mononame" "$firaname" "$lxgwname" "$maplname")
	tar_list=("$mono_zip" "$fira_zip" "$lxgw_zip" "$mapl_zip")
	for ((i=0; i<${#font_urls[@]}; i++)); do
		payload="$fonts_dir${fontname_list[i]}/"
		function unzipper() {
			unzip "${tar_list[i]}" -d "$payload" &> /dev/null
			rm ${tar_list[i]} && unset payload
			cd ..
		}

		if [[ -d "$payload" ]]; then
			# 只要字典序的哈希结果，这个 -df 太阴了
			ret=`\
				find "$payload" -type f | sort -df | \
				xargs sha256sum | awk -F' ' '{ printf $1"\n" }' | \
				sha256sum | awk -F' ' '{ print $1 }' \
			`
			# 文件有而且齐全
			[[ "$ret" == "${sha256_list[i]}" ]] && continue
		elif [[ -f "$fonts_dir${tar_list[i]}" ]]; then
			# 不存在但有tar/zip
			{"unzipper"}&
			continue
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
	mapl="$url_prefix/subframe7536/maple-font/$release_path/v7.5/$mapl_zip"
	link_list=("$jetbrain" "$firacode" "$lxgw" "$mapl")

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
		echo "fetch color_scheme..."
		# TODO: cdn.jsdelivr.net/gh 下
		# raw-github的形式：https://cdn.jsdelivr.net/gh/morhetz/gruvbox@master/colors/gruvbox.vim
		wget -P "$color_path" \
			"$raw_github/morhetz/gruvbox/$color_schash/colors/gruvbox.vim" &> /dev/null
	}&
}


function get_plug_manager() {
	[ -f "$plugman" ] && return # 加入判断，避免重复下载
	{
		echo "fetch plugin_manager..."
		wget -P "$init_dir" \
			"$raw_github/junegunn/vim-plug/$plugman_hash/plug.vim" &> /dev/null
		[[ "$res_mirror" == '' ]] && return
		cp "$plugman" "$plugman.backup"
		# 不可将以下关系合并到上面的判断
		# 需要备份plugman，防止意外. 后面自己删
		# 注意下面的引号
		# \ '^https://git::@github\.com', 'https://wget.la/https://github.com', '')
		$gsed -i "s#'$main_github#'$url_prefix#g" "$plugman"
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
		$gsed -i "/<\\/fontconfig>/i\\$payload" "$fontconf"
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


function _clone_vim_src() {
	# 感觉最好是替换掉
	# deps: ruby-dev lua libperl-dev python3 python3-dev
	git clone --depth=2 --recursive "$url_prefix/$vim_src_suf" "$HOME/.vim-src"
	cd "$HOME/.vim-src"
	# TODO: 既然要装个新的，最好是覆盖整个系统的
	./configure \
		--with-features=huge \
		--prefix="$HOME/app/vim" \
		--enable-fail-if-missing \
		--enable-python3interp \
		--enable-fontset \
		--enable-rubyinterp \
		--enable-perlinterp \
		--with-python3-command=python3
	make && make install
}

function setup_ycm() {
	# 需要 cmake
	cd "$ycm_dir"
	git submodule update --init --recursive
	python3 ./install.py
}

function _cp_vimrc() {
	vim_ver=`vim --version | grep -oP '(?<=VIM - Vi IMproved )([0-9\.]+)'`
	if [[ "$vim_ver" < 9 ]]; then
		# TODO:
		# "_clone_vim_src"
		echo 'need clone and compile...'
		return
	fi
	cp "$curr_dir/vimrc" "$vim_target"
	cp "$curr_dir/clean_vimview.py" "$vimdir/clean_vimview.py"
	vim -u "$vim_target" +PlugInstall! +wa!
	"setup_ycm"
}


function check_sys() {
	# linux: GNU/Linux
	if [[ "`uname -o`" == "Darwin" ]]; then
		ping_dev='stddev'
		gsed='gsed'
	fi
}
####################################################################### shellscript入口
# 准备创建管道文件
# TODO: auto sync for mirror list
"check_sys"
"alter_src_via_mirror"
"get_plug_manager"
"get_color_scheme"

if [[ "$font_key" = true ]]; then
	"get_fonts"
	"set_font_conf"
else
	$gsed -i 's/set guifont=/" set guifont=/g' "$curr_dir/vimrc"
	# 重算
	vimrc_hash=`sha256sum "$curr_dir/vimrc" | awk -F' ' '{ print $1 }'`
fi

## TODO: 确定vim版本而决定是否需要从头开始编译，并编写可用的编译脚本
# vim --version
# arch
#	sudo pacman -Rsn vi vim-tiny vim vim-runtime gvim vim-common vim-gui-common vim-nox
# debian
#	sudo apt-get remove --purge vi vim-tiny vim vim-runtime gvim vim-common vim-gui-common vim-nox

if [[ -s "$vim_target" ]]; then
	# 经过color后已经创建~/.vim/目录
	calc_hash=`cat "$vim_target"|sha256sum|awk -F' ' '{print $1}'`
	[[ "$calc_hash" != "$vimrc_hash" ]] && "_cp_vimrc"
else
	"_cp_vimrc"
fi

echo 'done...'

## 计算加载插件耗时
# vim --startuptime vim.log
