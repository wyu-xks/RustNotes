---
title: Android Handler 机制 - Looper，Message，MessageQueue
date: 2017-06-07 23:23:11
category: Android_note
tag: [Android]
toc: true
---

|Android|IDE|
|:------:|:------:|
|API 25|Android Studio 2.3|

从源码角度分析Handler机制。有利于使用Handler和分析Handler的相关问题。

## Handler 简介
一个Handler允许发送和处理Message，通过关联线程的 MessageQueue 执行 Runnable 对象。  
每个Handler实例都和一个单独的线程及其消息队列绑定。  
可以将一个任务切换到Handler所在的线程中去执行。一个用法就是子线程通过Handler更新UI。

主要有2种用法：
* 做出计划，在未来某个时间点执行消息和Runnable
* 线程调度，在其他线程规划并执行任务

要使用好Handler，需要了解与其相关的 `MessageQueue`， `Message`和`Looper`；不能孤立的看Handler    
Handler就像一个操作者（或者像一个对开发者开放的窗口），利用`MessageQueue`和`Looper`来实现任务调度和处理。  
- **Handler持有 Looper 的实例，直接looper的消息队列。**
```java
// 这个回调允许你使用Handler时不新建一个Handler的子类
public interface Callback {
    public boolean handleMessage(Message msg);
}
final Looper mLooper; // Handler持有 Looper 的实例
final MessageQueue mQueue; // 持有消息队列
final Callback mCallback;
```

在Handler的构造器中，我们可以看到消息队列是相关的Looper管理的
```java
    public Handler(Callback callback, boolean async) {
        // 处理异常
        mLooper = Looper.myLooper();
        // 处理特殊情况...
        mQueue = mLooper.mQueue; // 获取的是Looper的消息队列
    }

    public Handler(Looper looper, Callback callback, boolean async) {
        mLooper = looper;
        mQueue = looper.mQueue; // 获取的是Looper的消息队列
        mCallback = callback;
        mAsynchronous = async;
    }
```

### Android是消息驱动的，实现消息驱动有几个要素：

* 消息的表示：Message
* 消息队列：MessageQueue
* 消息循环，用于循环取出消息进行处理：Looper
* 消息处理，消息循环从消息队列中取出消息后要对消息进行处理：Handler

#### 初始化消息队列
在Looper构造器中即创建了一个MessageQueue，**Looper持有消息队列的实例**

#### 发送消息
通过Looper.prepare初始化好消息队列后就可以调用Looper.loop进入消息循环了，然后我们就可以向消息队列发送消息，
消息循环就会取出消息进行处理，在看消息处理之前，先看一下消息是怎么被添加到消息队列的。

#### 消息循环
Java层的消息都保存在了Java层MessageQueue的成员mMessages中，Native层的消息都保存在了Native Looper的
mMessageEnvelopes中，这就可以说有两个消息队列，而且都是按时间排列的。

### 为什么要用Handler这样的一个机制
因为在Android系统中UI操作并不是线程安全的，如果多个线程并发的去操作同一个组件，可能导致线程安全问题。为了解决这一个问题，android制定了一条规则：只允许UI线程来修改UI组件的属性等，也就是说必须单线程模型，这样导致如果在UI界面进行一个耗时较长的数据更新等就会形成程序假死现象 也就是ANR异常，如果20秒中没有完成程序就会强制关闭。所以比如另一个线程要修改UI组件的时候，就需要借助Handler消息机制了。

### Handler发送和处理消息的几个方法

1.void handleMessage( Message  msg):处理消息的方法，该方法通常被重写。
2.final boolean hasMessage(int  what):检查消息队列中是否包含有what属性为指定值的消息
3.final boolean hasMessage(int what ,Object object) :检查消息队列中是否包含有what好object属性指定值的消息
4.sendEmptyMessage(int what):发送空消息
5.final Boolean send EmptyMessageDelayed(int what ,long delayMillis):指定多少毫秒发送空消息
6.final  boolean sendMessage(Message msg):立即发送消息
7.final boolean sendMessageDelayed(Message msg,long delayMillis):多少秒之后发送消息


## 与Handler工作的几个组件Looper、MessageQueue各自的作用：

* 1.Handler：它把消息发送给Looper管理的MessageQueue,并负责处理Looper分给它的消息
* 2.MessageQueue：管理Message，由Looper管理
* 3.Looper：每个线程只有一个Looper，比如UI线程中，系统会默认的初始化一个Looper对象，它负责管理MessageQueue，不断的从MessageQueue中取消息，并将相对应的消息分给Handler处理。可以参阅[startActivity分析](http://rustfisher.github.io/2017/09/06/Android_note/RTFSC-Android_Activity_start_flow_analysis/)

`Handler.java (frameworks/base/core/java/android/os)`
```java
    // 将消息添加到队列前，先判断队列是否为null
    public boolean sendMessageAtTime(Message msg, long uptimeMillis) {
        MessageQueue queue = mQueue;
        if (queue == null) {
            RuntimeException e = new RuntimeException(
                    this + " sendMessageAtTime() called with no mQueue");
            Log.w("Looper", e.getMessage(), e);
            return false;
        }
        return enqueueMessage(queue, msg, uptimeMillis);
    }
// ......
    // 将消息添加到队列中
    private boolean enqueueMessage(MessageQueue queue, Message msg, long uptimeMillis) {
        msg.target = this; // 将自己指定为Message的Handler
        if (mAsynchronous) {
            msg.setAsynchronous(true);
        }
        return queue.enqueueMessage(msg, uptimeMillis);
    }
```
从这里也不难看出，每个Message都持有Handler。如果Handler持有Activity的引用，Activity onDestroy后Message却仍然在队列中，因为Handler与Activity的强关联，会造成Activity无法被GC回收，导致内存泄露。  
因此在Activity onDestroy 时，与Activity关联的Handler应清除它的队列由Activity产生的任务，避免内存泄露。

消息队列 `MessageQueue.java (frameworks/base/core/java/android/os)`
```java
    // 添加消息
    boolean enqueueMessage(Message msg, long when) {
        // 判断并添加消息...
        return true;
    }
```

### Handler.sendEmptyMessage(int what) 流程解析
获取一个Message实例，并立即将Message实例添加到消息队列中去。  

简要流程如下
```java
// Handler.java
// 立刻发送一个empty消息
sendEmptyMessage(int what) 

// 发送延迟为0的empty消息  这个方法里通过Message.obtain()获取一个Message实例
sendEmptyMessageDelayed(what, 0) 

// 计算消息的计划执行时间，进入下一阶段
sendMessageDelayed(Message msg, long delayMillis)

// 在这里判断队列是否为null  若为null则直接返回false
sendMessageAtTime(Message msg, long uptimeMillis)

// 将消息添加到队列中
enqueueMessage(MessageQueue queue, Message msg, long uptimeMillis)

// 接下来是MessageQueue添加消息
// MessageQueue.java
boolean enqueueMessage(Message msg, long when)
```

部分源码如下
```java
    public final boolean sendEmptyMessageDelayed(int what, long delayMillis) {
        Message msg = Message.obtain();
        msg.what = what;
        return sendMessageDelayed(msg, delayMillis);
    }

    public final boolean sendEmptyMessage(int what)
    {
        return sendEmptyMessageDelayed(what, 0);
    }

    public final boolean sendMessageDelayed(Message msg, long delayMillis)
    {
        if (delayMillis < 0) {
            delayMillis = 0;
        }
        return sendMessageAtTime(msg, SystemClock.uptimeMillis() + delayMillis);
    }

    public boolean sendMessageAtTime(Message msg, long uptimeMillis) {
        MessageQueue queue = mQueue;
        if (queue == null) {
            RuntimeException e = new RuntimeException(
                    this + " sendMessageAtTime() called with no mQueue");
            Log.w("Looper", e.getMessage(), e);
            return false;
        }
        return enqueueMessage(queue, msg, uptimeMillis);
    }

    private boolean enqueueMessage(MessageQueue queue, Message msg, long uptimeMillis) {
        msg.target = this;
        if (mAsynchronous) {
            msg.setAsynchronous(true);
        }
        return queue.enqueueMessage(msg, uptimeMillis);
    }
```

### Handler 取消任务 removeCallbacksAndMessages 
要取消任务时，调用下面这个方法
```java
public final void removeCallbacksAndMessages(Object token) {
    mQueue.removeCallbacksAndMessages(this, token);
}
```
通过调用`Message.recycleUnchecked()`方法，取消掉与此Handler相关联的Message。

相关的消息队列会执行取消指令
```java
void removeCallbacksAndMessages(Handler h, Object object)
```

## Message 和 MessageQueue 简介
### Message
Message 属于被传递，被使用的角色  
Message 是包含描述和任意数据对象的“消息”，能被发送给`Handler`。  
包含2个int属性和一个额外的对象  
虽然构造器是公开的，但获取实例最好的办法是调用`Message.obtain()`或`Handler.obtainMessage()`。
这样可以从他们的可回收对象池中获取到消息实例

一般来说，每个Message实例握有一个Handler

部分属性值
```java
    /*package*/ Handler target; // 指定的Handler
    
    /*package*/ Runnable callback;
    
    // 可以组成链表
    // sometimes we store linked lists of these things
    /*package*/ Message next;
```

重置自身的方法，将属性全部重置
```java
public void recycle()
void recycleUnchecked()
```

获取Message实例的常用方法，得到的实例与传入的Handler绑定
```java
    /**
     * Same as {@link #obtain()}, but sets the value for the <em>target</em> member on the Message returned.
     * @param h  Handler to assign to the returned Message object's <em>target</em> member.
     * @return A Message object from the global pool.
     */
    public static Message obtain(Handler h) {
        Message m = obtain();
        m.target = h;

        return m;
    }
```

将消息发送给Handler
```java
    /**
     * Sends this Message to the Handler specified by {@link #getTarget}.
     * Throws a null pointer exception if this field has not been set.
     */
    public void sendToTarget() {
        target.sendMessage(this); // target 就是与消息绑定的Handler
    }
```
调用这个方法后，Handler会将消息添加进它的消息队列`MessageQueue`中

### MessageQueue
持有一列可以被Looper分发的Message。  
一般来说由Handler将Message添加到MessageQueue中。

获取当前线程的MessageQueue方法是`Looper.myQueue()`

## Looper 简介
Looper与MessageQueue紧密关联

在一个线程中运行的消息循环。线程默认情况下是没有与之管理的消息循环的。  
要创建一个消息循环，在线程中调用prepare，然后调用loop。即开始处理消息，直到循环停止。

大多数情况下通过Handler来与消息循环互动。

Handler与Looper在线程中交互的典型例子
```java
class LooperThread extends Thread {
    public Handler mHandler;
    public void run() {
        Looper.prepare(); // 为当前线程准备一个Looper
        // 创建Handler实例，Handler会获取当前线程的Looper
        // 如果实例化Handler时当前线程没有Looper，会报异常 RuntimeException
        mHandler = new Handler() {
            public void handleMessage(Message msg) {
                // process incoming messages here
            }
        };
        Looper.loop(); // Looper开始运行
    }
}
```

### Looper中的属性
Looper持有MessageQueue；唯一的主线程Looper `sMainLooper`；Looper当前线程 `mThread`；
存储Looper的`sThreadLocal`
```java
    // sThreadLocal.get() will return null unless you've called prepare().
    static final ThreadLocal<Looper> sThreadLocal = new ThreadLocal<Looper>();
    private static Looper sMainLooper;  // guarded by Looper.class

    final MessageQueue mQueue; // Handler会获取这个消息队列实例（参考Handler构造器）
    final Thread mThread; // Looper当前线程
```

ThreadLocal并不是线程，它的作用是可以在每个线程中存储数据。

### Looper 方法
准备方法，将当前线程初始化为Looper。退出时要调用quit
```java
public static void prepare() {
    prepare(true);
}

private static void prepare(boolean quitAllowed) {
    if (sThreadLocal.get() != null) {
        throw new RuntimeException("Only one Looper may be created per thread");
    }
    sThreadLocal.set(new Looper(quitAllowed)); // Looper实例存入了sThreadLocal
}
```

`prepare`方法新建 Looper 并存入 sThreadLocal `sThreadLocal.set(new Looper(quitAllowed))`  
`ThreadLocal<T>`类
```java
    public void set(T value) {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null)
            map.set(this, value);
        else
            createMap(t, value);
    }

    public T get() {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null)
                return (T)e.value;
        }
        return setInitialValue();
    }
```

当要获取Looper对象时，从`sThreadLocal`获取
```java
    // 获取与当前线程关联的Looper，返回可以为null
    public static @Nullable Looper myLooper() {
        return sThreadLocal.get();
    }
```

在当前线程运行一个消息队列。结束后要调用退出方法`quit()`
```java
public static void loop()
```

准备主线程Looper。Android环境会创建主线程Looper，开发者不应该自己调用这个方法。  
UI线程，它就是ActivityThread，ActivityThread被创建时就会初始化Looper，这也是在主线程中默认可以使用Handler的原因。
```java
public static void prepareMainLooper() {
    prepare(false); // 这里表示了主线程Looper不能由开发者来退出
    synchronized (Looper.class) {
        if (sMainLooper != null) {
            throw new IllegalStateException("The main Looper has already been prepared.");
        }
        sMainLooper = myLooper();
    }
}
```

获取主线程的Looper。我们开发者想操作主线程时，可调用此方法
```java
public static Looper getMainLooper()
```
