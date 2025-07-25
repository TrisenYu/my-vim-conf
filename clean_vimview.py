#!/usr/bin/env python
# -*- coding: utf-8 -*-
# SPDX-LICENSE-IDENTIFIER: GPL2.0
# (C) All rights reserved. Author: <kisfg@hotmail.com> in 2025
# Created at 2025年07月22日 星期二 17时15分40秒
# Last modified at 2025年07月25日 星期五 15时47分13秒
import os
from datetime import datetime

target_dir: str = './view/'


def clean_views() -> None:
    """
    清理当前所在文件夹下的 view 目录中超过15天没有更改的view文件
    """
    global target_dir
    dirs = os.listdir(target_dir)
    curr = datetime.now()
    for file in dirs:
        conj = os.path.join(target_dir, file)
        _modify_time = os.path.getmtime(conj)
        lst_modify_time = datetime.fromtimestamp(_modify_time)
        time_diff = curr - lst_modify_time
        if time_diff.days >= 15:
            os.remove(conj)


if __name__ == '__main__':
    clean_views()
