---
title: 刷机方法
date: 2015-07-20 22:11:36
category: Tools
tag: [Android_flash]
---

### 启动adb的方法：
```bash
lsusb
sudo gedit /etc/udev/rules.d/51-android.rules
sudo restart udev
```
连接机器，lsusb找到usb 的 ID：
Bus 003 Device 047: ID 05c6:9039 CompanyName, Inc.

打开51-android.rules新增一行代码：
```
SUBSYSTEM=="usb", ATTRS{idVendor}=="05c6", ATTRS{idProduct}=="9091", MODE="0666", SYMLINK+="android_adb"
```
注意修改51-android.rules权限  
最后重启udev服务即可

### 机器进入lk之后，长按 power + volume down 进fastboot模式

### 查看系统user，user-debug，eng版本：
找到 ro.build.type 这个属性
```bash
adb shell
cd system/
cat build.prop
```
