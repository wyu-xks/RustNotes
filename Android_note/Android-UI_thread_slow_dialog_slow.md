---
title: Android - 点击弹出dialog响应太慢，更新界面出现卡顿
date: 2016-10-26 07:47:12
category: Android_note
tag: [Android_UI]
toc: true
---


### 点击Button，过了快1秒才响应并弹出dialog

UI线程做了太多的事情。可以检查UI线程里各个方法的起止时间。看是哪个方法耗时较大。
对于要频繁调用的dialog，可以实例化化一个，然后反复调用同一个dialog。
在dialog中OnStart方法里重置需要的状态。

### 利用EventBus更新UI造成的卡顿
对于EventBus，发送的事件并不能保证很快（1ms内）就被收到。会有“堵车”的现象。

为避免堵塞UI线程，可以走异步`@Subscribe(threadMode = ThreadMode.ASYNC)`模式。
然后用handler来更新UI。这样可以尽量避免堵塞主线程，界面卡顿等等问题。

在EventBus注册前，先初始化好各个控件和handler。

Fragment的动画切换都是用Transaction实现，如果你pop in的那个fragment卡顿，说明其onCreateView方法太消耗资源，可以把重点放在优化fragment上面，而不是优化动画。
