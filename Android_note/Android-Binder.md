---
title: Android-Binder
date: 2015-10-26 15:09:31
category: Android_note
tag: [Android_frameworks]
toc: true
---


IDE Android Studio 2.3

本文索引：
* 为什么要了解Binder机制？
* Binder介绍
* 应用开发者怎么使用Binder，AIDL使用简介

## 为什么要了解Binder机制
要想知道不同进程的Activity或Service是如何通信的，需要了解Android中的Binder进程间通信机制。

## Binder介绍
Android使用Linux的进程管理机制，以进程为单位分配虚拟地址空间。  
为保证安全，不同进程之间是相互隔离的。Android**进程间使用Binder方式进行通讯**。

### Android之所以选择Binder而不是传统IPC机制的原因
主要有2个方面的原因
* 1、安全，每个进程都会被Android系统分配UID和PID，不像传统IPC在数据里加入UID，这就让那些恶意进程无法直接和其他进程通信，进程间通信的安全性得到提升。  
* 2、高效，socket作为一款通用接口，其传输效率低，开销大，主要用在跨网络的进程间通信和本机上进程间的低速通信。Binder数据拷贝次数只要1次，在手机这种资源紧张的情况下很重要。

Binder基于Client-Server通信模式，传输过程只需一次拷贝，为发送发添加UID/PID身份，既支持实名Binder也支持匿名Binder，安全性高。

参考表 - 各种IPC方式数据拷贝次数

|IPC  | 数据拷贝次数 |
|:-------:|:--------|
|共享内存 | 0  |
|Binder  | 1  |
|Socket 管道 消息队列| 2 |

### Binder结构
Binder使用Client-Server通信方式（C/S体系结构）。
Service组件所在的进程称为Server进程，使用Service的组件所在进程称为Client进程。

C/S体系结构通常由以下部分组成：  
* 用户端（Client）：是C/S体系结构中使用server端提供Service的一方
* 服务端（Server）：是C/S体系结构中为Client端提供Service的一方
* 服务代理（Proxy）：位于Client端，提供访问服务的接口
* 服务存根（Stub）：位于Server端，屏蔽Proxy与Server端通信的细节
* 服务（Service）：运行于Server端，提供具体的功能处理Client端的请求
* 通信协议：Client和Server可以运行在不同的进程中，主要用Binder作为通信协议

组件servicemanager（本身也是一个Server），提供了Service注册和Service检索功能。它自身维护一个Service信息列表。Client只需向servicemanager提供所需Service名字，便可获取Service信息。

app启动时，或者进行广播时，都会进入`ActivityManagerNative.java`中的类`ActivityManagerProxy`  
app启动startActivity；广播使用`broadcastIntent`；进入`ActivityManagerService`，调用相应的方法


## AIDL（Android Interface Definition Language） 统一的通信接口
AIDL（Android Interface Definition Language, Android 接口定义语言）  
用于定义C/S体系结构中Server端可以提供的服务调用接口，框架层提供的Java系统服务接口大多由AIDL语言定义。
Android提供了AIDL工具，可将AIDL文件编译成Java文件。提高服务开发的效率

程序员可以利用AIDL自定义编程接口，在客户端和服务端之间实现进程间通信（IPC）。
在Android平台上，一个进程通常不能访问另外一个进程的内存空间，因此，Android平台将这些跨进程访问的对象分解成操作系统能够识别的简单对象。
并为跨应用访问而特殊编排和整理这些对象。用于编排和整理这些对象的代码编写起来十分冗长，所以Android的AIDL提供了相关工具来自动生成这些代码。

开发人员只需要在AIDL文件中定义Server端可以提供的服务方法，AIDL工具便可将其转化为Java文件。转化后的Java文件包含C/S体系结构的以下内容：
- 服务接口 （IPowerManager）
- 服务在Client端的代理（Proxy）
- 服务存根（Stub）
- Binder类型与IIterface类型的转换接口（asInterface 和 asBinder 方法）
- 服务方法请求码

AIDL意义：  
AIDL工具建立了基于Binder的C/S体系结构的通用组件；
开发者可以专注于开发服务的功能，而不需理会具体的通信结构，提高效率

### 例子：创建两个apk，一个作为服务提供方，一个作为AIDL服务调用方。

#### AIDL服务提供方代码
首先是AIDL服务提供方主要文件目录  
```
main/aidl/
`-- com
    `-- rustfisher
        `-- ndkproj
            `-- ITomInterface.aidl // AIDL代码

main/java
`-- com
    `-- rustfisher
        |-- tom
        |   `-- TomService.java // 对应的Service

build/generated/source/aidl/
`-- debug
    `-- com
        `-- rustfisher
            `-- ndkproj
                `-- ITomInterface.java // 工程编译后AIDL生成的Java文件 提供给调用方
```

一共4步  
##### 1.新建AIDL文件并写好接口

进入服务方的工程，右键新建AIDL文件`ITomInterface.aidl`。  
文件会默认生成在`main/aidl/com/rustfisher/ndkproj`下
```java
// ITomInterface.aidl
package com.rustfisher.ndkproj;

// 文件名应该和接口名相同
// 编写好AIDL文件后可以先编译一次
interface ITomInterface {
    void basicTypes(int anInt, long aLong, boolean aBoolean, float aFloat,
            double aDouble, String aString);
    String helloAIDL(String name); // 此次使用的方法
}
```

##### 2.编写服务方的接口实现代码  
在`com.rustfisher.tom`包内创建`TomService.java`文件；建立内部类`TomServiceImpl`实现接口的功能
```java
import com.rustfisher.ndkproj.ITomInterface;

public class TomService extends Service {
    private static final String TAG = "rustApp";

    public class TomServiceImpl extends ITomInterface.Stub {

        @Override
        public void basicTypes(int anInt, long aLong, boolean aBoolean, float aFloat, double aDouble, String aString) throws RemoteException {

        }

        @Override
        public String helloAIDL(String name) throws RemoteException {
            Log.d(TAG, name + " requires helloAIDL()");
            return "Hello " + name + ", nice to meet you!";
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return new TomServiceImpl(); // 绑定服务则返回 TomServiceImpl 实例
    }
}
```

##### 3.服务方在`AndroidManifest.xml`文件中配置
实现了`TomService`类后，对此AIDL服务进行配置；在`AndroidManifest.xml`文件中配置
```xml
        <service android:name="com.rustfisher.tom.TomService">
            <intent-filter>
                <action android:name="com.rustfisher.ndkproj.ITomInterface" />
            </intent-filter>
        </service>
```
action里面写上AIDL文件
##### 4.安装运行此apk到手机上
让服务方运行起来

#### AIDL调用方代码（客户端）
建立（或进入）AIDL调用方的工程，这里是aidlcaller工程。

主要文件目录
```
java/
`-- com
    |-- rust
    |   `-- aidlcaller
    |       `-- MainActivity.java // 演示用的
    `-- rustfisher
        `-- ndkproj // 这个路径尽量保持与服务提供方那里的一致
            `-- ITomInterface.java // 从服务方那里copy来的
```

有如下3个步骤：
* 1.将AIDL服务端生成的Java文件复制到调用方工程里，尽量保持这个Java文件的路径与服务端的一致，便于识别
* 2.写代码绑定服务，获取AIDL服务对象
* 3.通过AIDL服务对象完成AIDL接口调用

编写调用方`MainActivity.java`代码
```java
import com.rustfisher.ndkproj.ITomInterface;

public class MainActivity extends AppCompatActivity {

    private static final String TAG = "rustApp";
    ITomInterface mTomService; // AIDL 服务
    TextView mTv1;

    private ServiceConnection serviceConnection = new ServiceConnection() {
        @Override
        public void onServiceConnected(ComponentName name, IBinder service) {
            mTomService = ITomInterface.Stub.asInterface(service);// 获取服务对象
            mTv1.setClickable(true); // 需要等服务绑定好  再允许点击
            Log.d(TAG, "[aidlcaller] onServiceConnected");
        }

        @Override
        public void onServiceDisconnected(ComponentName name) {
            Log.d(TAG, "onServiceDisconnected " + name);
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        initAIDLService();
        initUI();
    }

    private void initUI() {
        mTv1 = (TextView) findViewById(R.id.tv1);
        mTv1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    String hello = mTomService.helloAIDL("Jerry");
                    Log.d(TAG, hello);
                } catch (Exception e) {
                    Log.e(TAG, "mTomService initAIDLService: Fail ", e);
                    e.printStackTrace();
                }
            }
        });
    }

    private void initAIDLService() {
        // 这个是服务提供方的AndroidManifest action
        Intent intent = new Intent("com.rustfisher.ndkproj.ITomInterface");
        intent.setPackage("com.rustfisher.ndkproj"); // 服务提供者的包名
        bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE);
    }
}
```

#### 测试和效果
点击调用端的View，打出log `Hello Jerry, nice to meet you!`
服务端apk打印log：`Jerry requires helloAIDL()`

如果调用失败则抛出 `android.os.DeadObjectException`

当服务提供方App没有在运行时，调用方去请求服务会失败。

服务端更新后，如果aidl文件没改动，不需要更新生成的Java文件
如果服务端apk被卸载，调用端使用此服务时会出错

## 参考资料  
[universus的专栏 - Android Bander设计与实现 - 设计篇](http://blog.csdn.net/universus/article/details/6211589)

[老罗的Android之旅 - Android进程间通信（IPC）机制Binder简要介绍和学习计划](http://blog.csdn.net/luoshengyang/article/details/6618363)

[Android Binder机制原理](http://blog.csdn.net/boyupeng/article/details/47011383)


## 其他基础简介
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

### RPC(Remote Procedure Call Protocol)
RPC是指远程过程调用，也就是说两台服务器A，B，一个应用部署在A服务器上，想要调用B服务器上应用提供的函数/方法，由于不在一个内存空间，不能直接调用，需要通过网络来表达调用的语义和传达调用的数据。

![RPC_flow](https://raw.githubusercontent.com/RustFisher/Rustnotes/master/Android_note/pics/RPC_flow.jpg)
