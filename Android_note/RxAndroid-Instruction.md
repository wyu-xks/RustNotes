---
title: RxAndroid 使用方法初探 - 简单的事件分发
date: 2017-04-14 19:51:14
category: Android_note
tag: [RxAndroid]
toc: true
---

## 关于RxJava和RxAndroid

强烈建议阅读这篇文章： http://gank.io/post/560e15be2dca930e00da1083

RxAndroid使用了观察者模式，属响应型机制。  
参考 https://github.com/ReactiveX/RxAndroid/

应用场景：异步。它是一个实现异步操作的库。

优势：保持代码可读性

## 使用实例

IDE Android Studio

### 添加依赖库

```
dependencies {
    // ......
    compile 'io.reactivex:rxandroid:1.2.1'
    // Because RxAndroid releases are few and far between, it is recommended you also
    // explicitly depend on RxJava's latest version for bug fixes and new features.
    compile 'io.reactivex:rxjava:1.1.6'
}
```

### 实例1 直接关联被观察者与订阅者

先定义出被观察者（事件源）和订阅者。然后把它们关联起来。  
当订阅者执行了`onCompleted()`后，就不再接收消息了。
```java
/**
 * 被观察者
 */
Observable.OnSubscribe mObservableAction = new Observable.OnSubscribe<String>() {
    @Override
    public void call(Subscriber<? super String> subscriber) {
        subscriber.onNext("mObservableAction: " + mCount);
        /**
         * Notifies the Observer that the {@link Observable}
         * has finished sending push-based notifications
         */
        subscriber.onCompleted();// 执行了此方法后，将不再接收处理消息
    }
};

/**
 * 接收消息的订阅者
 */
Subscriber<String> mSubscriber1 = new Subscriber<String>() {
    @Override
    public void onCompleted() {
        Log.d(TAG, "onCompleted: got sth");
    }

    @Override
    public void onError(Throwable e) {
        Log.d(TAG, "onError");
    }

    @Override
    public void onNext(String str) {
        Log.d(TAG, "onNext:" + str);
        mTv1.setText(str);
    }
};

/**
 * 作为观察者 - 接收到事件后执行操作
 * 不知为何要起 Action1 这个名字
 */
private Action1<String> mActionTv2 = new Action1<String>() {
    @Override
    public void call(String s) {
        mTv2.setText(s);
    }
};

findViewById(R.id.act_rx_btn1).setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View v) {
        mCount++;
        Log.d(TAG, "onClick: " + mCount);
        /**
         * 实例1 将事件源与订阅者关联起来
         */
        @SuppressWarnings("unchecked")
        Observable<String> observable = Observable.create(mObservableAction)
                .subscribeOn(AndroidSchedulers.mainThread());
        observable.subscribe(mSubscriber1);// 先通知一个，再通知另一个
        observable.subscribe(mActionTv2);  // 这个可以一直执行下去
    }
});

```

### 实例2 直接分发特定事件给订阅者

```java
private Action1<String> mActionTv3 = new Action1<String>() {
    @Override
    public void call(String s) {
        mTv3.setText(s);
    }
};

private Action1<String> mActionShowToast = new Action1<String>() {
    @Override
    public void call(String s) {
        Toast.makeText(RxAndroidActivity.this, s, Toast.LENGTH_SHORT).show();
    }
};

findViewById(R.id.act_rx_btn2).setOnClickListener(new View.OnClickListener() {
    @Override
    public void onClick(View v) {
        // 事件产生，分发给订阅者
        Observable<String> oba1 = Observable.just("事件分发源 " + mCount);
        oba1.observeOn(AndroidSchedulers.mainThread());
        oba1.subscribe(mActionTv3);
        oba1.subscribe(mActionShowToast);
    }
});
```

### 循环产生的消息
在子线程中产生消息，通知UI线程。

在不指定线程的情况下， RxJava 遵循的是线程不变的原则，即：在哪个线程调用 subscribe()，
就在哪个线程生产事件；在哪个线程生产事件，就在哪个线程消费事件。
如果需要切换线程，就需要用到 Scheduler （调度器）。

和上一个例子一样，定时产生一个消息，发送给订阅者

```java
private Action1<String> mActionTimer = new Action1<String>() {
    @Override
    public void call(String s) {
        final String second = s;
        /**
         * 跑在UI线程里更新
         */
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mTimerTv.setText(second);
            }
        });
    }
};

new Thread(new Runnable() {
    @Override
    public void run() {
        int s = 0;
        while (s <= 100) {
            Observable<String> timerOb = Observable.just(String.valueOf(s) + "s");

            // 指定在主线程发生回调
            timerOb.observeOn(AndroidSchedulers.mainThread());

            timerOb.subscribe(mActionTimer);
            try {
                Thread.sleep(1000L);
            } catch (InterruptedException e) {
                e.printStackTrace();
                break;
            }
            s++;
        }
    }
}).start();
```

### 实例效果

| 效果图 | |
|:---:|:----:|
|![实例1](https://raw.githubusercontent.com/RustFisher/aboutView/master/pics/rx_android_demo_01.gif)|![实例2](https://raw.githubusercontent.com/RustFisher/aboutView/master/pics/rx_android_demo_02.gif)|

画面中的秒数计数器一直在更新

## 线程控制
### 使用Scheduler的API
调用`Observable.subscribeOn(Schedulers s)`来设定被观察的任务执行的线程  
`Observable.observeOn()`来设定回调使用的线程

以下是`Schedulers`的部分源码
```java
public final class Schedulers {
    private final Scheduler computationScheduler; // 计算线程 与CPU有关
    private final Scheduler ioScheduler; //  主要用于I/O读写
    private final Scheduler newThreadScheduler;
    // .......
}
```

可以从注释中了解到线程切换的效果  
* `Schedulers.immediate()` 不切换线程 
* `Schedulers.newThread()` 对每一次任务启动一个新的线程
* `Schedulers.computation()` 适用于计算工作，比如处理循环事件，回调或者其他计算工作。不要在这里进行IO相关的操作。
* `Schedulers.io()` 内部实现中有一个自增长的线程池，可用于异步的阻塞IO读写工作。不要把计算工作放在这里。

还有一个Android专用的UI线程，引入`rx.android.schedulers.AndroidSchedulers;`
* `AndroidSchedulers.mainThread()` 使用UI线程

代码示例：在IO线程读取图片，然后显示在界面上
```java
Observable.create(new Observable.OnSubscribe<Drawable>() {
            @Override
            public void call(Subscriber<? super Drawable> subscriber) {
                Drawable drawable = ContextCompat.getDrawable(getApplicationContext(), R.mipmap.ic_launcher);
                int count = 0;
                while (count < 100) {
                    count++;// 人为制造一些延时
                    try {
                        Thread.sleep(25);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
                subscriber.onNext(drawable);
                subscriber.onCompleted();
            }
        })
                .subscribeOn(Schedulers.io()) // 在io线程取数据
                .observeOn(AndroidSchedulers.mainThread())//在主线程执行回调
                .subscribe(new Observer<Drawable>() {
                    @Override
                    public void onNext(Drawable drawable) {
                        mIv1.setImageDrawable(drawable);
                    }

                    @Override
                    public void onCompleted() {
                    }

                    @Override
                    public void onError(Throwable e) {
                        Toast.makeText(getApplicationContext(), "Error!", Toast.LENGTH_SHORT).show();
                    }
                });
```

## 变换
将时间序列中的对象或整个序列进行加工处理，转换成不同的事件或事件序列。串成串串。

### 使用`map()`来进行变换
输入图片的资源int值，通过map获得Drawable对象，然后发送给监听者  
这是最简单最常用的变换方式，一对一的变换

```java
Observable.just(R.mipmap.ic_launcher)
        .map(new Func1<Integer, Drawable>() {
            @Override
            public Drawable call(Integer integer) {
                return ContextCompat.getDrawable(getApplicationContext(), integer);
            }
        })
        .subscribeOn(Schedulers.io())// 线程调度
        .observeOn(AndroidSchedulers.mainThread())
        .subscribe(new Action1<Drawable>() {
            @Override
            public void call(Drawable drawable) {
                mIv2.setImageDrawable(drawable);// 显示图片
            }
        });
```

其中`Func1`是一个接口；`T`是输入对象，`R`是返回对象
```java
public interface Func1<T, R> extends Function {
    R call(T t);
}
```

### 使用`flatMap`
一个对象中持有某个集合，想要把这个集合输出。  
例如User持有一个String list，现在想一个个地获取list中的内容

```java
    User tom = new User("Tom");
    User jerry = new User("jerry");
    tom.profileList.add("p1");
    tom.profileList.add("p2");
    jerry.profileList.add("p4");
    jerry.profileList.add("p5");

    Observable.just(tom, jerry)
            .flatMap(new Func1<User, Observable<String>>() {
                @Override
                public Observable<String> call(User user) {
                    Log.d(TAG, "user: " + user.name);
                    return Observable.from(user.profileList); // 可以接受Iterable
                }
            })
            .subscribe(new Action1<String>() {
                @Override
                public void call(String s) {
                    Log.d(TAG, "profile:  " + s);
                }
            });

     /**
     * 示例用户类
     */
    class User {
        public User(String name) {
            this.name = name;
        }

        public String name;
        public List<String> profileList = new ArrayList<>();
    }
/*
输出
user: Tom
profile:  p1
profile:  p2
user: jerry
profile:  p4
profile:  p5
*/
```

