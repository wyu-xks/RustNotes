---
title: Android-Binder
date: 2015-10-26 15:09:31
category: Android_note
tag: [Android_frameworks]
---
Android5.1

Android使用Linux的进程管理机制，以进程为单位分配虚拟地址空间。  
为保证安全，不同进程之间是相互隔离的。Android**进程间使用Binder方式进行通讯**。

Service组件所在的进程称为Server进程，使用Service的组件所在进程称为Client进程，C/S体系结构。  
C/S体系结构通常由以下部分组成：  
用户端（Client）：是C/S体系结构中使用server端提供Service的一方  
服务端（Server）是C/S体系结构中为Client端提供Service的一方  
服务代理（Proxy）位于Client端，提供访问服务的接口  
服务存根（Stub）：位于Server端，屏蔽Proxy与Server端通信的细节  
服务（Service）：运行与Server端，提供具体的功能处理Client端的请求  
通信协议：Client和Server可以运行在不同的进程中，主要用Binder作为通信协议

组件servicemanager（本身也是一个Server），提供了Service注册和Service检索功能。它自身维护一个Service信息列表。Client只需向servicemanager提供所需Service名字，便可获取Service信息。

app启动时，或者进行广播时，都会进入ActivityManagerNative.java中的类ActivityManagerProxy  
app启动startActivity；广播使用broadcastIntent；进入ActivityManagerService，调用相应的方法


#### AIDL 统一的通信接口
AIDL（Android Interface Definition Language, Android 接口定义语言）  
用于定义C/S体系结构中Server端可以提供的服务调用接口，框架层提供的Java系统服务接口大多由AIDL语言定义。Android提供了AIDL工具，可将AIDL文件编译成Java文件。提高服务开发的效率

AIDL文件路径放入Android.mk文件中，编译时自动将其转换为Java文件。 frameworks/base/core/java/android/os/IPowerManager.aidl  
比如 IPowerManager.aidl 文件编译转化成比如 IPowerManager.java；编译得到的文件位置  
out/target/common/obj/JAVA_LIBRARIES/framework_intermediates/src/core/java/android/os/IPowerManager.java

开发人员只需要在AIDL文件中定义Server端可以提供的服务方法，AIDL工具便可将其转化为Java文件。转化后的Java文件包含C/S体系结构的以下内容：
- 服务接口 （IPowerManager）
- 服务在Client端的代理（Proxy）
- 服务存根（Stub）
- Binder类型与IIterface类型的转换接口（asInterface 和 asBinder 方法）
- 服务方法请求码

AIDL意义：  
AIDL工具建立了基于Binder的C/S体系结构的通用组件；
开发者可以专注于开发服务的功能，而不需理会具体的通信结构，提高效率

//##### AIDL语法
