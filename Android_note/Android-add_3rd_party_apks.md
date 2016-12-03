---
title: Android 预装第三方apk
date: 2015-09-24 15:09:14
category: Android_note
tag: [Android_frameworks]
---
[TOC]

keyword： preinstall apk

## 基本原理
一般来说，安装apk需要2个要素：apk的 `Android.mk` 文件和 PRODUCT_PACKAGES

### mk 文件说明
Android.mk 里描述的是这个apk；需特别注意的是库文件

若apk支持不同cpu类型的so，针对so的部分的处理:
```
ifeq ($(TARGET_ARCH),arm)
LOCAL_PREBUILT_JNI_LIBS := \
    @lib/armeabi-v7a/xxx.so\
    @lib/armeabi-v7a/xxxx.so
else ifeq ($(TARGET_ARCH),x86)
LOCAL_PREBUILT_JNI_LIBS := \
    @lib/x86/xxx.so
else ifeq ($(TARGET_ARCH),arm64)
LOCAL_PREBUILT_JNI_LIBS := \
    @lib/armeabi-v8a/xxx.so

endif
```
即将和TARGET_ARCH对应的so抽离出来  
库文件太多，写了个脚本来处理；首先ls出库文件名，保存到文本，再用脚本处理文本

`LOCAL_DEX_PREOPT := false` - dex文件开关；若为true，编译dex；目的是加快开机速度 :)

### PRODUCT_PACKAGES
apk的名字要添加到 PRODUCT_PACKAGES

apk相关配置完成后，mm编译试一下。若mm编译通过，全编译一般也没问题。

## 例子

### 预装第三方音乐apk
目的：预装多个apk

相关的apk存放在vendor目录下统一管理；每个apk单独存放在自己的目录下

```
vendor/ts$ tree
.
├── china_apks
│   ├── doubanFM
│   │   ├── Android.mk
│   │   └── doubanFM.apk
│   ├── Kugouyinle
│   │   ├── Android.mk
│   │   └── Kugouyinle.apk
│   ├── KuwoPlayer
│   │   ├── Android.mk
│   │   └── KuwoPlayer.apk
│   └── Lava
│       ├── Android.mk
│       └── Lava.apk
├── products
│   ├── cn_products.mk
│   └── us_products.mk

```
apk“名单” `cn_products.mk` 放在china_apks目录外

相关的Android.mk文件：

```mk
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := Lava
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $(LOCAL_MODULE).apk
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_CERTIFICATE := PRESIGNED

include $(BUILD_PREBUILT)
```
`LOCAL_CERTIFICATE := platform` 增加root权限，一般不用

cn_products.mk 文件：
```mk
#Add the cn apps.
PRODUCT_PACKAGES += \
    Xiami \
    TingPhone \
    tiantiandongting \
    QQMusic \
    Lava \
    KuwoPlayer \
    Kugouyinle \
    doubanFM \
    CloudMusic
```
至此，apk和PRODUCT_PACKAGES已经准备好了；现在任务是让makefile找到这些apk

根据产品型号，进入 device/companyname/ABCxxxx  找到 ABCxxxx.mk，添加：
```mk
# Add preinstall apks
$(call inherit-product-if-exists, vendor/ts/products/cn_products.mk)
```
把cn_products.mk的路径写入即可 ;-)

### 预装Google服务包

`device/cpu/structrue/yourProductName/device.mk`  
device.mk:462: $(call inherit-product-if-exists, vendor/google/products/company_gms.mk)

关键点 : company_gms.mk里写上要加载的apk

添加google服务

我们自己的ROM里没有google服务，完整的google包里包含google框架和各种服务，我们可以选择性安装模块

在google包里products目录下，有一个gms.mk文件（或者自己起名字）

gms.mk管理着要安装的各个模块，找到关键字PRODUCT_PACKAGES

PRODUCT_PACKAGES后面跟着的就是要安装的模块

截取部分来看看：
```
PRODUCT_PACKAGES += \
    AndroidForWork \
    ConfigUpdater \
    GoogleBackupTransport \
    GoogleFeedback
```
一般会在device/corecompany/yourproductname/ 目录中存放.mk文件

corecompany指代芯片厂家，比如高通，MTK；
可能是device.mk，也可能是 yourproductname.mk

这个mk文件中会引用gms.mk（或者自己起名字）；需要把gms.mk的路径写对，编译时会自动找到
```
$(call inherit-product-if-exists, vendor/google/products/intel_gms.mk)
```
本例中google包放在vendor目录下

观察 vendor/google/apps/GmsCore 里的Android.mk文件

LOCAL_PRIVILEGED_MODULE := true

这个设置表示，GmsCore模块装入system/priv-app

如果没有这个设置，模块会装入system/app

可以在模块目录mm编译，看看会装在哪个目录

priv-app里能获得系统权限，安卓4.4后有了这个划分

小结：

1. 找个地方把google包放进去，比如vendor/google

2. 选择要安装的google服务，修改gms.mk文件

3. 修改device/corecompany/yourproductname/中相应的mk文件，引用gms.mk

4. 把out目录删掉，或者只删去相应模块

5. 编译

### 网易云音乐Android.mk文件示例
```mk
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := CloudMusic
LOCAL_DEX_PREOPT := false
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $(LOCAL_MODULE).apk
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_PREBUILT_JNI_LIBS:= \
    @lib/armeabi/libbitmaps.so \
    @lib/armeabi/libblur.so \
    @lib/armeabi/libFMProcessor.so \
    @lib/armeabi/libfpGenerate.so \
    @lib/armeabi/libgifimage.so \
    @lib/armeabi/libijkffmpeg.so \
    @lib/armeabi/libijkplayer.so \
    @lib/armeabi/libijksdl.so \
    @lib/armeabi/libimagepipeline.so \
    @lib/armeabi/liblocSDK3.so \
    @lib/armeabi/libMP3Encoder.so \
    @lib/armeabi/libndkbitmap.so \
    @lib/armeabi/libneutil.so \
    @lib/armeabi/libwebp.so \
    @lib/armeabi/libwebpimage.so

include $(BUILD_PREBUILT)
```
user版默认开启编译dex；在这里关闭，否则编译出错 :-(
```bash
...
dex2oatd I 23189 23309 art/runtime/verifier/method_verifier.cc:288] Verification error in void net._.a()
...
```

机器的 .mk 文件配置：
```mk
ifeq ($(TARGET_BUILD_VARIANT),user)
    ifeq ($(WITH_DEXPREOPT),)
      WITH_DEXPREOPT := true
    endif
endif
```

### 喜马拉雅电台 mk文件示例
```mk
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := TingPhone
LOCAL_MODULE_TAGS := optional
LOCAL_SRC_FILES := $(LOCAL_MODULE).apk
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_SUFFIX := $(COMMON_ANDROID_PACKAGE_SUFFIX)
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_PREBUILT_JNI_LIBS:= \
    @lib/armeabi/libaudiomixer.so \
    @lib/armeabi/libmp3decoder.so \
    @lib/armeabi/libmresearch.so \
    @lib/armeabi/libnoisereduction.so \
    @lib/armeabi/libxmediaplayer.so \
    @lib/armeabi/libEasylinkControllerVer2.so \
    @lib/armeabi/libmp3encoder.so \
    @lib/armeabi/libmsc.so \
    @lib/armeabi/libnoisereduction_v7.so \
    @lib/armeabi/libxmediaplayer_x.so

include $(BUILD_PREBUILT)
```

## 机器配置
TARGET_ARCH=arm

TARGET_ARCH_VARIANT=armv7-a-neon

TARGET_CPU_VARIANT=cortex-a7
