---
title: Android AsyncTask
date: 2017-06-22 22:13:16
category: Android_note
tag: [Thread]
toc: true
---

本文简单介绍Android中的AsyncTask，并从源码角度分析它的流程和特点。  

AsyncTask有助于使用UI线程。
这个类能让你不主动使用多线程或Handler，在UI线程进行后台操作并发布结果。
是一个在不用多线程和Handler的情况下的帮助类。AsyncTask适用于短时间的操作（最多几秒）。
如需长时间的线程操作，建议使用多线程包`java.util.concurrent`中的API，比如`Executor`，`ThreadPoolExecutor` 和 `FutureTask`

AsyncTask任务的构成：
* 3种泛型：`Params`， `Progress` 和 `Result`
* 4个步骤：`onPreExecute`, `doInBackground`, `onProgressUpdate` 和 `onPostExecute`

[Google文档](https://developer.android.com/reference/android/os/AsyncTask.html)

### 用法简介
虚构一个计算任务
```java
    /**
     * 虚拟的计算任务
     */
    private class CalculationTask extends AsyncTask<Float, Integer, Float> {
        protected Float doInBackground(Float... inputs) {
            Log.d(TAG, "doInBackground thread ID = " + Thread.currentThread().getId());
            long step = 0;
            float result = 0;
            for (float f : inputs) {
                // 假设这里有一些耗时的操作
                result += f;
            }
            while (step < 5) {
                result += step;
                step++;
                publishProgress((int) step);
            }
            return result;
        }

        protected void onProgressUpdate(Integer... progress) {
            Log.d(TAG, "onProgressUpdate thread ID = " + Thread.currentThread().getId());
            Log.d(TAG, "onProgressUpdate: " + progress[0]);
        }

        protected void onPostExecute(Float result) {
            Log.d(TAG, "onPostExecute thread ID = " + Thread.currentThread().getId());
            Log.d(TAG, "任务执行完毕");
        }
    }
    // 执行任务
    new CalculationTask().execute(1.2f, 2.3f, 6.3f);
/*
logcat
Main thread ID = 1
doInBackground thread ID = 8089
onProgressUpdate thread ID = 1
onProgressUpdate: 1
...
onProgressUpdate thread ID = 1
onProgressUpdate: 5
onPostExecute thread ID = 1
任务执行完毕
*/
```

### AsyncTask 使用的的泛型
AsyncTask使用的3种泛型
* Params 送去执行的类型
* Progress 后台计算的进度类型
* Result 后台计算的结果

不用的泛型可以用`Void`表示。例如
```java
private class MyTask extends AsyncTask<Void, Void, Void> { ... }
```

### 异步任务的4个步骤
异步任务执行时经过4个步骤
* `onPreExecute()` UI线程在任务开始前调用这个方法。此方法常用来设置任务，比如在屏幕上显示一个进度条。
* `doInBackground(Params...)` `onPreExecute()`执行完毕后立即在后台线程中执行。这一步用来执行耗时的后台计算。
这个方法接受异步任务的参数，返回最后的任务结果。这一步可以调用`publishProgress(Progress...)`通知出去一个或多个进度。这些进度值会被`onProgressUpdate(Progress...)`在UI线程收到。
* `onProgressUpdate(Progress...)`  调用`publishProgress(Progress...)`后会在UI线程中执行。用来显示执行中任务的UI。
* `onPostExecute(Result)` 后台任务执行完毕时被调用。最终结果会被传入这个方法。

### 取消任务
调用`cancel(boolean)`可随时取消任务。取消任务后`isCancelled()`会返回true。
调用这个方法后，后台任务`doInBackground(Object[])`执行完毕后会调用`onCancelled(Object)`而不再是`onPostExecute(Object)`。
为保证任务能被及时地取消，在`doInBackground(Object[])`中应该经常检查`isCancelled()`返回值

### 线程规则 Threading rules
一些线程规则
* 异步任务必须从UI线程启动
* 必须在UI线程实例化AsyncTask类
* 必须在UI线程调用`execute(Params...)`
* 不要手动调用`onPreExecute(), onPostExecute(Result), doInBackground(Params...), onProgressUpdate(Progress...)`
* 同一个异步任务实例只能被执行一次。重复执行同一个异步任务实例会抛出异常（`IllegalStateException`）。

## 源码简析
需要解决的问题：
AsyncTask是如何调用后台线程完成任务的？线程是如何调度的？

AsyncTask使用`Executor`，利用`WorkerRunnable`和`FutureTask`来执行后台任务
```java
    private final WorkerRunnable<Params, Result> mWorker; // 实现了 Callable
    private final FutureTask<Result> mFuture;

    private static abstract class WorkerRunnable<Params, Result> implements Callable<Result> {
        Params[] mParams;
    }
```

使用`Handler`来进行线程调度。内部定义了一个类`InternalHandler`。

### 从`execute(Params... params)`方法切入
先看方法`execute(Params... params)`，使用默认执行器，并传入参数
调用`xecuteOnExecutor(Executor exec, Params... params)`
```java
    @MainThread // 指定在主线程执行
    public final AsyncTask<Params, Progress, Result> execute(Params... params) {
        return executeOnExecutor(sDefaultExecutor, params);
    }
```

先判断当前状态，如果状态不是`Status.PENDING`，则抛出异常。  
否则进入`Status.RUNNING`状态，执行`onPreExecute()`，再由执行器启动任务。
```java
    @MainThread
    public final AsyncTask<Params, Progress, Result> executeOnExecutor(Executor exec,
            Params... params) {
        if (mStatus != Status.PENDING) {
            switch (mStatus) {
                case RUNNING:
                    throw new IllegalStateException("Cannot execute task:"
                            + " the task is already running.");
                case FINISHED: // 同一个任务实例只能够执行一次
                    throw new IllegalStateException("Cannot execute task:"
                            + " the task has already been executed "
                            + "(a task can be executed only once)");
            }
        }
        mStatus = Status.RUNNING;
        onPreExecute();
        mWorker.mParams = params;
        exec.execute(mFuture); // 开始进入后台线程执行任务
        return this;
    }
```

`mWorker`带着传进来的参数，`mFuture`实例化时已经将`mWorker`注入。参看构造函数
```java
    public AsyncTask() {
        mWorker = new WorkerRunnable<Params, Result>() {
            public Result call() throws Exception {
                mTaskInvoked.set(true);

                Process.setThreadPriority(Process.THREAD_PRIORITY_BACKGROUND);
                // 在后台线程进行自定义的操作  这里面可以调用publishProgress方法
                Result result = doInBackground(mParams); 
                Binder.flushPendingCommands();
                return postResult(result); // 发送最终结果
            }
        };

        mFuture = new FutureTask<Result>(mWorker) { // 依赖 mWorker
            @Override
            protected void done() {
                try {
                    postResultIfNotInvoked(get());
                } catch (InterruptedException e) {
                    android.util.Log.w(LOG_TAG, e);
                } catch (ExecutionException e) {
                    throw new RuntimeException("An error occurred while executing doInBackground()",
                            e.getCause());
                } catch (CancellationException e) {
                    postResultIfNotInvoked(null);
                }
            }
        };
    }
```

`publishProgress`方法通过主线程的Handler向外通知进度
```java
    @WorkerThread
    protected final void publishProgress(Progress... values) {
        if (!isCancelled()) {
            getHandler().obtainMessage(MESSAGE_POST_PROGRESS,
                    new AsyncTaskResult<Progress>(this, values)).sendToTarget();
        }
    }
```

后台任务执行完毕，`postResult`发送最终结果
```java
    private Result postResult(Result result) {
        @SuppressWarnings("unchecked")
        Message message = getHandler().obtainMessage(MESSAGE_POST_RESULT,
                new AsyncTaskResult<Result>(this, result));
        message.sendToTarget(); // 会走到finish方法
        return result;
    }

    private void finish(Result result) {
        if (isCancelled()) {
            onCancelled(result); // 如果任务已经被取消了
        } else {
            onPostExecute(result); // 通知任务执行完毕
        }
        mStatus = Status.FINISHED;
    }
```

### 关于默认执行器 `sDefaultExecutor` 和线程池
源码中构建了一个线程池和一个自定义的执行器`SerialExecutor`。靠它们来执行后台任务。

参考源代码
```java
public abstract class AsyncTask<Params, Progress, Result> {
    private static final int CPU_COUNT = Runtime.getRuntime().availableProcessors();
    // 核心线程至少2个，最多4个
    private static final int CORE_POOL_SIZE = Math.max(2, Math.min(CPU_COUNT - 1, 4));
    private static final int MAXIMUM_POOL_SIZE = CPU_COUNT * 2 + 1;
    private static final int KEEP_ALIVE_SECONDS = 30;

    public static final Executor SERIAL_EXECUTOR = new SerialExecutor();
    private static volatile Executor sDefaultExecutor = SERIAL_EXECUTOR;

    private static final ThreadFactory sThreadFactory = new ThreadFactory() {
        private final AtomicInteger mCount = new AtomicInteger(1);

        public Thread newThread(Runnable r) {
            return new Thread(r, "AsyncTask #" + mCount.getAndIncrement());
        }
    };

    private static final BlockingQueue<Runnable> sPoolWorkQueue =
            new LinkedBlockingQueue<Runnable>(128);

    public static final Executor THREAD_POOL_EXECUTOR; // 实际执行者

    static {
        ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(
                CORE_POOL_SIZE, MAXIMUM_POOL_SIZE, KEEP_ALIVE_SECONDS, TimeUnit.SECONDS,
                sPoolWorkQueue, sThreadFactory);
        threadPoolExecutor.allowCoreThreadTimeOut(true);
        THREAD_POOL_EXECUTOR = threadPoolExecutor;
    }

    // 默认执行器的类
    private static class SerialExecutor implements Executor {
        final ArrayDeque<Runnable> mTasks = new ArrayDeque<Runnable>();
        Runnable mActive;

        public synchronized void execute(final Runnable r) {
            mTasks.offer(new Runnable() {
                public void run() {
                    try {
                        r.run();
                    } finally {
                        scheduleNext();
                    }
                }
            });
            if (mActive == null) {
                scheduleNext();
            }
        }

        protected synchronized void scheduleNext() {
            if ((mActive = mTasks.poll()) != null) {
                THREAD_POOL_EXECUTOR.execute(mActive);
            }
        }
    }
}

```


