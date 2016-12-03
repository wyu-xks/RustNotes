---
title: 日常命令记录
date: 2015-05-16 22:18:01
category: Linux_note
tag: [Linux,Tools]
toc: true
---
CLI（command-line interface，命令行界面）
是指可在用户提示符下键入可执行指令的界面，
它通常不支持鼠标，用户通过键盘输入指令，计算机接收到指令后，予以执行。

[TOC]

## 快捷方式类
### linux文本从剪贴板选择粘贴快捷键  `ctrl + :`
出现数字序号提示，按数字键选择，或者鼠标点击选择

### 控制窗口
按住 `Ctrl + win` ，再按方向键，可控制窗口最大化，贴到边缘等等
`Ctrl + l`，清屏，相当于clear
`Ctrl + w`，删除左边的单词；并不是删除整行
ctrl-u从当前位置删除到行首，ctrl-k删除行尾，ctrl-a移动到行首，ctrl-e移动到行尾

## 查找搜索

### wc 输出统计
统计.md文件数量
```
find . -name *.md | wc -l
```
### 寻找特定文件并执行操作
比如删除～结尾的文件
```
find . -name "*~" -type f -print -exec rm -rf {} \;
```

修改执行命令和文件类型，安装目录下所有apk文件
```
find . -name "*.apk" -type f -print -exec adb install {} \;
```

删除指定目录，比如删除所有的git目录
```
find . -type d -iname ".git" -exec rm -rf {} \;
```

### 批量修改文件名

```
rename abc_ "" *// 删除所有文件的'abc_'前缀

for i in `ls`;do mv $i abc_$i;done // 加前缀: abc_
```

## 系统，文件状态
### 查看文件夹大小 `du`
```
~/wd/rustNote$ du --max-depth=0 -h .git/
1.9M	.git/
```
### 硬盘容量 `df`
```
df -h               # 以最合适的单位显示
df --block-size m   # 以Mb为单位显示
```

## 软件更新
sudo apt-get update(更新源)

sudo apt-get -f install

### 下载Skype
参见：[http://blog.csdn.net/hhbgk/article/details/8683939]
```
wget http://www.skype.com/go/getskype-linux-deb
sudo dpkg -i skype_xx.deb
#（特别注意这儿的文件名可能会因为SKYPE版本的更新而不一样，自己根据下载的文件来修改一下就好了）
```

vim 的配置
https://github.com/ma6174/vim

参考博客： http://easwy.com/blog/archives/advanced-vim-skills-catalog/
