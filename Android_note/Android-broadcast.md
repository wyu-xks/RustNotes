---
title: Android 广播机制（Broadcast）介绍与使用
date: 2015-10-29 15:09:35
category: Android_note
tag: [Android]
---

Android应用可以通过广播从系统或其他App接收或发送消息。类似于订阅-发布设计模式。当某些事件发生时，可以发出广播。
系统在某些状态改变时会发出广播，例如开机、充电。App也可发送自定义广播。广播可用于应用间的通讯。

## 广播的种类
广播的种类也可以看成是广播的属性。  

#### 标准广播（Normal Broadcasts）
完全异步的广播。广播发出后，所有的广播接收器几乎同时接收到这条广播。
不同的App可以注册并接到标准广播。例如系统广播。

#### 有序广播（Ordered Broadcasts）
同步广播。同一时刻只有一个广播接收器能接收到这条广播。这个接收器处理完后，广播才会继续传递。
有序广播是全局的广播。

#### 本地广播（Local Broaddcasts）
只在本App发送和接收的广播。注册为本地广播的接收器无法收到标准广播。

#### 带权限的广播
发送广播时可以带上相关权限，申请了权限的App或广播接收器才能收到相应的带权限的广播。
如果在manifest中申请了相应权限，接收器可以不用再申请一次权限即可接到相应广播。

## 接收广播
创建广播接收器，调用`onReceive()`方法，需要一个继承BroadcastReceiver的类。

### 注册广播
代码中注册称为动态注册。在AndroidManifest.xml中注册称为静态注册。动态注册的刚波接收器一定要取消注册。在onDestroy()方法中调用unregisterReceiver()方法来取消注册。

不要在onReceive()方法中添加过多的逻辑操作或耗时的操作。因为在广播接收器中不允许开启线程，当onReceive()方法运行较长时间而没结束时，程序会报错。因此广播接收器一般用来打开其他组件，比如创建一条状态栏通知或启动一个服务。

新建一个MyExampleReceiver继承自BroadcastReceiver。
```java
public class MyExampleReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        Toast.makeText(context,"Got it",Toast.LENGTH_SHORT).show();
        //abortBroadcast();                              
    }
}
```
`abortBroadcast()`可以截断有序广播

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

## 发送广播
App有3种发送广播的方式

### sendOrderedBroadcast(Intent, String)
发送有序广播。每次只有1个广播接收器能接到广播。
接收器接到有序广播后，可以完全地截断广播，或者传递一些信息给下一个接收器。
有序广播的顺序可受`android:priority`标签影响。同等级的接收器收到广播的顺序是随机的。

### sendBroadcast(Intent)
以一个未定义的顺序向所有接收器发送广播。也称作普通广播。
这种方式更高效，但是接收器不能给下一个接收器传递消息。这类广播也无法截断。

### LocalBroadcastManager.sendBroadcast
广播只能在应用程序内部进行传递，并且广播接收器也只能接收到来自本应用程序发出的广播。
这个方法比全局广播更高效（不需要Interprocess communication，IPC），而且不需要担心其它App会收到你的广播以及其他安全问题。

## 广播与权限

### 发送带着权限的广播
当你调用`sendBroadcast(Intent, String)`或`sendOrderedBroadcast(Intent, String, BroadcastReceiver, Handler, int, String, Bundle)`时，你可以指定一个权限。  
接收器在manifest中申请了相应权限时才能收到这个广播。

例如发送一个带着权限的广播
```java
sendBroadcast(new Intent("com.example.NOTIFY"),
              Manifest.permission.SEND_SMS);
```

接收广播的app必须注册相应的权限
```xml
<uses-permission android:name="android.permission.SEND_SMS"/>
```

当然也可以使用自定义[permission](https://developer.android.com/guide/topics/manifest/permission-element.html)。在manifest中使用permission标签
```xml
<permission android:name="custom_permission" />
```
添加后编译一下。即可调用`Manifest.permission.custom_permission`

### 接收带权限的广播
若注册广播接收器时申明了权限，那么只会接收到带着相应权限的广播。

在配置文件中声明权限，程序才能访问一些关键信息。
例如允许查询系统网络状态。
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

<!-- 机器开机广播 -->
<uses-permission android:name="android.permission.BOOT_COMPLETED">
```
如果没有申请权限，程序可能会意外关闭。

## 标准广播，本地广播，带权限的广播，有序广播使用示例
发送和接收广播。分为发送和接收方2个App。  

使用带权限的广播。系统权限与自定义权限。
使用权限需要在AndroidManifest.xml中声明。如果是自定义权限，需要先添加自定义权限。
```xml
    <!-- 自定义的权限  给广播用 -->
    <permission android:name="com.rust.permission_rust_1" />
    <uses-permission android:name="com.rust.permission_rust_1" />
```

发送广播时带上权限声明。  
接收方（不论是否己方App）需要在`AndroidManifest.xml`中申请权限。
注册接收器时也需要声明权限。

发送不带权限的有序广播
```java
    /**
     * 发送不带权限的有序广播
     */
    private void sendStandardOrderBroadcast() {
        Intent intent = new Intent(MSG_PHONE);
        sendOrderedBroadcast(intent, null);
        Log.d(TAG, "[App1] 发送不带权限的有序广播, " + intent.getAction());
    }
```

发送方App1代码
```java
    private static final String TAG = "rustApp";
    public static final String MSG_PHONE = "msg_phone";
    public static final String PERMISSION_RUST_1 = "com.rust.permission_rust_1";

        // 注册广播接收器
        registerReceiver(mStandardReceiver1, makeIF());
        registerReceiver(mStandardReceiver2, makeIF());
        registerReceiver(mStandardReceiver3, makeIF());

        registerReceiver(mStandardReceiverWithPermission, makeIF(),
                Manifest.permission.permission_rust_1, null);  // 带上权限

        LocalBroadcastManager.getInstance(getApplicationContext())
                .registerReceiver(mLocalReceiver1, makeIF());
        LocalBroadcastManager.getInstance(getApplicationContext())
                .registerReceiver(mLocalReceiver2, makeIF());
        LocalBroadcastManager.getInstance(getApplicationContext())
                .registerReceiver(mLocalReceiver3, makeIF());

        // 解除接收器
        unregisterReceiver(mStandardReceiver1);
        unregisterReceiver(mStandardReceiver2);
        unregisterReceiver(mStandardReceiver3);

        unregisterReceiver(mStandardReceiverWithPermission);

        LocalBroadcastManager.getInstance(getApplicationContext())
                .unregisterReceiver(mLocalReceiver1);
        LocalBroadcastManager.getInstance(getApplicationContext())
                .unregisterReceiver(mLocalReceiver2);
        LocalBroadcastManager.getInstance(getApplicationContext())
                .unregisterReceiver(mLocalReceiver3);


    // 发送标准广播
    private void sendStandardBroadcast() {
        Intent intent = new Intent(MSG_PHONE);
        sendBroadcast(intent);
        Log.d(TAG, "[App1] Dispatcher 发送标准广播");
    }

    // 发送带权限的标准广播
    private void sendStandardBroadcastWithPermission() {
        Intent intent = new Intent(MSG_PHONE);
        sendBroadcast(intent, PERMISSION_RUST_1);
        Log.d(TAG, "[App1] Dispatcher 发送带权限的标准广播");
    }

    // 发送本地广播
    private void sendAppLocalBroadcast() {
        Intent intent = new Intent(MSG_PHONE);
        LocalBroadcastManager.getInstance(getApplicationContext()).sendBroadcast(intent);
        Log.d(TAG, "[App1] Dispatcher 发送本地广播");
    }

    private IntentFilter makeIF() {
        IntentFilter intentFilter = new IntentFilter(MSG_PHONE);
        intentFilter.addAction(Intent.ACTION_TIME_TICK);
        intentFilter.addAction(Intent.ACTION_TIME_CHANGED);
        return intentFilter;
    }

    // 标准接收器  用context来注册
    private BroadcastReceiver mStandardReceiver1 = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "[App1] 标准接收器1 收到: " + intent.getAction());
        }
    };

    // 标准接收器  用context来注册
    private BroadcastReceiver mStandardReceiver2 = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "[App1] 标准接收器2 收到: " + intent.getAction());
            if (intent.getAction().endsWith(MSG_PHONE)) {
                abortBroadcast(); // 截断有序广播
                Log.d(TAG, "[App1] 标准接收器2截断有序广播 " + intent.getAction());
            }
        }
    };

    // 标准接收器  用context来注册
    private BroadcastReceiver mStandardReceiver3 = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "[App1] 标准接收器3 收到: " + intent.getAction());
        }
    };

    // 注册的时候给它带权限  标准接收器
    private BroadcastReceiver mStandardReceiverWithPermission = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "[App1] 带权限的标准接收器收到: " + intent.getAction());
        }
    };

    /**
     * 用LocalBroadcastManager来注册成为本地接收器
     * 收不到标准广播 - 不论是本app发出的还是别的地方发出来的
     */
    private BroadcastReceiver mLocalReceiver1 = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "[App1] 本地接收器1 收到: " + intent.getAction());
        }
    };

    private BroadcastReceiver mLocalReceiver2 = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "[App1] 本地接收器2 收到: " + intent.getAction());
        }
    };

    private BroadcastReceiver mLocalReceiver3 = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "[App1] 本地接收器3 收到: " + intent.getAction());
        }
    };

```

接收方App2代码
```xml
    <!-- 自定义的权限  给广播用 -->
    <permission android:name="com.rust.permission_rust_1" />
    <uses-permission android:name="com.rust.permission_rust_1" />
```

```java
public static final String MSG_PHONE = "msg_phone";
        registerReceiver(mDefaultReceiver, makeIF());
        LocalBroadcastManager.getInstance(getApplicationContext())
                .registerReceiver(mLocalReceiver, makeIF());

        unregisterReceiver(mDefaultReceiver);
        LocalBroadcastManager.getInstance(getApplicationContext())
                .unregisterReceiver(mLocalReceiver);


    private BroadcastReceiver mDefaultReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "[App2] standard receive: " + intent.getAction());
        }
    };

    private BroadcastReceiver mLocalReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            Log.d(TAG, "[App2] local receive: " + intent.getAction());
        }
    };

    private IntentFilter makeIF() {
        IntentFilter intentFilter = new IntentFilter(MSG_PHONE);
        intentFilter.addAction(Intent.ACTION_TIME_TICK);
        intentFilter.addAction(Intent.ACTION_TIME_CHANGED);
        return intentFilter;
    }
```

使用`LocalBroadcastManager`发出的本地广播，另一个App是接收不到的。
要收到本地广播，同样需要`LocalBroadcastManager`来注册接收器。

可以把本地广播看成是一个局部的，App内的广播体系。

实验中我们注意到，`Intent.ACTION_TIME_TICK`广播是可以截断的。
