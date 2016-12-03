---
title: awk in Ubuntu
date: 2015-12-16 22:11:01
category: Linux_note
tag: [Linux,Tools]
toc: true
---
Ubuntu14.04
## 目的：想用awk来统计某个文本中单词出现的次数，并以一定的格式输出结构

通常，awk逐行处理文本。awk每接收文件的一行，然后执行相应的命令来处理。

用legal文件来做示例
```
$ cat /etc/legal

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.
```

### 搜索统计单词“law”的个数
```
$ awk -F : '/law/{count++} END{print "the count is ",count}' /etc/legal
the count is  1
```
### 统计单词“the”的个数
```
$ awk -F : '/the/{count++} END{print "the count is ",count}' /etc/legal
the count is  3
```
找到指定单词，自定义变量count自增，最后输出语句和count值


命令sort，把各行按首字母排列顺序重新排列起来
* sort -nr，每行都以数字开头，按数字从达到小，排列各行
* uniq -c，统计各行出现的次数，并把次数打印在每行前端
* awk参数 NF - 浏览记录的域的个数

综合起来，命令就是
```
awk -F' ' '{for(i=1;i<=NF;i=i+1){print $i}}' /etc/legal |
sort|uniq -c|sort -nr|awk -F' ' '{printf("%s %s\n",$2,$1)}'
```
统计/etc/legal中单词出现次数，并以“单词 次数”格式输出结果
