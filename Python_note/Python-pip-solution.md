---
title: pip 相关
date: 2017-04-29 20:59:20
category: Python
---

* Ubuntu 14.04 

## pip 使用国内镜像源
使用pip install 的时候总是出现read timeout 之类的错误

使用国内镜像  `https://pypi.tuna.tsinghua.edu.cn/simple`  
例如我要安装 scrapy  
```
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple scrapy
```

添加源的配置

Linux下，修改 ~/.pip/pip.conf (没有就创建一个)， 修改 index-url至tuna，内容如下：
```
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
```
 

windows下，直接在user目录中创建一个pip目录，如：C:\Users\xx\pip，新建文件pip.ini，内容如下
```
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
```