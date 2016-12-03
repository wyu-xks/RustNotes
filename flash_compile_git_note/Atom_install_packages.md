---
title: atom编辑器安装插件
date: 2016-05-24 15:09:13
category: Tools
tag: [Atom]
---

win7，atom 1.7.3，npm 2.15.1，node v4.4.4，git bash
npm装在了G盘，环境变量中PATH指向用户目录下AppData/Roming/npm

atom中直接安装插件失败。尝试手动安装。
找到两个插件的repo地址：https://github.com/cakebake/markdown-themeable-pdf，https://github.com/izuzak/atom-pdf-view
使用git bash进入atom插件目录`/c/Users/Administrator/.atom/packages`，并将目录clone到这个地方。
clone完毕后，cd进入插件目录，`npm install`直接安装。
最后重启一下atom，看看插件自动加载了没有。

参考：https://segmentfault.com/q/1010000000743953
