---
title: Android Activity OOM bug
date: 2016-07-21 22:01:40
category: Android_note
tag: [Android_debug]
---
Parrot SDK Sample OOM 问题

进入activity，再退出activity。第三次进入activity时，app崩溃。  

使用Android Studio 的 Monitor来查看Memory使用情况。发现退出activity后，memory并没有被释放。
实际上当前Activity并没有被销毁。

```
java.lang.OutOfMemoryError: Failed to allocate a 1064892 byte allocation with 299528 free bytes and 292KB until OOM
at dalvik.system.VMRuntime.newNonMovableArray(Native Method)
at android.graphics.BitmapFactory.nativeDecodeAsset(Native Method)
```

传context时，参照的是官方SDK

[Parrot SDKSample](https://github.com/Parrot-Developers/Samples/blob/master/Android/SDKSample/app/src/main/java/com/parrot/sdksample/activity/MiniDroneActivity.java)

修改方法：
```java
mMiniDrone = new MiniDrone(this, service);// 这里把activity实例送进去了
mMiniDrone.addListener(mMiniDroneListener);
```
应该改成
```java
mMiniDrone = new MiniDrone(getApplicationContext(), service);
mMiniDrone.addListener(mMiniDroneListener);
```
这样就可以销毁整个activity了。

使用Android Studio的Monitors工具，可以看到内存的实时使用情况。

![monitors](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Android_note/pics/as_monitors_view.png)


在`DronesListActivity.java`中同样有这个错误
```java
mDroneDiscoverer = new DroneDiscoverer(this);// SDKSample又把activity实例传进去了
```

`DroneDiscoverer.java`
```java
//......
    public DroneDiscoverer(Context ctx) {
        mCtx = ctx;

        mListeners = new ArrayList<>();

        mMatchingDrones = new ArrayList<>();

        mArdiscoveryServicesDevicesListUpdatedReceiver = new ARDiscoveryServicesDevicesListUpdatedReceiver(mDiscoveryListener);
    }
```
