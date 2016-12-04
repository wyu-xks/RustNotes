---
title: Android - 单例控制器和UI
date: 2016-12-09 20:47:12
category: Android_note
tag: [Android_UI]
toc: true
---

## 目的
解耦。fragment跟随某个对象变换而改变UI。不论fragment销毁重建多少次，都能表现出目标对象的
状态。项目中需要实时监视一个对象，把目标对象的状态实时显示在屏幕上。

分层。分离成UI层和控制层。要更新UI的话，直接操作控制器。

Activity和Fragment中尽量不要持有线程。因为旋转屏幕时Activity会重建。线程的操作尽可能
放在控制器中，例如service。

## 做法
抽象成一个控制器（Controller），单例化目标对象。相关方法全部放在Controller中。
例如ViewController。

在Controller中提供监听器listener。fragment创建时增加监听回调，销毁时注销回调。[主动消除过期引用]

Controller添加主动更新状态的接口。每次fragment onResume，都请求Controller传送数据刷新。

因为Controller中有子线程，fragment要通过handler来更新UI。这个UIHandler掌握着所有的更新
操作。

例如这样一个`Controller.java`：

```java

public enum Action {
    ACTION1, ACTION2
}

public interface OnActionListener {
    void action(Action action);
}

private static volatile Controller controller;

public static Controller getController() {
    if (null == controller) {
        controller = new Controller();
    }
    return controller;
}

public void clearListener() {
    // 销毁监听器
}

```

fragment 创建时设置好监听器，销毁时取消监听器。

消息传递过程：
```
service --[Controller] --> fragment(handler)
```
Controller变换通知给了UI，由UI决定做什么样的操作，或者不操作。

对于app全局的状态改变，需要任何界面都做出反应，可以使用EventBus。
