#!/usr/bin/env sh
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月30日 星期三 00时19分05秒
# Last modified at 2025年07月30日 星期三 00时20分19秒
a=("1" "2222" "3333")

function aaa() {
	inp=($@)
	for ((i=0; i<=${#inp[@]}; i++)); do
		echo ${inp[$i]}
	done
}
aaa ${a[@]}
