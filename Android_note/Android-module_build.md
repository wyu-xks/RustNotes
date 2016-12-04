---
title: Android frameworks 模块编译
date: 2015-11-02 15:10:46
category: Android_note
tag: [Android_frameworks]
---

Android L 源码，编译相关的文件一般在build目录下  
build/target/product 放了很多mk文件；一般不同的产品会有不同的目录

假设我不想编译OpenWnn，在build目录下grep一下“OpenWnn”  
target/product/full_base.mk  
target/product/sdk_base.mk  
进入这两个文件，删掉这两句及相关库后：  
```mk
PRODUCT_PACKAGES := \
    libfwdlockengine \
    WAPPushManager
```
把out目录删除，或者只删掉相关文件
重新编译即可

在full_base.mk中，有以下内容
```mk
PRODUCT_PACKAGES := \
    libfwdlockengine \
    WAPPushManager

PRODUCT_PACKAGES += \
    LiveWallpapersPicker \
    NoiseField \
    PhaseBeam \
    VisualizationWallpapers \
    PhotoTable
......
```
sdk_base.mk中也有这么多packages
```
PRODUCT_PACKAGES := \
        Dialer \
        Gallery \
        Mms \
        Music \
        SystemUI \
......
```
不想编译哪个，删去即是。在对应的产品mk文件中确保没有这个模块即可

但是有的地方可能会调用到这些app。如果不编译某个模块，而系统中有对它的调用，很可能会有弹窗警告。比如“短信”已停止工作。

```
adb shell
root@product_name:/system/app # rm -rf Mms
```
从机器中删去短信app，需要root权限  
在adb shell里要注意语法，-rf不能写在最后面
