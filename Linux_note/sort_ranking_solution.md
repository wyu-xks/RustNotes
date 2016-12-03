---
title: 整理排名文件的脚本
date: 2015-02-02 01:08:17
category: Linux_note
tag: [Linux,Tools]
---

```bash
#! /bin/sh
sed -i 's/<small>/\n/g' $1 | sed 's/)<\/small><\/td><td>/\n/g'
sed -i 's/.&nbsp/\n/g' $1 # 用换行符替换
sed -i '-e /;/d' $1 # 删除带有分号的行
sed -i 's/)</\n/g' $1 # 将数字两边的字符替换成换行符
sed -i 's/, /\n/g' $1 #
sed -i '-e /(/d' $1
sed -i '-e /-/d' $1
sed -i '-e /td/d' $1	# 删除多余的东西，剩下的就是排名和积分
```

把结果放入xls文件中 cat rankingtest > ranking.xls

整理Log的命令
```bash
find . -name deviceLogcat.txt|xargs grep "E/" >> MonkeyTestLogManager
sed -i 's/08-25 /\n/g' MonkeyTestLogManager
sed -i '-e /To0be0filled0by0O0E0/d' MonkeyTestLogManager
```

在所有md文件的第三行插入`category: Linux_note`
```
sed -i '3a category: Linux_note' *.md
```
