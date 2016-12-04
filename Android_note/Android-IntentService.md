---
title: Android IntentService 分析和用法
date: 2017-06-09 23:49:50
category: Android_note
tag: [Android_service]
toc: true
---

* Android Studio 2.3

## IntentService 简介
* IntentService继承自Service，可用`startService`启动，也需要在`AndroidManifest.xml`中注册
* IntentService在一个单独的worker线程中处理任务
* 任务完成后，会自动停止
* 可多次启动同一个IntentService，它们会自一个接一个地排队处理

## IntentService 与 Service
耗时任务可以不用在Service中手动开启线程。  
当操作完成时，我们不用手动停止IntentService，它会自动判定停止。  

### IntentService 自动停止
参考IntentService源码：
```java
    private volatile ServiceHandler mServiceHandler;

    private final class ServiceHandler extends Handler {
        public ServiceHandler(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(Message msg) {
            onHandleIntent((Intent)msg.obj);
            stopSelf(msg.arg1); // 传入startID
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();
        HandlerThread thread = new HandlerThread("IntentService[" + mName + "]");
        thread.start();

        mServiceLooper = thread.getLooper();
        mServiceHandler = new ServiceHandler(mServiceLooper);
    }

    @Override
    public void onStart(@Nullable Intent intent, int startId) {
        Message msg = mServiceHandler.obtainMessage();
        msg.arg1 = startId; // 这个是停止服务的依据
        msg.obj = intent;
        mServiceHandler.sendMessage(msg);
    }
```
利用`ServiceHandler`来控制生命周期。onCreate方法中开启了一个`HandlerThread`来处理请求。
在`onStart`中获取到`startId`。在`ServiceHandler`中每次处理完一个命令都会调用`stopSelf(int startId)`方法来停止服务。
IntentService直到命令队列中的所有命令被执行完后才会停止服务。


## 用法示例
新建一个模拟计算的后台服务`CalIntentService`继承`IntentService`
```java

/**
 * 模拟计算的后台服务
 * Created by Rust on 2017/6/9.
 */
public class CalIntentService extends IntentService {

    private static final String TAG = "rustApp";
    private int mStartId = 0;

    /**
     * 一定要一个无参构造器
     */
    public CalIntentService() {
        this("cal_intent_service_name");
    }

    /**
     * Creates an IntentService.  Invoked by your subclass's constructor.
     *
     * @param name Used to name the worker thread, important only for debugging.
     */
    public CalIntentService(String name) {
        super(name);
    }

    @Override
    public void onStart(@Nullable Intent intent, int startId) {
        super.onStart(intent, startId);
        mStartId = startId;
        Log.d(TAG, "[CalIntentService] onStart, startId=" + mStartId); // 复写这个方法来看startId
    }

    @Override
    public void onDestroy() {
        super.onDestroy(); // 观察生命周期
        Log.d(TAG, "[CalIntentService] onDestroy. StartId=" + mStartId);
    }

    @Override
    protected void onHandleIntent(@Nullable Intent intent) {
        if (null != intent) {
            String name = intent.getStringExtra("name");
            String msg = intent.getStringExtra("msg");
            Log.d(TAG, "[CalIntentService] 收到 name:" + name + ", msg:" + msg + ", at "
                    + Thread.currentThread().toString());
        }
        try {
            Thread.sleep(1000); // 模拟耗时操作
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        Log.d(TAG, "[CalIntentService] 计算结束.  mStartId=" + mStartId);
    }
}

```

AndroidManifest中注册这个服务。目前只允许本App使用
```xml
    <service
        android:name="com.rustfisher.service.CalIntentService"
        android:exported="false" />
```

Activity中启动这个服务
```java
    btn2.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            Intent calIntent = new Intent(getApplicationContext(), CalIntentService.class);
            calIntent.putExtra("name", "Rust");
            calIntent.putExtra("msg", "Click event: " + mClickCount++);
            startService(calIntent);
        }
    });
```

在手机上运行，快速点击几次按钮，启动IntentService，logcat输出
```
[CalIntentService] onStart, startId=1
[CalIntentService] 收到 name:Rust, msg:Click event: 0, at Thread[IntentService[cal_intent_service_name],5,main]
[CalIntentService] onStart, startId=2
[CalIntentService] onStart, startId=3
[CalIntentService] onStart, startId=4
[CalIntentService] 计算结束.  最新StartId=4
[CalIntentService] 收到 name:Rust, msg:Click event: 1, at Thread[IntentService[cal_intent_service_name],5,main]
[CalIntentService] 计算结束.  最新StartId=4
[CalIntentService] 收到 name:Rust, msg:Click event: 2, at Thread[IntentService[cal_intent_service_name],5,main]
[CalIntentService] 计算结束.  最新StartId=4
[CalIntentService] 收到 name:Rust, msg:Click event: 3, at Thread[IntentService[cal_intent_service_name],5,main]
[CalIntentService] 计算结束.  最新StartId=4
[CalIntentService] onDestroy. StartId=4
```

可以看出，先执行`onStart`，然后排队执行`onHandleIntent`。任务全部结束后自行停止。
