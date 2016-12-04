---
title: Android Daydream 互动屏保
date: 2015-11-01 15:09:37
category: Android_note
tag: [Android]
---
API19 API23
Create:2016-03-01

继承DreamService来实现一个自定义屏保
Dreams是当充电的设备空闲，或者插入底座时显示的互动屏保。在展览或陈列时，Dreams为APP提供一个定制的展示方式。

## DreamService的生命周期

1.onAttachedToWindow()
初始化设置，在这里可以调用 setContentView()

2.onDreamingStarted()
互动屏保已经启动，这里可以开始播放动画或者其他操作

3.onDreamingStopped()
在停止 onDreamingStarted() 里启动的东西
4.onDetachedFromWindow()
在这里回收前面调用的资源（比如 handlers 和 listeners）

另外，onCreate 和 onDestroy 也会被调用。但要复写上面的几个方法来执行初始化和销毁操作。

## manifest 声明
为了能让系统调用，你的 DreamService 应该在 APP 的 manifest 中注册：
```xml
 <service
     android:name=".MyDream"
     android:exported="true"
     android:icon="@drawable/my_icon"
     android:label="@string/my_dream_label" >
     <intent-filter>
         <action android:name="android.service.dreams.DreamService" />
         <category android:name="android.intent.category.DEFAULT" />
     </intent-filter>
     <!-- Point to additional information for this dream (optional) -->
     <meta-data
         android:name="android.service.dream"
         android:resource="@xml/my_dream" />
 </service>
```
如果填写了 `<meta-data>` 元素，dream的附加信息就被指定在XML文件的 `<dream>` 元素中。

通常提供的附加信息是对互动屏保的自定义设置，指向一个自己写的Activity。
比如：`res/xml/my_dream.xml`
```xml
 <dream xmlns:android="http://schemas.android.com/apk/res/android"
     android:settingsActivity="com.example.app/.MyDreamSettingsActivity" />
```
这样在Settings-Display-Daydream-你的Daydream选项右边会出现一个设置图标。点击此图标可打开指定的activity。

当目标api>=21，必须在manifest中申请`BIND_DREAM_SERVICE`权限，比如：
```xml
 <service
     android:name=".MyDream"
     android:exported="true"
     android:icon="@drawable/my_icon"
     android:label="@string/my_dream_label"
     android:permission="android.permission.BIND_DREAM_SERVICE">
   <intent-filter>
     <action android:name=”android.service.dreams.DreamService” />
     <category android:name=”android.intent.category.DEFAULT” />
   </intent-filter>
 </service>
```
如果不申请权限，这个互动屏保将无法启动并有类似报错：
system_process W/ActivityManager: Unable to start service Intent { act=android.service.dreams.DreamService flg=0x800000 cmp=com.google.android.deskclock/com.android.deskclock.Screensaver } U=0: not found
system_process E/DreamController: Unable to bind dream service: Intent { act=android.service.dreams.DreamService flg=0x800000 cmp=com.google.android.deskclock/com.android.deskclock.Screensaver }
system_process I/DreamController: Stopping dream: name=ComponentInfo{com.google.android.deskclock/com.android.deskclock.Screensaver}, isTest=false, canDoze=false, userId=0

## demo
`AndroidManifest.xml` 注册这个service；里面指定的图标和标题都显示在设置中
```xml
        <service
            android:name="com.rust.service.MyDayDream"
            android:exported="true"
            android:icon="@drawable/littleboygreen_x128"
            android:label="@string/my_day_dream_label"
            android:permission="android.permission.BIND_DREAM_SERVICE">
            <intent-filter>
                <action android:name="android.service.dreams.DreamService" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>
        </service>
```

`MyDayDream.java` 互动屏保的定义
```java
package com.rust.service;

import android.service.dreams.DreamService;

import com.rust.aboutview.R;

public class MyDayDream extends DreamService {

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        // Exit dream upon user touch
        setInteractive(false);
        // Hide system UI
        setFullscreen(true);
        // Set the dream layout
        setContentView(R.layout.my_day_dream);
    }

}
```

`my_day_dream.xml` 互动屏保的布局文件；只有一行字
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/my_day_dream_label"
        android:textColor="@color/colorRed"
        android:textSize="30sp" />
</LinearLayout>
```
在Settings-Display-Daydream中可以找到新增的选项

![](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Android_note/pics/daydream_settings.png)
