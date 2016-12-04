---
title: Android Activity 启动流程分析
date: 2017-09-06 21:58:58
category: Android_note
tag: [Android_frameworks,RTFSC]
---

|Android版本|IDE|
|:-----|:-----|
|API 25|Android Studio|

## Activity相关，预备知识

[必备] Binder相关说明，可参阅 http://rustfisher.github.io/2015/10/26/Android_note/Android-Binder/

### `ProcessRecord` - 表示一个正在进行的进程的所有信息
uid是进程的用户id；pid是应用所在进程的ID；
```java
final ApplicationInfo info; // all about the first app in the process
final boolean isolated;     // true if this is a special isolated process
final int uid;              // uid of process; may be different from 'info' if isolated
final int userId;           // user of process.
int pid;                    // The process of this application; 0 if none
```

### `ActivityRecord` - 能代表一个activity
An entry in the history stack, representing an activity.  
这个类里持有activity的很多信息，资源信息、启动时间戳等等

### `ActivityStartInterceptor` - 表示应用拦截的逻辑信息
A class that contains activity intercepting logic for {@link ActivityStarter#startActivityLocked}
It's initialized  
里面的属性已经初始化。

### `Instrumentation`
package android.app;

Instrumentation是执行application instrumentation代码的基类。当应用程序运行的时候instrumentation处于开启，Instrumentation将在任何应用程序运行前初始化，可以通过它监测系统与应用程序之间的交互。Instrumentation implementation通过的AndroidManifest.xml中的<instrumentation>标签进行描述。

内部类 `ActivityResult` - 目标activity执行结果的描述，返回给调用方的activity  
方法`execStartActivity`，供application调用来执行“startActivity”操作

### `ActivityThread` - 在应用进程中管理主线程的操作
This manages the execution of the main thread in an
application process, scheduling and executing activities,
broadcasts, and other operations on it as the activity
manager requests.

在应用进程中管理主线程的操作，比如计划和启动activity，广播以及activity manager的其他操作请求。  
内部类`ApplicationThread`，并持有实例`mAppThread`

### `ActivityStarter` - 用于启动activity
`package com.android.server.am;`  
控制着activity的启动方式和时机。通过intent和flag来要启动的activity以及相应的task和栈。

Controller for interpreting how and then launching activities.
This class collects all the logic for determining how an intent and flags should be turned into
an activity and associated task and stack.

### `interface IApplicationThread` - 系统用于与application交互的接口
activity manager可通过这个接口来操作application

## 流程分析

![Activity Manager相关的流程图](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Android_note/pics/activity-manager-flow.gif)

图片来自 https://izobs.gitbooks.io/android-framework-development-guide/content/activitymanager/activity_manager_flow.html

### Launcher启动Activity流程小结
整个应用程序的启动过程要执行很多步骤，但是整体来看，主要分为以下几个阶段：

* 1.应用的启动是从其他应用调用startActivity开始的。通过代理请求AMS启动Activity。
* 2.AMS创建进程，并进入ActivityThread的main入口。在main入口，主线程初始化，并loop起来。主线程初始化，主要是实例化ActivityThread和ApplicationThread，以及MainLooper的创建。ActivityThread和ApplicationThread实例用于与AMS进程通信。
* 3.应用进程将实例化的ApplicationThread,Binder传递给AMS，这样AMS就可以通过代理对应用进程进行访问
* 4.AMS通过代理，请求启动Activity。ApplicationThread通知主线程执行该请求。然后，ActivityThread执行Activity的启动。Activity的启动包括，Activity的实例化，Application的实例化，以及Activity的启动流程：create、start、resume。

Activity启动另一个Activity过程类似

参阅 https://izobs.gitbooks.io/android-framework-development-guide/content/activitymanager/activity_manager_flow.html  
http://www.cloudchou.com/android/post-788.html

#### AMS（ActivityManagerService）启动activity
简化掉进程间通讯后，大致流程如下

* AMS创建进程
* 在进程中新建ActivityThread实例和ApplicationThread实例
* ActivityThread.main方法中，初始化主线程，创建MainLooper
* 启动Activity，onCreate...
