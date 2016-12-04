---
title: 监听者模式 Listener pattern in Java and Android
date: 2015-05-16 22:11:01
category: Design_pattern
tag: [Java]
toc: true
---

监听者模式（观察者模式）能降低对象之间耦合程度。为两个相互依赖调用的类进行解耦。
便于进行模块化开发工作。不同模块的开发者可以专注于自身的代码。   
监听者用来监听自已感兴趣的事件，当收到自已感兴趣的事件时执行自定义的操作。  
在某些数据变化时，其他的类做出一些响应。处理数据（或者分发事件）的类主动投送消息，感兴趣
的类主动“订阅”消息。

监听者模式在Android中有大量的运用，相信大家都不会感到陌生。在Android开发中，Button控件的
点击事件就是监听者模式最常见的例子。  
当Button被点击，执行了 `OnClickListener.onClick`；Activity中给这个Button设置了自己实现
的`OnClickListener`，并复写了`onClick`方法，就能执行自定义操作了。

### Java代码实例
下面来用Java来实现监听者模式。  
这个例子是给“计算类”持续地传入数据，处理好数据后，发出结果。感兴趣的类接收结果。  
2个文件：`AlgoCalculator.java`；`MainUser.java`  
* `AlgoCalculator.java`是计算部分，接收数据并进行计算。并将结果传递出去。
* `MainUser.java`是调用方，将基本数据传入AlgoCalculator并监听结果。

```java
package com.algo;

import java.util.LinkedList;
import java.util.List;

public class AlgoCalculator {

    private List<short[]> mDataBuffer = new LinkedList<>();

    public AlgoCalculator() {

    }

    // 定义一个Listener接口；可将一个boolean值传递出去
    public interface ResultChangeListener {
        void onChange(boolean found);
    }

    private ResultChangeListener resultChangeListener;
    // 调用方能够设置并实现这个接口
    public void setResultChangedListener(ResultChangeListener resultChangedListener) {
        this.resultChangeListener = resultChangedListener;
    }
    // 传输数据
    public void setDataStream(short[] data) {
        checkData(data);// 处理数据方法
    }

    // 处理数据，并送出结果
    private void checkData(short[] data) {
        if (data.length == 0) {
            return;
        }
        long sum = 0;
        for (short b : data) {
            sum += b;
        }
        if (sum > 40) {
            resultChangeListener.onChange(true); // 数据处理结果
        } else {
            resultChangeListener.onChange(false);
        }
    }
}
```

主程序；调用方传入数据，获取结果
```java
import com.algo.AlgoCalculator;

public class MainUser {
    public static void main(String[] args) {
        AlgoCalculator algoCalculator = new AlgoCalculator(); // 初始化

        // 设置监听器，并在里面增加要执行的动作
        algoCalculator.setResultChangedListener(new AlgoCalculator.ResultChangeListener() {
            @Override
            public void onChange(boolean found) {
                System.out.println("result: " + found);
            }
        });
        short[] data1 = {1, 2, 3,};
        short[] data2 = {10, 20, 30};
        short[] data3 = {6, 7, 8};
        short[] data4 = {1, 1, 1};
        // 传入数据
        algoCalculator.setDataStream(data1);    // output false
        algoCalculator.setDataStream(data2);    // output true
        algoCalculator.setDataStream(data3);    // output false
        algoCalculator.setDataStream(data4);    // output false
    }
}
```
在另外的类里，能够很方便地调用`AlgoCalculator`的计算能力并获取计算结果。
在这里，每传入一次数据，就能获取一个结果。如果每秒钟传入一次数据，每秒钟就能获取一个结果。
我们可以把复杂的算法封装起来，客户端只需要传入数据，即可获得（监听到）结果。  

很多场景中都使用了监听者模式。程序员也可能在不知不觉中就运用了这个模式。

### Android中使用监听器
最常见的例子是给Button设置点击事件监听器

类似上个例子，设计一个接口当做监听器。Android中回调时可以利用handler，控制调用的线程。
```java
private Handler mMainHandler;

mMainHandler = new Handler(Looper.getMainLooper());// 在主线程中运行

private void notifySthChange(final int state) {
    mMainHandler.post(new Runnable() {
        @Override
        public void run() {
            ArrayList<SListener> list = new ArrayList<>(mListeners);
            for (SListener l : list) {
                l.OnSthChanged(state);
            }
        }
    });
}
```
在回调中可以直接更新UI。
