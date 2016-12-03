---
title: Android 广播机制（Broadcast）
date: 2015-10-29 15:09:35
category: Android_note
tag: [Android]
---
[TOC]

### 标准广播（Normal Broadcasts）
完全异步的广播。广播发出后，所有的广播接收器几乎同时接收到这条广播
### 有序广播（Ordered Broadcasts）
同步广播。同一时刻只有一个广播接收器能接收到这条广播。这个接收器处理完后，广播才会继续传递。

### 注册广播。
在代码中注册称为动态注册。在AndroidManifest.xml中注册称为静态注册。动态注册的刚波接收器一定要取消注册。在onDestroy()方法中调用unregisterReceiver()方法来取消注册。

#### 创建广播接收器：
调用onReceive()方法，需要一个继承BroadcastReceiver()的类。

不要在onReceive()方法中添加过多的逻辑操作或耗时的操作。因为在广播接收器中不允许开启线程，当onReceive()方法运行较长时间而没结束时，程序会报错。因此广播接收器一般用来打开其他组件，比如创建一条状态栏通知或启动一个服务。

新建一个MyExampleReceiver继承自BroadcastReceiver。
```java
public class MyExampleReceiver extends BroadcastReceiver{
    @Override
    public void onReceive(Context context, Intent intent){
        Toast.makeText(context,"Got it",Toast.LENGTH_SHORT).show();
        //abortBroadcast();                              
    }
}
```
abortBroadcast();可以截断有序广播

在AndroidManifest.xml中注册广播接收器；name里填接收器的名字。
可以设置广播接收器优先级：
```xml
<intent-filter android:priority="100">

<receiver android:name=".MyExampleReceiver">
    <intent-filter>
        <action android:name="com.rust.broadcasttest.MY_BROADCAST"/>
    </intent-filter>
</receiver>
```
让接收器接收到一条“com.rust.broadcasttest.MY_BROADCAST”广播。  
发送自定义广播（标准广播）时，要传送这个值。例如：
```java
Intent intent = new Intent("com.rust.broadcasttest.MY_BROADCAST");
sendBroadcast(intent);
```
发送有序广播，应当调用sendOrderedBroadcast()；
```java
Intent intent = new Intent("com.rust.broadcasttest.MY_BROADCAST");
sendOrderedBroadcast(intent，null);
```

#### 本地广播
广播只能在应用程序内部进行传递，并且广播接收器也只能接收到来自本应用程序发出的广播。
本地广播无法静态注册。比全局广播更加高效。
用LocalBroadcastManager管理广播。将其实例化getInstance()，调用发送广播和注册广播接收器的方法。

--> sendBroadcast();--> registerReceiver();

在配置文件中声明权限，程序才能访问一些关键信息。
例如允许查询系统网络状态。
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

<!-- 机器开机广播 -->
<uses-permission android:name="android.permission.BOOT_COMPLETED">
```
如果没有申请权限，程序可能会意外关闭。
