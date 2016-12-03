---
title: Android Monkey test
date: 2015-12-11 20:10:20
category: Android_note
tag: [Android]
---

## cmd启动测试
只测试launcher3：  
adb shell monkey -p com.cyanogenmod.trebuchet -v 10000 > mtr11271352.txt

Launcher3的包名被改写为com.cyanogenmod.trebuchet  
LOCAL_AAPT_FLAGS += --rename-manifest-package com.cyanogenmod.trebuchet

## 关于Monkey测试的停止条件

Monkey Test执行过程中在下列三种情况下会自动停止：

1、如果限定了Monkey运行在一个或几个特定的包上，那么它会监测试图转到其它包的操作，并对其进行阻止。

2、如果应用程序崩溃或接收到任何失控异常，Monkey将停止并报错。

3、如果应用程序产生了应用程序不响应（application not responding）的错误，Monkey将会停止并报错。

例如某个测试记录中：  
ANR in com.cyanogenmod.trebuchet (com.cyanogenmod.trebuchet/com.android.launcher3.Launcher)

## 可以用脚本启动 Monkey test
比如对Launcher3进行Monkey test：

```bash
#!/bin/sh

echo "***************************************"
echo "*****      Monkey run !!!!!!     ******"
echo "***************************************"
RECORD_FOLDER=`date +%Y%m%d`
FOLDER_TIME=`date +%H%M%S`
mkdir testRecord-$RECORD_FOLDER-$FOLDER_TIME
cd testRecord-$RECORD_FOLDER-$FOLDER_TIME
for i in {1..10}
    do
    adb shell input keyevent 3
    START_TIME=`date +%H%M%S`
    echo "Now run the NO.$i test - start time : $START_TIME"
    adb shell monkey -p com.cyanogenmod.trebuchet -v 10000 > mtr_$i-$START_TIME.log
done
grep -nr "System appears to have crashed" --exclude=*.txt > crashRecord.txt
echo "*********     Finish!     *************"
```
## 附录
命令行输入HOME键：  
adb shell input keyevent 3

keycode在 KeyEvent.java (frameworks/base/core/java/android/view)
