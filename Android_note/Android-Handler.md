---
title: Android Handler 机制
date: 2015-10-09 15:09:43
category: Android_note
tag: [Android]
toc: true
---
2016-2-25
Android 6.0.1_r10

[TOC]

Handler Looper MessageQueue

参考网址： http://www.cnblogs.com/angeldevil/p/3340644.html

### Android是消息驱动的，实现消息驱动有几个要素：

    消息的表示：Message
    消息队列：MessageQueue
    消息循环，用于循环取出消息进行处理：Looper
    消息处理，消息循环从消息队列中取出消息后要对消息进行处理：Handler

初始化消息队列
发送消息
通过Looper.prepare初始化好消息队列后就可以调用Looper.loop进入消息循环了，然后我们就可以向消息队列发送消息，
消息循环就会取出消息进行处理，在看消息处理之前，先看一下消息是怎么被添加到消息队列的。
消息循环
Java层的消息都保存在了Java层MessageQueue的成员mMessages中，Native层的消息都保存在了Native Looper的
mMessageEnvelopes中，这就可以说有两个消息队列，而且都是按时间排列的。

### 为什么要用Handler这样的一个机制:
因为在Android系统中UI操作并不是线程安全的，如果多个线程并发的去操作同一个组件，可能导致线程安全问题。
为了解决这一个问题，android制定了一条规则：只允许UI线程来修改UI组件的属性等，也就是说必须单线程模型，
这样导致如果在UI界面进行一个耗时较长的数据更新等就会形成程序假死现象 也就是ANR异常，如果20秒中没有完成
程序就会强制关闭。所以比如另一个线程要修改UI组件的时候，就需要借助Handler消息机制了。

### Handler发送和处理消息的几个方法:

1.void handleMessage( Message  msg):处理消息的方法，该方法通常被重写。
2.final boolean hasMessage(int  what):检查消息队列中是否包含有what属性为指定值的消息
3.final boolean hasMessage(int what ,Object object) :检查消息队列中是否包含有what好object属性指定值的消息
4.sendEmptyMessage(int what):发送空消息
5.final Boolean send EmptyMessageDelayed(int what ,long delayMillis):指定多少毫秒发送空消息
6.final  boolean sendMessage(Message msg):立即发送消息
7.final boolean sendMessageDelayed(Message msg,long delayMillis):多少秒之后发送消息


### 与Handler工作的几个组件Looper、MessageQueue各自的作用：

1.Handler：它把消息发送给Looper管理的MessageQueue,并负责处理Looper分给它的消息
2.MessageQueue：采用先进的方式来管理Message
3.Looper：每个线程只有一个Looper，比如UI线程中，系统会默认的初始化一个Looper对象，它负责管理MessageQueue，
不断的从MessageQueue中取消息，并将相对应的消息分给Handler处理

Handler.java (frameworks/base/core/java/android/os)
```java
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
......
    private boolean enqueueMessage(MessageQueue queue, Message msg, long uptimeMillis) {
        msg.target = this;
        if (mAsynchronous) {
            msg.setAsynchronous(true);
        }
        return queue.enqueueMessage(msg, uptimeMillis);
    }
```

MessageQueue.java (frameworks/base/core/java/android/os)
```java
    boolean enqueueMessage(Message msg, long when) {
        if (msg.target == null) {
            throw new IllegalArgumentException("Message must have a target.");
        }
        if (msg.isInUse()) {
            throw new IllegalStateException(msg + " This message is already in use.");
        }

        synchronized (this) {
            if (mQuitting) {
                IllegalStateException e = new IllegalStateException(
                        msg.target + " sending message to a Handler on a dead thread");
                Log.w(TAG, e.getMessage(), e);
                msg.recycle();
                return false;
            }

            msg.markInUse();
            msg.when = when;
            Message p = mMessages;
            boolean needWake;
            if (p == null || when == 0 || when < p.when) {
                // New head, wake up the event queue if blocked.
                msg.next = p;
                mMessages = msg;
                needWake = mBlocked;
            } else {
                // Inserted within the middle of the queue.  Usually we don't have to wake
                // up the event queue unless there is a barrier at the head of the queue
                // and the message is the earliest asynchronous message in the queue.
                needWake = mBlocked && p.target == null && msg.isAsynchronous();
                Message prev;
                for (;;) {
                    prev = p;
                    p = p.next;
                    if (p == null || when < p.when) {
                        break;
                    }
                    if (needWake && p.isAsynchronous()) {
                        needWake = false;
                    }
                }
                msg.next = p; // invariant: p == prev.next
                prev.next = msg;
            }

            // We can assume mPtr != 0 because mQuitting is false.
            if (needWake) {
                nativeWake(mPtr);
            }
        }
        return true;
    }
```
