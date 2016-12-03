---
title: Android resource 解析
date: 2016-03-15 15:10:05
category: Android_note
tag: [Android_note]
---

apk资源，工具使用

#### 资源分类
* assets/	不会被分配ID；用AssetManager以字节流的形式读取

* res/	每个资源会分配到一个ID，保存在R.java文件中；通过ID来引用；只能有一级子目录，并且子目录名格式固定

##### res资源类型
参考
[docs/guide/topics/resources/providing-resources.html](docs/guide/topics/resources/providing-resources.html)

|资源类型               |描述                 |
| :------------------- | :-------------------|
|animator/|存放定义属性动画的XML文件。|
|anim/|存放定义补间动画的XML文件。当然属性动画也可以放该目录下，为了区分这两种动画，因此定义了两种资源类型|
|color/|存放定义颜色状态列表的XML文件，比如说一个按钮，按下去是什么颜色，没按是什么颜色，不可用是什么颜色等等|
|drawable/|存放位图(.png, .9.png, .jpg, .gif)或可被编译为 Bitmap files，Nine-Patches, Layer List，State lists, Level List, Transition Drawable, Inset Drawable, Clip Drawable, Scale Drawable，Shapes Drawable，Animation drawables类型的XML文件|
|layout/|存放定义用户UI 的XML文件|
|menu/|存放定义应用菜单的XML文件|
|raw/|可存放任意格式的文件|
|values/|存放定义string，array，color，dimen，style的XML文件|
|xml/|存放任意的XML文件。比如若你的应用中有一些特殊配置参数，则可以将这些配置参数定义在XML文件中，然后将此XML文件置于此目录供应用程序使用|

##### aapt简介

aapt支持9种命令，分别为 l[ist]，d[ump]，p[ackage]，r[emove]，a[dd]，c[runch]，s[ingleCrunch]，v[ersion]，[dae]m[on]

要使用aapt，首先`source build/envsetup.sh`，就可以直接使用aapt指令了

比如找到TeleService.apk，`aapt d resources TeleService.apk`列出资源
