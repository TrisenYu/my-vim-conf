#!/usr/bin/env python
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月22日 星期二 17时15分40秒
# Last modified at 2025年07月30日 星期三 13时26分35秒
from datetime import datetime
import os

home_directory:str = os.path.expanduser('~')
target_dir: str = f'{home_directory}/.vim/view/'

def clean_views(rm_all: bool=False) -> None:
    """
    清理当前所在文件夹下的 view 目录中超过7天没有更改的view文件
    """
    global target_dir
    dirs = os.listdir(target_dir)
    curr = datetime.now()
    for file in dirs:
        conj = os.path.join(target_dir, file)
        _modify_time = os.path.getmtime(conj)
        lst_modify_time = datetime.fromtimestamp(_modify_time)
        time_diff = curr - lst_modify_time
        if time_diff.days >= 7 or rm_all:
            os.remove(conj)


if __name__ == '__main__':
    import argparse
    vparser = argparse.ArgumentParser(
        description="vim-view清理脚本配置帮助",
        allow_abbrev=True
    )
    vparser.add_argument(
        '-ra', '--remove-all',
        type=bool, default=False,
        help='删除view目录下的所有记录项'
    )
    vargs = vparser.parse_args()
    clean_views(vargs.remove_all)
