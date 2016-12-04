---
title: Android 线程
date: 2015-08-01 11:10:09
category: Android_note
tag: [Thread]
toc: true
---

服务（Service）是Android中实现后台程序运行的方案。适合执行那些不需要和用户交互并长期执行的任务。

服务并非运行在一个独立的进程中，而是依赖于创建服务时所在的应用程序。当某个应用程序进程被杀掉时，所有依赖于该进程的服务都会结束。

服务并不会开启线程。所有的代码都默认运行在主线程里面。我们需要在服务的内部创建子线程，并在这里执行具体任务。

## 启动子线程
定义一个线程。启动线程需要new一个实例出来调用start方法。
```java
﻿class MyThread extends Thread{
    @Override
    public void run(){
        //do something
    }
}
new MyThread().start();    //start thread
```
使用Runnable接口的方式来定义一个线程。
```java
class MyThread implements Runnable{

    @Override
    public void run(){
        //do something
    }
}
MyThread myThread = new MyThread();
new myThread().start();
```
或者换一个写法，用匿名类的方式来写
```java
new Thread(new Runnable(){
    @Override
    public run(){
        //do something
}
}).start();
```

## Timer
Android中的定时器。  
每一个Timer是一个单独的后台线程，默认非守护线程。交给它的应该是耗时短的任务。  
多个线程可以由同一个timer来启动。

可以配合Handler来使用

```java
// 记录的时钟显示
private Timer mTimer;

mTimer = new Timer();

TimerTask recordTimerTask = new TimerTask() {
    int runningTime;

    @Override
    public void run() {
        runningTime++;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                // 控制格式输出
                mClockTv.setText(String.format(Locale.ENGLISH, "%02d:%02d",
                    runningTime / 60, runningTime % 60));
            }
        });
    }
};

mTimer.schedule(recordTimerTask, 1000, 1000);

// Terminates this timer, discarding any currently scheduled tasks.
// cancel后，如果要还要使用这个timer，需要再new一次
mTimer.cancel();
```

## 线程安全与性能相关

### 处理数据的线程应当适当sleep
假设需要一个不停循环的线程来处理实时数据。计算一下数据产生的时间间隔，让线程sleep一小段
时间。这样可以大大节省系统开销。

### 应主动结束子线程
当Activity或service结束时，要手动结束掉正在运行的子线程，撤销队列中的子线程。  
否则子线程有可能让应用崩溃。
