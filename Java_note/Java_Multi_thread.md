---
title: Java 多线程
date: 2017-01-08 22:11:39
category: Java_note
tag: [Thread]
toc: true
---


参考书籍： *Core Java, Volume II - Advanced Features 7th Edition*  
建议参考： *Concurrent Programming in Java*

以下是一些笔记和心得，详细内容请参考 *Core Java 2*

多线程和进程有什么区别？  
本质区别在于每个进程都有它自己的变量的完备集，线程则共享相同的数据。

## 线程状态
* New (新生)
* Runnable (可运行)
* Blocked (被阻塞)
* Dead (死亡)

### 新生线程
用new操作符创建一个新线程，此时线程还没开始运行，就处于New（新生）状态。
在线程可以运行前，还有一些簿记工作要做。

### 可运行线程
一旦调用了start方法，该线程就变成可运行（Runnable）的了。一个可运行线程可能实际上在运行，也
可能吗没有，这取决于操作系统为该线程提供的运行时间。

在任何给定时刻，一个可运行线程可能正在运行，也可能不是。

### 被阻塞线程
* 调用sleep方法
* 调用一个在I/O上被阻塞的操作
* 线程试图得到一个锁

### 死线程
两个原因导致线程死亡（退出）：
* 因为run方法正常退出而自然死亡
* 因为一个未捕获的异常终止了run方法而使线程猝死


## 线程属性
### 线程优先级
默认情况下，一个线程继承它的父线程的优先级。一个线程的父线程就是启动它的那个线程。

线程优先级是高度依赖于系统的。

### 守护线程
可以调用`t.setDaemon(true)`将线程转变成一个守护线程。

一个守护线程唯一作用就是为其他线程提供服务。比如计时器线程。当只剩下守护线程时，虚拟机就退出了。

#### 守护线程退出举例
测试线程类。有一个执行计数器。
```java
static class TestThread extends Thread {
        private int count = 1000;

        TestThread(int c) {
            this.count = c;
        }

        @Override
        public void run() {
            while (!isInterrupted() && count > 0) {
                count--;
                System.out.println("[" + getId() + "] running.");
                try {
                    Thread.sleep(50);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
            System.out.println(getId() + " dies.");
        }
    }
```

调用。将t1，t2设为守护线程。因设置运行次数的关系，t1和t2先正常退出。
```java
    public static void main(String[] args) {
        TestThread t1 = new TestThread(2);
        TestThread t2 = new TestThread(2);
        TestThread t3 = new TestThread(3);
        t1.setDaemon(true);
        t2.setDaemon(true);
        t1.start();
        t2.start();
        t3.start();
    }
```

如果修改线程的循环次数，其他不变。运行后壳看出，t3线程结束后，t1和t2线程
被直接结束了，而且没能执行最后的代码。
```java
        TestThread t1 = new TestThread(4);
        TestThread t2 = new TestThread(4);
        TestThread t3 = new TestThread(2);
```

## 同步
通常有两个或者多个线程对相同的对象进行共享访问。如果两个线程访问相同对象，并调用了改变对象状态的
方法，可能会出现race condition。如果那个方法不是原子操作，很可能出错。

### 锁对象
使用锁来保护代码块
```java
myLock.lock();
try {
  // critical work...
}
finally {
  myLock.unlock();
}
```
这种结构保证在任何时刻只有一个线程能够进入临界区。一个线程锁住了对象，其他线程调用lock时，会被
阻塞。

如果一个异常在临界区代码结束前被抛出，那么finally子句就会释放锁，这会使对象处于某种受损状态中。

### Synchronized关键字
如果一个方法由synchronized关键字声明，那么对象的锁将保护整个方法。

### Volatile域
volatile关键字为对一个实例的域的同步访问提供了一个免锁（lock-free）机制。如果你把域声明为
volatile，那么编译器和虚拟机知道该域可能会被另一个线程并发更新。

访问一个volatile变量比访问一个一般变量要慢。

在以下三个条件下，对一个域的并行访问是安全的：
* volatile域
* final域，并且在构造器调用完成后被访问
* 对域的访问有锁保护

### 死锁
当所有的线程都不能满足锁的条件，都无法执行下去而阻塞，称为死锁。

## 执行器

构建一个新的线程代价还是有些高的，因为它设计与操作系统的交互。如果你的程序创建大量生存周期很短
的线程，那就应该使用线程池。一个线程池包含大量准备运行的空闲线程。你将一个Runnable对象给线程池，
线程池中的一个线程就会调用run方法。当run方法退出时，线程并不会死亡，而是继续在池中准备为下一个
请求提供服务。

另一个使用线程池的理由是减少并发线程的数量。创建大量的线程会降低性能甚至使虚拟机崩溃。如果你用的
算法会创建许多的线程，那么就应该使用一个线程数“固定”的线程池来限制并发线程的数量。

