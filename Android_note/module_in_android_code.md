---
title: App中的模块化
date: 2016-11-19 10:55:01
category: Android_note
---

### 重构工程，模块化思路和步骤
* 新建模块
* 移动枚举类和接口
* 移动工具类
* 减少全局变量，尽可能消除对Application的直接引用
* 移动执行最小操作的类
* 增加回调接口，增加通知方法，移动其他类
* 设计对外统一访问管理的类

### Android 蓝牙管理模块
Android中需要调用蓝牙设备。

一开始是在Service中管理蓝牙设备的连接和业务。随着业务代码的增长，蓝牙的连接部分日趋复杂和混乱。
整个Service的代码也再变大。业务要求针对同一款蓝牙硬件设备开发出不同的App。各个App要实现的功能不同。
为避免大量的重复代码，需要将这个蓝牙设备管理模块化。

单例化一个`BtDevice`，相关信息都存储在单例中，可以直接调用。参照Google示例，在子线程中进行蓝牙连接。
`BtDevice`模块与Service解耦。添加回调接口，发送蓝牙设备发回的数据。
App中有多个activity，各个页面生命周期不同。app主工程中增设一个消息管理Service，专门用于接受BtService的数据，
然后再用别的方法发送出去（EventBus，Broadcast等）。

在Android Studio中新建一个module，把蓝牙管理相关的代码放进模块，调整好API。编译后会有aar文件。
新的工程只需要引入aar文件即可。

模块化后，代码层级和逻辑更清晰，耦合度下降，更易维护。

### xml中找不到module中的自定义view
* Android Studio 2.2.3 

模块的build和调用方的build的配置要一致，最好全部配置成一样的。

比如compileSdkVersion等等。然后重新make module和rebuild project
