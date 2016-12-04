---
title: Android 查看系统应用的权限
date: 2015-10-30 15:09:36
category: Android_note
tag: [Android]
---


adb shell进入机器

```
/system/app # ll

drwxr-xr-x root     root              2015-09-09 20:42 LiveWallpapersPicker
drwxr-xr-x root     root              2015-09-09 20:42 Music
drwxr-xr-x root     root              2015-09-09 20:42 NfcNci
drwxr-xr-x root     root              2015-09-09 20:42 NoiseField
drwxr-xr-x root     root              2015-09-09 20:42 OSSwichToWindows
drwxr-xr-x root     root              2015-09-09 20:42 PacProcessor
drwxr-xr-x root     root              2015-09-09 20:42 PackageInstaller
```

查看第三方安装apk的权限，进入/data/app
```
-rw-rw-rw- system   system    6577672 2015-09-10 16:00 appsearch_AndroidPhone_1011875l_6.3.0_E8AB.apk

-rw-rw-rw- system   system    7192235 2015-09-10 16:00 baidumap_v7.0.0_55C9.apk

-rw-rw-rw- system   system    5617682 2015-09-10 16:01 baidusearch_v4.9_0A10.apk

-rw-rw-rw- system   system    6123921 2015-09-10 16:00 com.dianxinos.optimizer.channel_channel_1012389f_74E9.apk

-rw-rw-rw- system   system   16689707 2015-09-10 16:00 googlepinyin4.1.2.101341788-armeabi-v7.apk
```
这是直接将apk复制进/data/app中，机器也能执行；

apk的权限都是666；如果权限不对，机器无法运行apk

install的apk在/data/app的形式如下
```
drwxr-xr-x system   system            2015-09-11 10:17 com.UCMobile.x86-1
drwxr-xr-x system   system            2015-09-11 10:18 com.sankuai.meituan-1
```
库已经被抽出来，建立文件夹来放置；权限是755

看看文件夹里面的权限情况
```
/data/app/com.UCMobile.x86-1 # ll

-rw-r--r-- system   system   20731599 2015-09-11 10:17 base.apk
drwxr-xr-x system   system            2015-09-11 10:17 lib
```

机器中，预装的apk放在/system/vendor/preinstall 里面，默认权限是666

执行脚本把它们复制到/data/app/，cp -p 保留源目录或者文件的属性

如果adb shell进入机器，以root身份执行脚本，一般都没问题；

但机器自动执行脚本，能否正常执行chmod？需要在代码中调用执行脚本

为了保证预置apk能正常运行，在复制到data/app/后，把权限修改为666或777

也可在复制前就修改权限
```
for file in /system/vendor/preinstall/*;
    do
       cp -p $file /data/app
    done

for app in /data/app/*;
    do
        chmod 777 "$app"
    done
```
