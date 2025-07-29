#!/usr/bin/env sh
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月30日 星期三 00时52分03秒
# Last modified at 2025年07月30日 星期三 00时56分41秒
a=('echo' 'ls')
aa=('123...' '..')
function aaa() {
	for ((i=0; i<${#a[@]}; i++)); do
		${a[i]} ${aa[i]}
	done
}
function bbb() {
	inp=($@)
	for ((i=0; i<${#a[@]}; i++)); do
		${a[i]} ${inp[i]}
	done
}
aaa
bbb ${aa[@]}
