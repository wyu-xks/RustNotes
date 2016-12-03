---
title: Android ThreadPoolExecutor 初步
date: 2016-12-01 20:00:33
category: Android_note
tag: [Thread]
---

### 应用场景
执行大量同步任务时，减少创建线程的开销。在执行一系列任务时，提供一种管理资源和线程的手段。

例如加载大量图片的任务。

### ThreadPoolExecutor 参数释义

* corePoolSize 线程池中的线程数量
* maximumPoolSize 线程池中线程数量的最大值
* keepAliveTime 线程数量超过corePoolSize，超出部分的线程被终止前的等待时间
* unit keepAliveTime 的单位，可以是秒或分钟等等
* workQueue 持有未执行任务的队列。持有execute方法添加的Runnable
* threadFactory 创建线程时用的工厂模式
* handler 处理队列外的线程

每个ThreadPoolExecutor持有一些基本的状态，例如已完成的任务个数。

### ThreadPoolExecutor 应用代码示例
定义基本参数
```java
private static final int CORE_POOL_SIZE = 1;    // 核心线程数
private static final int MAX_POOL_SIZE = 3;     // 最大线程数
private static final int BLOCK_SIZE = 3;        // 阻塞队列大小
private static final long KEEP_ALIVE_TIME = 2;  // 空闲线程超时时间
```

创建ThreadPoolExecutor
```java
private ThreadPoolExecutor mExecutorPool;
private void initThreadPool() {
    mExecutorPool = new ThreadPoolExecutor(
            CORE_POOL_SIZE, MAX_POOL_SIZE, KEEP_ALIVE_TIME, TimeUnit.SECONDS,
            new ArrayBlockingQueue<Runnable>(BLOCK_SIZE),
            Executors.defaultThreadFactory(), mRejectHandle);
    mExecutorPool.allowCoreThreadTimeOut(true);
}

ThreadPoolExecutor.AbortPolicy mRejectHandle = new ThreadPoolExecutor.AbortPolicy() {
    @Override
    public void rejectedExecution(Runnable r, ThreadPoolExecutor e) {
//            super.rejectedExecution(r, e);// 可不抛出异常;自己处理被拒绝的任务
        Toast.makeText(getApplicationContext(), "reject " + r.toString(),
                Toast.LENGTH_SHORT).show();
    }
};

```

向线程池中添加任务Runnable，这里有2种不同的任务。Runnable中用handler更新UI
```java
public void addNewTask() {
    int num = 0;
    try {
        for (; num < 10; num += 2) {
            mExecutorPool.execute(new WorkFirstRunnable(num));
            mExecutorPool.execute(new WorkSecondRunnable(num + 1));
        }
    } catch (Exception e) {
        Log.e(TAG, "新任务被拒绝 ", e);
    }
    showPoolInfo("added task!");
}

```

这例子中，同时在执行的有3个线程。超出允许数量的任务会被拒绝加入队列并且不会被执行，
由`mRejectHandle`处理。

示意图：

![tpDemo1](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Android_note/pics/threadpool_demo_1.gif)
