---
title: Git 使用问题 - win7 git bash下git pull失败
date: 2016-04-23 16:31:22
category: Tools
tag: [Git]
---
win7 旗舰版，从github上pull代码时，git bash命令出现错误
```
Administrator@rust-PC /g/rust_proj/cardslib (master)
$ git --version
git version 2.8.0.windows.1

Administrator@rust-PC /g/rust_proj/cardslib (master)
$ git pull https://github.com/gabrielemariotti/cardslib.git
fatal: I don't handle protocol 'https'
```
解决办法：
```
Administrator@rust-PC /g/rust_proj/cardslib (master)
$ git pull 'https://github.com/gabrielemariotti/cardslib.git'
```
git version 2.6.4.windows.1  下可使用双引号

故障原因：
参见： http://stackoverflow.com/questions/30474447/git-fatal-i-dont-handle-protocol-http
在 git clone 和 http://... 之间看起来是一个空格，但它实际上是一个特殊的Unicode字符
删去这个字符，输入真正的空格后，命令可以使用了。
真正的命令应该是这样的：
```
vi t.txt # copy+paste the line
python
open('t.txt').read()
git clone \xe2\x80\x8b\xe2\x80\x8bhttp://...
```
