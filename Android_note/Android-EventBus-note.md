---
title: Android EventBus使用注意事项
date: 2016-07-10 22:59:12
category: Android_note
tag: [EventBus]
---

使用EventBus 3.0.0 时  
除了注册和注销EventBus外，同时还需要使用它的接收方法
```java
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        EventBus.getDefault().register(this);
        // ......       
    }

    @Subscribe (threadMode = ThreadMode.MAIN)
    public void onEventXYZ(EventMsg msg) {
         // Must use EventBus function
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        EventBus.getDefault().unregister(this);
    }
```
onEventXYZ(EventMsg msg)是接收事件的方法。如果没有接收Event的方法，（荣耀和小米）实测会报错  
> java.lang.RuntimeException: Unable to start activity
> ComponentInfo{com.rustfisher.ndkproj/com.rustfisher.ndkproj.MainActivity}:
>  org.greenrobot.eventbus.EventBusException: Subscriber class com.rustfisher.ndkproj.MainActivity and
> its super classes have no public methods with the @Subscribe annotation

Activity 不可见时，onStop；仍可接收EventBus发来的消息。
