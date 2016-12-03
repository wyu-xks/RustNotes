---
title: RTFSC Android WallpaperManagerService
date: 2015-12-20 20:11:36
category: Android_note
tag: [RTFSC]
---
Android5.1;  Ubuntu14.04

不知道怎么解读源代码比较好，如果是照着代码翻译成中文，那还不如RTFSC

第一步，找出service主要实现的功能  
第二步，解释一下这些功能是怎么实现的

##### WallpaperManagerService.java
(base/services/core/java/com/android/server/wallpaper)  
继承自IWallpaperManager.Stub (framework/base/core/java/android/app/IWallpaperManager.aidl)

功能1：根据userId取得壁纸文件File  
功能2：方法systemRunning，在用户账户停止或删除时执行  
功能3：用户账户停止时，删除壁纸；删除用户账户时，删除壁纸文件  
功能4：更新壁纸和设置壁纸  

##### 内部类
包含内部类有： WallpaperData WallpaperObserver WallpaperConnection MyPackageMonitor  

###### WallpaperData类，看下面这个构造函数
```java
WallpaperData(int userId) {
    this.userId = userId;
    wallpaperFile = new File(getWallpaperDir(userId), WALLPAPER);
}
```
通过userId来找到壁纸文件

###### WallpaperConnection类
继承自IWallpaperConnection.Stub；需要复写几个方法，完成service与manager的连接

继承的文件位置(framework/base/core/java/android/service/wallpaper/IWallpaperConnection.aidl)  
类中复写了连接和解除连接时的方法  
setWallpaper方法调用了updateWallpaperBitmapLocked(name, mWallpaper)方法，准备好设置壁纸

###### MyPackageMonitor类
监视package的一系列动作，做出反应  
比如检测到（观察log）  
onPackageModified ---- com.android.vending  
onPackageModified ---- com.google.android.gms  

###### WallpaperObserver类
继承自FileObserver，监视wallpaper（壁纸）的变化  
每次更改壁纸，CLOSE_WRITE都会被触发；没有设置壁纸，会触发一次CREATE  
实例化一个BackupManager，调用当前绑定的服务的dataChanged方法  
设置壁纸时，打印log，发现调用了com.android.server.backup.Trampoline的dataChanged方法
