---
title: Android handler 可能会造成内存泄露
date: 2015-10-07 15:09:42
category: Android_note
tag: [Android]
---
Android Studio

使用 Handler 时；
```java
    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            // handle something
        }
    };
```
Android Studio 弹出了警告；
```
This Handler class should be static or leaks might occur (null) less... (Ctrl+F1)

Since this Handler is declared as an inner class, it may prevent the outer class from being garbage collected. If the Handler is using a Looper or MessageQueue for a thread other than the main thread, then there is no issue. If the Handler is using the Looper or MessageQueue of the main thread, you need to fix your Handler declaration, as follows: Declare the Handler as a static class; In the outer class, instantiate a WeakReference to the outer class and pass this object to your Handler when you instantiate the Handler; Make all references to members of the outer class using the WeakReference object.
```
如果这个Handler用的是主线程外的Looper或者消息队列就没事。若是在主线程中，Handler的消息还在队列中尚未被处理，GC有可能无法回收这个Handler；也就无法回收使用这个Handler的外部类（如Activity、Service），有可能引起OOM。
换句话说，当Activity结束时，延迟的消息还可能在消息队列中。消息引用这Activity的Handler，Handler持有着它的外部类（也就是这个Activity）。这个引用会持续到消息被处理，在此之前不会被GC。
Java中，非静态内部类和匿名类会引用了它们的外部类。

根据修改建议，按照提示进行修改，将handler声明为static。
```java
    static class rustHandler extends Handler {
        private final WeakReference<MySwipeActivity> mActivity;

        rustHandler(MySwipeActivity mySwipeActivity) {
            mActivity = new WeakReference<MySwipeActivity>(mySwipeActivity);
        }

        @Override
        public void handleMessage(Message msg) {
            MySwipeActivity activity = mActivity.get();
            if (activity != null) {
                // la la la la la ...
            }
        }
    }
```
静态类 rustHandler 中定义一个 WeakReference（弱引用）；利用这个若引用来完成操作。这样警告就消失了。

参考Android源码，也有这种做法，没有使用弱引用的
```java
    static class MyHandler extends Handler {
        MySwipeActivity handlerSwipeActivity;

        MyHandler(MySwipeActivity mySwipeActivity) {
            handlerSwipeActivity = mySwipeActivity;
        }

        @Override
        public void handleMessage(Message msg) {
            if (handlerSwipeActivity != null) {
                // do something
            }
        }
    }
```
同样消除了AS的警告；MyHandler 声明为 static，达到了目的

#### Java中的引用
java.lang.ref 类库包含了一组类，这些类为垃圾回收提供了更大的灵活性。
SoftReference WeakReference PhantomReference 由强到弱，对应不同级别的“可获得性”；越弱表示对垃圾回收器的限制越少，对象越容易被回收。

## Android L Handler
Handler可以发送和运行MessageQueue相关联的Message与Runnable对象；每个Handler实例与单个线程及线程的消息队列关联
创建一个Handler，它与线程/消息队列关联；它能分发消息和runnables给消息队列并执行它们

Handler的2个主要用法：
规划messages和runnables的执行时机
把一个action排到另一个线程中，并由那个线程执行

规划messages使用到：
post，参考`postAtTime(Runnable, long)`

#### 参考
http://www.androiddesignpatterns.com/2013/01/inner-class-handler-memory-leak.html
http://stackoverflow.com/questions/11407943/this-handler-class-should-be-static-or-leaks-might-occur-incominghandler
