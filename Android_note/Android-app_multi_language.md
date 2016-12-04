---
title: Android 多语言自动适配
date: 2015-10-21 15:09:19
category: Android_note
tag: [Android]
---


Android为多语言适配提供了很大的方便。开发者不需要在代码中进行修改。
只需要配置xml文件。

res --> values 其中存放有xml文件。一般这些都是英文的字符串。我们可以存放其他语言的字符串。
另一语种的字符串文件放在另外的文件夹下。文件夹命名规则为： values-##-r**

例如: values-zh-rCN

其中##表示语言代号（language codes），**表示国家代号（country codes），也可以只有语言代号。

使用eclipse，步骤如下：
* 1.在res文件夹下新建一个文件夹，命名为values-zh-rCN
* 2.在values-zh-rCN文件夹中新建一个string.xml文件，里面存放的是程序中用到的字符串。
