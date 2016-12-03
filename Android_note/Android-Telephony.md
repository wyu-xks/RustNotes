---
title: Android Telephony 笔记
date: 2015-09-20 15:10:08
category: Android_note
tag: [Android_frameworks]
---
《深入理解Android-Telephony原理剖析与最佳实践》 杨青平 [著]

[TOC]

## 基础篇
智能手机一般采用两个处理器。分别为主处理器AP（Application Processor，应用处理器），从处理器BP（Baseband Processor，基带处理器），它们中间通过串口、总线或USB等方式通信。

### Dalvik
DEX - Dalvik Executable
Java虚拟机运行的是Java字节码，Dalvik虚拟机运行的是DEX格式文件
Dalvik虚拟机特性总结如下：
* 每个Android应用运行在一个Dalvik虚拟机实例中，而每一个虚拟机实例都是一个独立的进程空间。
* 虚拟机的线程机制、内存分配和管理、Mutex（进程同步）等实现都依赖Linux操作系统
* 所有Android应用的线程都对应一个Linux线程，因而虚拟机可以更读地使用Linux操作系统的线程调度和管理机制。

### HAL （Hardware Abstraction Layer，硬件抽象层）
上层应用不必关心具体实现的是什么硬件；
硬件厂家如果要更改硬件设备，只要按照HAL接口规范和标准提供对应的硬件驱动，而不需改变应用；
HAL简化了应用程序查询硬件的逻辑，而把这一部分的复杂性交给HAL统一处理。
HAL所谓的抽象并不提供对硬件的实际操作，对硬件的操作仍然由具体的驱动程序来完成。

#### Android为何引入HAL
GPL（General Public License） ，Linux Kernel 遵循GPL许可证；对源码的任何更改都必须向社会公开
ASL（Apache Software License），Android 遵循ASL许可证；可以随意使用源码，不必开源
把关键驱动转移到Android平台内，Linux kernel中仅保留基础通信功能

## 主要技术准备
### 同步异步
Synchronous（同步）；Asynchronous（异步）
同步调用，在发起一个函数或方法调用时，没有得到结果前，该调用不反回，一直到结果返回
异步调用，一个异步调用发起后，被调用者立即返回给调用者，但调用者不能立即得到结果，被调用者在实际处理这个调用的请求完成后，通过状态、通知或回调等方式来通知调用者请求处理的结果

同步就是发出一个请求后啥都不做，一直等待请求返回后才继续做事；异步就是发出请求后继续做其他事，这个请求处理完成后会通知你

### Handler
Handler运行在主线程（Activity UI线程）中，它与子线程可以通过Message对象来传递数据。
这时，Handler就承担着接收子线程传过来的Message对象，从而配合主线程更新UI。

### AIDL（Android Interface Definition Language）
程序员可以利用AIDL自定义编程接口，在客户端和服务端之间实现进程间通信（IPC）。在Android平台上，一个进程通常不能访问另外一个进程的内存空间，因此，Android平台将这些跨进程访问的对象分解成操作系统能够识别的简单对象。并为跨应用访问而特殊编排和整理这些对象。用于编排和整理这些对象的代码编写起来十分冗长，所以Android的AIDL提供了相关工具来自动生成这些代码。

#### 例子：创建两个apk，一个作为服务提供方，一个作为AIDL服务调用方。
android studio
##### AIDL服务方代码
一共4步
1.先进入服务方的工程，在`com.rust.aidl`包内创建`IMyService.aidl`文件
```
// IMyService.aidl
package com.rust.aidl;

// Declare any non-default types here with import statements

interface IMyService {
    /**
     * Demonstrates some basic types that you can use as parameters
     * and return values in AIDL.
     */
    void basicTypes(int anInt, long aLong, boolean aBoolean, float aFloat,
            double aDouble, String aString);
    String helloAndroidAIDL(String name);// 此次使用的方法
}

```
2.在`com.rust.service`包内创建`MyService.java`文件；有一个内部类`MyServiceImpl`实现接口的功能
```java
package com.rust.service;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.os.RemoteException;
import android.support.annotation.Nullable;
import android.util.Log;

import com.rust.aidl.IMyService;

public class MyService extends Service {

    public class MyServiceImpl extends IMyService.Stub {
        @Override
        public void basicTypes(int anInt, long aLong, boolean aBoolean, float aFloat,
                               double aDouble, String aString) throws RemoteException {

        }

        public String helloAndroidAIDL(String name) throws RemoteException {
            Log.d("aidl", "helloAndroidAIDL heard from : " + name);
            return "Rust: Service01 return value successfully!";
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return new MyServiceImpl();// 返回内部类实例
    }
}
```
3.实现了MyService类后，对此AIDL服务进行配置；在`AndroidManifest.xml`文件中配置
```xml
        <service android:name="com.rust.service.MyService">
            <intent-filter>
                <action android:name="com.rust.aidl.IMyService" />
            </intent-filter>
        </service>
```
service写实现类`MyService`；action里面写上AIDL文件
4.发布运行此apk
##### AIDL调用方代码
建立（或进入）AIDL调用方的工程，这里是MyAIDLTest工程。有如下3个步骤：
1.将AIDL服务端生成的Java文件复制到调用方工程里，尽量保持这个Java文件的路径与服务端的一致，便于识别
2.写代码绑定服务，获取AIDL服务对象
3.通过AIDL服务对象完成AIDL接口调用

本例中，生成的Java文件路径为：`服务端/app/build/generated/source/aidl/debug/com/rust/aidl/IMyService.java`
将其复制到调用方工程下：`MyAIDLTest/app/src/main/java/com/rust/aidl/IMyService.java`
编写调用方`MainActivity.java`代码
```java
package rust.myaidltest;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.IBinder;
import android.os.RemoteException;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import com.rust.aidl.IMyService;

public class MainActivity extends AppCompatActivity {

    Button aidlBtn;
    IMyService myService;// 服务
    String appName = "unknown";

    private ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            myService = IMyService.Stub.asInterface(service);// 获取服务对象
            aidlBtn.setEnabled(true);
        }// 连接服务

        @Override
        public void onServiceDisconnected(ComponentName name) {

        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        aidlBtn = (Button) findViewById(R.id.aidl_1_btn);
        appName = getPackageName();

        // 我们没办法在构造Intent的时候就显式声明.
        Intent intent = new Intent("com.rust.aidl.IMyService");
        // 既然没有办法构建有效的component,那么给它设置一个包名也可以生效的
        intent.setPackage("com.rust.aboutview");// the service package
        // 绑定服务，可设置或触发一些特定的事件
        bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);


        aidlBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    // AIDL服务调用代码如下：
                    String msg = myService.helloAndroidAIDL(appName);
                    Toast.makeText(getApplicationContext(), msg, Toast.LENGTH_SHORT).show();
                } catch (RemoteException e) {
                    e.printStackTrace();
                }
            }
        });
    }
}
```
##### 效果
点击调用端的按钮，弹出Toast：`Rust: Service01 return value successfully!`
服务端apk打印log：`helloAndroidAIDL heard from : rust.myaidltest`
其中，`rust.myaidltest`就是调用端传入的自身的包名
服务端更新后，如果aidl文件没改动，不需要更新生成的Java文件
如果服务端apk被卸载，调用端使用此服务时会出错


## Dialer 解构
Android M

点击拨号器，打开的第一个界面是`DialtactsActivity.java` `dialtacts_activity.xml`

`DialtactsActivity`里有内部类`OptionsPopupMenu`
复写show方法，先检查联系人的权限，然后决定菜单的选项

`LayoutOnDragListener`类实现拖动监听类

`remove_view_text.xml` 装载了ViewPager和dialer.list.RemoveView

`empty_content_view.xml` `EmptyContentView.java`在快速拨号界面为空时显示，call log和all contact界面同理
里面装了1个ImageView，2个TextView
有个bug就是EmptyContentView的显示问题：横屏时最下面那个TextView超出了屏幕，显示不全。
样机屏幕宽度四百多，高度八百多，可供显示的地方不够。可以把图片改小一点，就不会超出去了。

------

```java
    final Resources res = getResources();// 获取资源
```

Java中数组的表示方法；`long...`要放在最后的位置
```java

    long[] x = {3, 5, 6, 7, 87, 2};// 数组
    testLong(x);
    testLong("rust", x);
    ......
    private void testLong(long... x) {
        testLong(null, x);
    }

    private void testLong(String word, long... x) {
        if (!TextUtils.isEmpty(word)) {
            Log.d(TAG, "I said: " + word);
        }
        Log.d(TAG, "long... >>   " + x);
        Log.d(TAG, "x.length = " + x.length);
        x[4] += 2;
        for (long o : x) {
            Log.d(TAG, " " + o + ", ");
        }
    }
```
和普通的数组没什么差别
