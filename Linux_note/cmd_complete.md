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

删除文件名有特定字符的文件
```
find . -name "*abcd*" -exec rm -f {} \;
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

## 小脚本
### 进入特定目录并执行 `git pull`
先统计子目录个数。使用for循环和if判断是否是目录，进入目录执行git pull

```sh
# cd project and git pull

count=`find . -maxdepth 1 -type d | wc -l` # include current dir
let "count-=1" # minus 1
echo -e "Found $count folders.\n"
current=0;

for file in ./*
do
    if test -d $file
    then
    	let current++
        cd $file
        pwd
	git status
        git pull
        cd -
        echo "||------------------------------------------>>> [$current / $count]"
	echo " "
    fi
done
echo "[------------   Done   --------------]"
```

### 文本处理脚本
删除文本中多余的字段。主要靠sed操作。
```sh
#! /bin/sh
# 提取apk库文件名，整理成mk文件需要的形式
# 2015-11-25 14:51:07
sed -i 's/.so/.so\n/g' $1 #.so后面加上换行
sed -i 's/lib/\nlib/g' $1 #lib前面也换行
sed -i '/^$/d' $1 #删除空行
sed -i '/ /d' $1 #删除有空格的行
sed -i 's/lib/@\/lib\/armeabi\/lib/g' $1 #lib -> @\lib\
sed -i 's/.so/.so\ \\/g' $1 #.so后面加上空格和'\'，即 .so -> .so \
sed -i 's/@\/lib/    @lib/g' $1 #@\lib\去掉左边的反斜杠，并在@前加上4个空格
```

## vim

### vim 文本替换命令
s表示替换；命令尾加上g表示搜索当前整行所有匹配情况；命令前可以指定行数范围。

在命令模式下输入指令

`:s/old/new` -- 当前行首个`old`字符替换成`new`字符

`:s/old/new/g` -- 当前行所有`old`字符替换成`new`字符

`:1,2 s/old/new/g` -- 第1行和第2行所有`old`字符替换成`new`字符

`:% s/old/new/g` -- 所有行出现的`old`字符替换成`new`字符
