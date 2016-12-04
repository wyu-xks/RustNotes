---
title: Python 查看目录中的文件
date: 2017-07-01 21:47:20
category: Python
---

一些关于文件的操作  
例如，实现查看目录内容的功能。类似Linux下的`tree`命令。  
统计目录下指定后缀文件的行数。

功能是将目录下所有的文件路径存入list中。
可以加入后缀判断功能，搜索指定的后缀名文件。
主要利用递归的方法来检索文件。

### 仿造 tree 功能示例代码
* Python2.7

列出目录下所有文件  
递归法
```python
import os

def tree_dir(path, c_path='', is_root=True):
    """
    Get file list under path. Like 'tree'
    :param path Root dir
    :param c_path Child dir
    :param is_root Current is root dir
    """
    res = []
    if not os.path.exists(path):
        return res
    for f in os.listdir(path):
        if os.path.isfile(os.path.join(path, f)):
            if is_root:
                res.append(f)
            else:
                res.append(os.path.join(c_path, f))
        else:
            res.extend(tree_dir(os.path.join(path, f), f, is_root=False))
    return res
```

下面是加入后缀判断的方法。在找到文件后，判断一下是否符合后缀要求。不符合要求的文件就跳过。
```python
def tree_dir_sur(path, c_path='', is_root=True, suffix=''):
    """ Get file list under path. Like 'tree'
    :param path Root dir
    :param c_path Child dir
    :param is_root Current is root dir
    :param suffix Suffix of file
    """
    res = []
    if not os.path.exists(path) or not os.path.isdir(path):
        return res
    for f in os.listdir(path):
        if os.path.isfile(os.path.join(path, f)) and str(f).endswith(suffix):
            if is_root:
                res.append(f)
            else:
                res.append(os.path.join(c_path, f))
        else:
            res.extend(tree_dir_sur(os.path.join(path, f), f, is_root=False, suffix=suffix))
    return res

if __name__ == "__main__":
    for p in tree_dir_sur(os.path.join('E:\ws', 'rnote', 'Python_note'), suffix='md'):
        print p
```

### 统计目录下指定后缀文件的行数
仅适用os中的方法，仅检索目录中固定位置的文件

```python
# -*- coding: utf-8 -*-
import os


def count_by_categories(path):
    """ Find all target files and count the lines """
    if not os.path.exists(path):
        return
    c_l_dict = dict()  # e.g. {category: lines}
    category_list = [cate for cate in os.listdir(path) if
                     os.path.isdir(os.path.join(path, cate)) and not cate.startswith('.')]
    for category_dir in category_list:
        line_count = _sum_total_line(os.path.join(path, category_dir), '.md')
        if line_count > 0:
            c_l_dict[category_dir] = line_count
    return c_l_dict


def _sum_total_line(path, endswith='.md'):
    """ Get the total lines of target files """
    if not os.path.exists(path) or not os.path.isdir(path):
        return 0
    total_lines = 0
    for f in os.listdir(path):
        if f.endswith(endswith):
            with open(os.path.join(path, f)) as cur_f:
                total_lines += len(cur_f.readlines())
    return total_lines


if __name__ == '__main__':
    note_dir = 'E:/ws/rnote'
    ca_l_dict = count_by_categories(note_dir)
    all_lines = 0
    for k in ca_l_dict.keys():
        all_lines += ca_l_dict[k]

    print 'all lines:', str(all_lines)
    print ca_l_dict
```

以笔记文件夹为例，分别统计分类目录下文件的总行数，测试输出
```
all lines: 25433
{'flash_compile_git_note': 334, 'Linux_note': 387, 'Algorithm_note': 3637, 'Comprehensive': 216, 'advice': 137, 'Java_note': 3013, 'Android_note': 11552, 'DesignPattern': 2646, 'Python_note': 787, 'kotlin': 184, 'cpp_note': 279, 'PyQt_note': 439, 'reading': 686, 'backend': 1136}
```
