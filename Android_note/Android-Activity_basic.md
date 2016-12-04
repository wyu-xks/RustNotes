---
title: Android Activity 基础概念
date: 2017-09-09 19:19:18
category: Android_note
toc: true
---

Activity 是一个应用组件，用户可与其提供的屏幕进行交互，以执行拨打电话、拍摄照片、发送电子邮件或查看地图等操作。每个 Activity 都会获得一个用于绘制其用户界面的窗口。窗口通常会充满屏幕，但也可小于屏幕并浮动在其他窗口之上。

[Google Guide Activities](https://developer.android.com/guide/components/activities.html)

### Activity任务，返回栈与启动模式
#### 任务（task），返回栈（back stack）
任务是指在执行特定作业时与用户交互的一系列 Activity。 这些 Activity 按照各自的打开顺序排列在堆栈（即返回栈）中。

#### Activity的4种启动模式
Manifest中的 launchMode 属性指定有关应如何将 Activity 启动到任务中的指令。您可以分配给 launchMode 属性的启动模式共有四种。

##### "standard"（默认模式）
默认。系统在启动 Activity 的任务中创建 Activity 的新实例并向其传送 Intent。Activity 可以多次实例化，而每个实例均可属于不同的任务，并且一个任务可以拥有多个实例。

##### "singleTop"
> 可以有多个实例，但是不允许多个相同Activity叠加。即，如果Activity在栈顶的时候，启动相同的Activity，不会创建新的实例，而会调用其onNewIntent方法。

目标作用是在栈顶添加activity实例或走栈顶activity的`onNewIntent()` 方法。若目标activity已在栈顶，则不会新建实例。

如果当前任务的顶部已存在 Activity 的一个实例，则系统会通过调用该实例的 onNewIntent() 方法向其传送 Intent，而不是创建 Activity 的新实例。Activity 可以多次实例化，而每个实例均可属于不同的任务，并且一个任务可以拥有多个实例（但前提是位于返回栈顶部的 Activity 并不是 Activity 的现有实例）。

例如，假设任务的返回栈包含根 Activity A 以及 Activity B、C 和位于顶部的 D（堆栈是 A-B-C-D；D 位于顶部）。收到针对 D 类 Activity 的 Intent。如果 D 具有默认的 "standard" 启动模式，则会启动该类的新实例，且堆栈会变成 A-B-C-D-D。但是，如果 D 的启动模式是 "singleTop"，则 D 的现有实例会通过 onNewIntent() 接收 Intent，因为它位于堆栈的顶部；而堆栈仍为 A-B-C-D。但是，如果收到针对 B 类 Activity 的 Intent，则会向堆栈添加 B 的新实例，即便其启动模式为 "singleTop" 也是如此。

注：为某个 Activity 创建新实例时，用户可以按“返回”按钮返回到前一个 Activity。 但是，当 Activity 的现有实例处理新 Intent 时，则在新 Intent 到达 onNewIntent() 之前，用户无法按“返回”按钮返回到 Activity 的状态。

##### "singleTask"
> 只有一个实例。在同一个应用程序中启动他的时候，若Activity不存在，则会在当前task创建一个新的实例，若存在，则会把task中在其之上的其它Activity destory掉并调用它的onNewIntent方法。

若目标activity已在栈中，则会销毁在目标activity之上的其他实例，此时目标activity来到栈顶。  

若目标activity是 “MAIN” activity，能被Launcher启动。那么按home键将App退到后台，在桌面上点击App图标。目标activity之上的页面都会被销毁掉，并调用目标activity的`onNewIntent()`方法。

系统创建新任务并实例化位于新任务底部的 Activity。但是，如果该 Activity 的一个实例已存在于一个单独的任务中，则系统会通过调用现有实例的 onNewIntent() 方法向其传送 Intent，而不是创建新实例。一次只能存在 Activity 的一个实例。

注：尽管 Activity 在新任务中启动，但是用户按“返回”按钮仍会返回到前一个 Activity。

##### "singleInstance"
> 只有一个实例，并且这个实例独立运行在一个task中，这个task只有这个实例，不允许有别的Activity存在。

与 "singleTask" 相同，只是系统不会将任何其他 Activity 启动到包含实例的任务中。该 Activity 始终是其任务唯一仅有的成员；由此 Activity 启动的任何 Activity 均在单独的任务中打开。

例如，A，B，C 3个Activity，只有B是以singleInstance模式启动，其他是默认模式。
页面启动顺序是 A -> B -> C，B会自己在一个task中；栈情况如下（方括号表示在前台）：
```
stack    |   | => |   | |   | => |   | |   | 
         |   |    |   | |   |    | C | |   | 
         | A |    | A | | B |    | A | | B | 
task id: [1082]   1082  [1083]   [1082] 1083
```
此时屏幕上显示是C的界面，按返回键，C被销毁，显示的是A的界面；再返回，A被销毁，原A和C所在的task结束。此时显示B的界面。

按返回键的变化情况
```
stack    |   |  |   | => |   |  |   | => |   | 
         | C |  |   |    |   |  |   |    |   | 
         | A |  | B |    | A |  | B |    | B | 
task id: [1082] 1083     [1082] 1083     [1083]
```

如果在只剩下B的时候，去启动C；由于B是singleInstance模式，B所在的栈只能有一个activity，则会新建一个task来存放C
```
stack     |   | => |   | |   | 
          |   |    |   | |   | 
          | B |    | B | | C | 
task id:  [1083]   1083  [1084]  
```

参阅
* http://blog.csdn.net/liuhe688/article/details/6754323
* [Activity、Task、应用和进程 - frank.sunny (cnblog)](http://www.cnblogs.com/franksunny/archive/2012/04/17/2453403.html)
