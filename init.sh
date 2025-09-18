#!/usr/bin/env bash
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月06日 星期日 18时04分20秒
# Last modified at 2025/09/19 星期五 14:47:17
#
# 我的评价是不如直接编程
# TODO: 这么复杂的脚本居然没有getopts?
#		感觉过于繁琐，还要在shellscript内验参
#		出现异常后处理异常、评估仍能保留的下载文件，清理不完整的部件并终止执行
set -u
declare has_been_called=""

######################### 常/变量定义

# 本地配置
declare curr_dir=`pwd`
declare vimdir="$HOME/.vim"
declare fonts_dir="$HOME/.fonts/"
declare color_path="$vimdir/colors"
declare plug_dir="$vimdir/plugged"
declare init_dir="$vimdir/autoload"

declare vim_target="$vimdir/vimrc"
declare plugman="$init_dir/plug.vim"

declare ycm_dir="$plug_dir/YouCompleteMe/"
declare vimspector_dir="$plug_dir/vimspector"

declare ping_dev='mdev'
declare font_key=false

declare gsed='sed'
declare ggrep='grep'

# file-hash
declare vimrc_hash=`sha256sum "$curr_dir/vimrc" | awk -F' ' '{ print $1 }'`
# github
declare raw_github='https://raw.githubusercontent.com'
declare main_github='https://github.com'
declare res_mirror=''
declare release_path='releases/download'
declare url_prefix="$main_github"
declare vim_src_suf="vim/vim.git"

# 字体包名称
declare mononame='JetBrainsMono-2.304'
declare firaname='Fira_Code_v6.2'
declare lxgwname='lxgw-wenkai-v1.520'
declare maplname='MapleMonoNormal-TTF'
# TODO: 要不直接附在这个仓库作为assets算了
declare mono_zip="$mononame.zip"
declare fira_zip="$firaname.zip"
declare lxgw_zip="$lxgwname.zip"
declare mapl_zip="$maplname.zip"
declare -A sha256_list=(
	'b20a708bfe76897bd4ad1e07521c657aca8f6ad0b07c5c13a9436969fb96a6ca'
	'f80cbcaa8e827d2d0f693cc2188be746caa7d641ac7db6dece1cd49c1eec343a'
	'f8c8e678ff3856de7bad2f37e896e0811fbc9b282bd74bae7b777226bf090170'
	'62bf9761500e1a09753c06cbfd1cd9057904b61ea4a2a590d09b7fc7cb108d31'
)

# git-commit-hash
declare color_schash='040138616bec342d5ea94d4db296f8ddca17007a'
declare plugman_hash='baa66bcf349a6f6c125b0b2b63c112662b0669e1'
declare past_inihash='5521a1922785c852707e40303d6394d4044caf83'

# TODO: 如何自动获取镜像主机名单？
declare -A famous_mirrors=(
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
declare ping_times=3
declare inf_val=31415926535897932384626433
declare get_self="$raw_github/TrisenYu/my-vim-conf/$past_inihash/init.sh"

# 通过 ping 和实际wget来测试所有给定的镜像站，
# 取时长最小、丢包数最小的一个
function _probe() {
	declare mirr_str=""
	declare tot_ping=0
	declare tot_wget=0
	for cur_mirr in ${famous_mirrors[@]}; do
		# TODO: ping和wget也做并发
		# 但要上数量控制、互斥保护还有异常kill
		declare mid_rtt_val=`ping -c $ping_times $cur_mirr`
		[[ "$?" != 0 ]] && continue
		declare loss_rate=`echo "$mid_rtt_val" | $ggrep -oP '([0-9\.]+)(?=% packet loss)'`
		declare rtt_val=`\
			echo "$mid_rtt_val" | $ggrep " min/avg/max/$ping_dev = [0-9\\./]\\+ ms\$" | \
			awk -F'/' '{ print $6 }'
		`
		if [[ "$rtt_val" == "" ]]; then
			rtt_val=`\
				echo "$mid_rtt_val" | grep -oP ' ([0-9\.]+)ms$' | \
				awk -F'ms' '{ print $1 }'\
				`
			if [[ "$rtt_val" != '' ]]; then
				rtt_val=`echo "scale=6;$rtt_val/$ping_times" | bc`
			else
				# 否则认为站点不可达
				rtt_val=$inf_val
			fi
		fi

		declare st_time=`date +%s.%N`
		wget "https://$cur_mirr/$get_self" -O - &> /dev/null
		declare ret_num=$?
		declare ed_time=`date +%s.%N`
		declare interval=`echo "scale=9; $ed_time-$st_time" | bc`
		[[ "$ret_num" != 0 ]] && loss_rate=100
		mirr_str+="$cur_mirr,$interval,$rtt_val,$loss_rate\\n"
		tot_wget=`echo "$tot_wget+$interval" | bc`
		tot_ping=`echo "$tot_ping+$rtt_val" | bc`
	done
	[[ "$mirr_str" == "" ]] && return
	declare -A mirror_tbl=(`echo -e "${mirr_str:0:-2}" | sort -nt ' ' -k2 -k3 -k4 | tr "\n" ' '`)
	declare mirr_check=`echo -e "$mirror_tbl" | awk -F' ' '{ print $3 }' | head -n 1`
	declare choice_val=0
	for item in ${mirror_tbl[@]}; do
		declare curr_mirr=($(echo "$item" | tr ',' ' '))
		declare conn_score=${curr_mirr[3]}
		declare ping_val=${curr_mirr[2]}
		declare wget_val=${curr_mirr[1]}
		[[ $(echo "$conn_score > 90" | bc) -eq 1 ]] && continue
		# 当然是越低越好
		declare calc_expr="(1.0-$wget_val/$tot_wget)*0.7+0.3*(1.0-$ping_val/$tot_ping)"
		declare mid_val=`echo "scale=2; $calc_expr" | bc`
		if [[ `echo "$mid_val" | cut -c 1` == '.' ]]; then
			mid_val="0$mid_val"
		fi
		if [[ $(echo "$choice_val < $mid_val" | bc) -eq 1 ]]; then
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
	echo "choice after evaluation: $res_mirror" "$url_prefix" "$raw_github"
}


# 入参:  压缩包名称 url
function _detect_font() {
	mkdir -p "$fonts_dir" && cd "$fonts_dir"
	declare -A font_urls=($@)
	declare -A fontname_list=("$mononame" "$firaname" "$lxgwname" "$maplname")
	declare -A tar_list=("$mono_zip" "$fira_zip" "$lxgw_zip" "$mapl_zip")
	for ((i=0; i<${#font_urls[@]}; i++)); do
		payload="$fonts_dir${fontname_list[$i]}/"
		function unzipper() {
			unzip "${tar_list[$i]}" -d "$payload" &> /dev/null
			rm ${tar_list[$i]} && unset payload
			cd ..
		}

	if [[ -d "$payload" ]]; then
		# 只要字典序的哈希结果，这个 -df 太阴了
		declare ret=`\
			find "$payload" -type f | sort -df | \
			xargs sha256sum | awk -F' ' '{ printf $1"\n" }' | \
			sha256sum | awk -F' ' '{ print $1 }' \
			`
		# 文件有而且齐全
		[[ "$ret" == "${sha256_list[$i]}" ]] && continue
	elif [[ -f "$fonts_dir${tar_list[$i]}" ]]; then
		# 不存在但有zip
		{"unzipper"}&
		continue
	fi
	{
		wget "${font_urls[$i]}" &> /dev/null
		"unzipper"
	}&
done
wait
cd "$curr_dir"
}


function get_fonts() {
	# 直接固定写死用这些版本的字体
	declare jetbrain="$url_prefix/JetBrains/JetBrainsMono/$release_path/v2.304/$mono_zip"
	declare firacode="$url_prefix/tonsky/FiraCode/$release_path/6.2/$fira_zip"
	declare lxgw="$url_prefix/lxgw/LxgwWenkai/$release_path/v1.520/$lxgw_zip"
	declare mapl="$url_prefix/subframe7536/maple-font/$release_path/v7.5/$mapl_zip"
	declare -A link_list=("$jetbrain" "$firacode" "$lxgw" "$mapl")

	"_detect_font" ${link_list[@]}
	fc-cache -fv
	declare ret=`fc-list | $ggrep -Ei "$lxgwname|$firaname|$mononame"`
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
		# raw-github的形式：
		# https://cdn.jsdelivr.net/gh/morhetz/gruvbox@master/colors/gruvbox.vim
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
	declare payload="\
	<!-- modified by vim-conf/init.sh at `date \"+%Y-%m-%d %H:%M:%S\"` -->
	<alias>
		<family>sans-serif</family>
		<prefer>
			<family>Fira Code Medium</family>
			<family>LXGW WenKai Mono</family>
			<family>JetBrains Mono</family>
		</prefer>
	</alias>
	<alias>
		<family>monospace</family>
		<prefer>
			<family>Fira Code Medium</family>
			<family>LXGW WenKai Mono</family>
			<family>JetBrains Mono</family>
		</prefer>
	</alias>\
"

	declare tonfpath="$HOME/.config/fontconfig"
	declare fontconf="$tonfpath/fonts.conf"
	if [ -f "$fontconf" ]; then
		declare check_dup=`\
			cat "$fontconf" | \
			$ggrep -Ei "fira code medium|lxgw wenkai mono|jetbrains mono" \
			`
		# 不重复定义
		[[ "$check_dup" != '' ]] && return
		# 否则插入到</fontconfig>所在的上一行
		$gsed -i "/<\\/fontconfig>/i\\$payload" "$fontconf"
		return
	fi
	mkdir -p "$tonfpath" && touch "$fontconf"
	# 需要额外补充
	declare pre_process="\
<?xml version='1.0'?>
<!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
<fontconfig>
$payload
</fontconfig>"
	echo "$pre_process" > "$fontconf"
}

function setup_ycm() {
	# TODO: 如果没下载好就进来就会爆炸
	# 需要 cmake，构建中途将github切换为镜像源
	cd "$ycm_dir"
	git submodule update --init --recursive
	python3 ./install.py --all --verbose
	cd "$curr_dir"
}

function setup_vimspector() {
	# TODO: 如果没下载好就进来就会爆炸
	cd "$vimspector_dir"
	# github.com/go-delve/delve/cmd/dlv 是作为 go mod 来的
	# 理论上不会受到这里替换的影响
	# 因为模式串是 https 开头的
	$gsed -i "s#'$main_github#'$url_prefix#g" ./python3/vimspector/gadgets.py
	python3 ./install_gadget.py \
		--enable-c --enable-cpp --enable-go \
		--enable-python --enable-bash \
		--force-enable-node \
		--enable-rust
	vim -u "$vim_target" +VimSpectorInstall! +wa!
	cd "$curr_dir"

}

function older_vim_cleaner() {
	tobe_inject="vi vim-runtime"
	if command -v apt &> /dev/null; then
		sudo apt-get remove --purge "$tobe_inject"
	elif command -v pacman &> /dev/null; then
		sudo pacman -Syyu
	elif command -v brew &> /dev/null; then
		brew update
		# mac 上直接更新就行
		# brew uninstall --force "$tobe_inject"
	fi
}

function install_vim_nox() {
	if command -v apt &> /dev/null; then
		sudo apt install vim-nox
	elif command -v pacman &> /dev/null; then
		# pacman brew 不需要操心
		return
	elif command -v brew &> /dev/null; then
		return
		# brew install vim-nox
	fi
}

function _cp_vimrc() {
	mkdir -p "$vimdir"
	cp "$curr_dir/vimrc" "$vim_target"
	cp "$curr_dir/clean_vimview.py" "$vimdir/clean_vimview.py"
	vim -u "$vim_target" +PlugInstall! +wa!
	if [[ "$has_been_called" != "" ]]; then
		# 避免重复处理，但是看上去有点呆
		sed -i '12s/has_been_called=""/has_been_called="yes"/' "$curr_dir/init.sh"
		"setup_ycm"
		"setup_vimspector"
	fi
}

function check_sys() {
	# linux: GNU/Linux
	if [[ "`uname -o`" == "Darwin" ]]; then
		ping_dev='stddev'
		gsed='gsed'
		ggrep='ggrep'
	fi
}
####################################################################### shellscript入口
"check_sys"
"alter_src_via_mirror"
"get_plug_manager"
"get_color_scheme"

declare vim_ver=`vim --version | $ggrep -oP '(?<=VIM - Vi IMproved )([0-9\.]+)'`
declare _ret1="$?"
declare vim_flg=`vim --version | $ggrep -oP '([+-])(?=python3)'`
declare _ret2="$?"

if [[ "$_ret1" -ne 0 || "$_ret2" -ne 0 || $(echo "$vim_ver <= 9.0" | bc) -eq 1 || "$vim_flg" == '-' ]]; then
	echo attempt to renew vim...
	"older_vim_cleaner"
	"install_vim_nox"
fi

if [[ "$font_key" = true ]]; then
	"get_fonts"
	"set_font_conf"
else
	$gsed -i 's/set guifont=/" set guifont=/g' "$curr_dir/vimrc"
	# 重算
	vimrc_hash=`sha256sum "$curr_dir/vimrc" | awk -F' ' '{ print $1 }'`
fi

if [[ -s "$vim_target" ]]; then
	# 经过color后已经创建~/.vim/目录
	calc_hash=`cat "$vim_target"|sha256sum|awk -F' ' '{print $1}'`
	[[ "$calc_hash" != "$vimrc_hash" ]] && "_cp_vimrc"
else
	"_cp_vimrc"
fi

"setup_ycm"
"setup_vimspector"

echo 'done...'
