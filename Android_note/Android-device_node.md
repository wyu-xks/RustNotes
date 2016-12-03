---
title: Android 上层应用读写设备节点
date: 2015-10-05 15:09:40
category: Android_note
tag: [Android]
---
Android L

[TOC]

## 1. Android 设备节点
Android基于Linux内核。设备节点文件是设备驱动的逻辑文件，可以通过设备节点来访问设备驱动。
很多设备信息都可存储在节点中。apk可以访问节点，获取设备信息或状态。

## 2. framework中读取节点的例子
Android Settings 应用中给出了很多的设备信息，可以以此为入口；进一步可以找到 Build.java
例如获取设备的版本号，应用中直接可以调用 Build.DISPLAY 获得字符串

源码 Build.java (frameworks\base\core\java\android\os)
```java
    public static final String PRODUCT = getString("ro.product.name");
    ......
    private static String getString(String property) {
        return SystemProperties.get(property, UNKNOWN);
    }
```
跳转到 SystemProperties.java (frameworks\base\core\java\android\os) 这个类不开放
```java
    // 调用 native_get ，获取节点；可以设定默认值
    public static String get(String key, String def) {
        if (key.length() > PROP_NAME_MAX) {
            throw new IllegalArgumentException("key.length > " + PROP_NAME_MAX);
        }
        return native_get(key, def);
    }
```

## 3. 应用层读写节点
应用层中，一般都能够读取设备节点。对于写节点这个操作，需要更高的root权限。

### 读取设备节点
例如给设备新添加了节点，路径是 `/sys/class/demo/version`
可以`adb shell`进入机器，然后 `cat /sys/class/demo/version`；即可获得信息

也可以写成一个方法，如下：
```java
    /**
     * 获取节点
     */
    private static String getString(String path) {
        String prop = "waiting";// 默认值
        try {
            BufferedReader reader = new BufferedReader(new FileReader(path));
            prop = reader.readLine();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return prop;
    }
```
调用方法就是：
```java
    getString("/sys/class/demo/version")
```

### 写设备节点
这里写节点的方法需要更高的权限，apk要放到源码中进行编译；
源码中编译apk的方法如同添加第三方apk的方法
AndroidManifest中添加：
```xml
        android:sharedUserId="android.uid.system"
```
写节点的代码
```java
    private static final String WAKE_PATH = "/sys/class/demo/wake";
    ......
        try {
            BufferedWriter bufWriter = null;
            bufWriter = new BufferedWriter(new FileWriter(WAKE_PATH));
            bufWriter.write("1");  // 写操作
            bufWriter.close();
            Toast.makeText(getApplicationContext(),
                    "功能已激活",Toast.LENGTH_SHORT).show();
            Log.d(TAG,"功能已激活 angle " + getString(ANGLE_PATH));
        } catch (IOException e) {
            e.printStackTrace();
            Log.e(TAG,"can't write the " + WAKE_PATH);
        }
```
经过源码mm编译后，push到设备中可以查看效果

### 定时读取设备节点
需要被更新的View记得调用`invalidate()`方法
#### 使用定时器与Handler来定时读取节点，并更新UI
重启定时器和取消定时器都封装成方法，便于调用
```java
    Timer mTimer;
    TimerTask mTimerTask;
    SensorHandler mHandler = new SensorHandler(this);

    /**
     * Handler : update value
     */
    static class SensorHandler extends Handler {
        MainActivity mainActivity;

        SensorHandler(MainActivity activity) {
            mainActivity = activity;
        }

        @Override
        public void handleMessage(Message msg) {
            mainActivity.ultrasoundValue.setText(getString(ULTRASOUND_VALUE_PATH));
        }
    }

    ......

    /**
     * cancel timer and timer task
     */
    private void cancelUltrasoundTimer(){
        if (mTimer != null) {
            mTimer.cancel();
            mTimer = null;
        }
        if (mTimerTask != null){
            mTimerTask.cancel();
            mTimerTask = null;
        }
    }

    /**
     * restart timer to update UI
     */
    private void restartUltrasoundTimer(String timer){
        cancelUltrasoundTimer();
        mTimer = new Timer(timer);
        mTimerTask = new TimerTask() {
            @Override
            public void run() {
                mHandler.sendEmptyMessageAtTime(1300, 50);
            }
        };
        mTimer.schedule(mTimerTask, 50, 50);
    }
```

#### 使用 Runnable 和 Handler 来定时更新UI
Handler 部分不变，在开启的子线程中向Handler发送消息
onCreate 方法中启动子线程
```java
        Thread t = new Thread(new UpdateUIThread());
        t.start();
```

```java
    class UpdateUIThread implements Runnable {

        @Override
        public void run() {
            while (true) {
                while (ultraStatus) {
                    Message message = new Message();
                    message.what = UPDATE_ULTRA_VALUE;// int

                    mHandler.sendMessage(message);
                    try {
                        Thread.sleep(100); // 暂停100ms，起到定时的效果
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }
                }
            }
        }
    }
```
