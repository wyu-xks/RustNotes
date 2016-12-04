---
title: Android ANR
date: 2015-09-27 15:09:15
category: Android_note
tag: [ANR]
toc: true
---

## ANR是什么
ANR,是“Application Not Responding”的缩写,即“应用程序无响应”。
如果应用程序主线程在超时时间内对输入事件没有处理完毕,或者对特定操作没有执行完毕,就会出现 ANR。
在Android4.4以后版本上,开发者可以选择监视ContentProvider子线程的ANR超时。

## ANR的三条件
主线程:只有应用程序进程的主线程响应超时才会产生 ANR
用户输入/特定操作:用户输入是指按键、触屏等设备输入事件;特定操作是指BroadcastReceiver 和Service 的
生命周期中的各个函数。产生个函数。产生 ANR 的上下文不同,报出 ANR 的原因也会不同。

## ANR问题的类型
- Input dispatching超时。
- BroadcastReceiver 执行超时。
- Service 各生命周期函数执行超时。
- ContentProvider 相关操作执行超时。

在开始分析前,一定要先明确是哪类ANR。

Input dispatching超时
用户输入事件处理超时
窗口获取焦点超时

### 用户输入事件处理超时
原因:主线程对输入事件在 5 秒内没有处理完毕
提示语:Reason: Input dispatching timed out (Waiting because the focused window has not finished
processing the input events that were previously delivered to it.)

产生这种 ANR 的前提是要有输入事件,如果用户没有触发任何输入事件，即便是主线程阻塞了,也不会产生ANR，因为
 InputDispatcher 没有分发事件给应用程序,
当然也不会检测处理超时和报告 ANR 了。

##### ANR模拟 - 主线程超时未响应
现在模拟一下主线程超时未响应；  
新建一个testanre app，在MainActivity.java中定义2个button
```java
public class MainActivity extends Activity {
    private TextView tv1;
    private Button btn1;
    private Button btn2;
    private int pushButton2 = 0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        tv1 = (TextView) findViewById(R.id.tv1);
        btn1 = (Button) findViewById(R.id.btn1);
        btn2 = (Button) findViewById(R.id.btn2);
        btn1.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View arg0) {
                try {
                    Thread.sleep(11 * 1000);//主线程等待
                } catch (InterruptedException e) {
                    Log.e("rust", "DEAD");
                }
            }
        });

        btn2.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View arg0) {
                pushButton2++;
                tv1.setText("U push button2 :" + pushButton2);
            }
        });
    }
}
```
app装到机器上，点击btn2，看到数字增加；点击btn1，主线程进入死循环，再点几下btn2也没反应  
产生ANR后，生成/data/anr/traces.txt文件
```log
10-14 14:47:23.079: E/ActivityManager(2835): ANR in com.rust.testanre (com.rust.testanre/.MainActivity)
10-14 14:47:23.079: E/ActivityManager(2835):   98% 10614/com.rust.testanre: 98% user + 0.3% kernel / faults: 1711 minor
10-14 14:47:23.079: E/ActivityManager(2835):   100% 10614/com.rust.testanre: 100% user + 0% kernel
10-14 14:47:23.079: E/ActivityManager(2835):     100% 10614/m.rust.testanre: 100% user + 0% kernel
10-14 14:47:35.775: E/CRASHLOG(2533): CRASH   683c4835534e7bb4572b  2015-10-14/14:47:35  ANR /data/logs/crashlog5
10-14 14:47:45.927: I/art(10614): Thread[5,tid=10622,WaitingInMainSignalCatcherLoop,Thread*=0x7f5269c2a400,peer=0x12c000a0,"Signal Catcher"]: reacting to signal 3
10-14 14:47:45.984: I/art(10614): Wrote stack traces to '/data/anr/traces.txt'
```
主线程中不能执行耗时过长的操作，比如操作网络或数据库，高耗时的计算，大量数据的排序计算等等  
这些应该放到子线程中进行；把上面的死循环放入子线程中
```java
        btn1.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View arg0) {
                new Thread(new Runnable(){
                    @Override
                    public void run() {
                        while(true){}//新启一个子线程来运行死循环
                    }
                }).start();
            }
        });
```
运行程序，点击btn1后，btn2不受什么影响

出现此类型ANR时，重点检查主线程中有没有耗时的操作，是否存在死锁死循环  

如果在MainActivity的onPause()方法中存在死循环，MainActivity第一次运行时正常；一旦尝试跳转去SecondActivity，会黑屏  
点击一下屏幕，log如下
```
10-14 17:03:33.592: I/InputDispatcher(2835): Dropping event because there is no touchable window at (941, 701).
```
点击返回键，尝试回到MainActivity，产生ANR

在activity生命周期的各个方法里，不能出现死循环

### 产生 ANR 的上下文不同，报出 ANR 的原因也会不同。
-------------------------------------------------------------------------------------------------
#### 窗口获取焦点超时
原因: 焦点应用在5 秒内没有获得窗口焦点
提示语:Reason: Input dispatching timed out (Waiting because no window has focus but there is a
 focused application that may eventually add a window when it finishes starting up.)

#### BroadcastReceiver 执行超时
原因: 主线程在执行 BroadcastReceiver 的 onReceive 函数时10/60 秒内没有执行完毕
提示语:Reason: Broadcast of Intent { act=android.net.wifi.WIFI_STATE_CHANGED flg=0x4000010
cmp=com.android.settings/.widget.SettingsAppWidget Provider (has extras) }

BroadcastReceiver的 onReceive 函数运行在主线程中,当这个函数超过 10秒钟没有返回就会触发 ANR。不过对
这种情况的 ANR 系统不会显示对话框提示,仅是输出 log 而已。

#### Service 各生命周期函数执行超时
原因: 主线程在执行 Service 的各个生命周期函数时 20 秒内没有执行完毕

提示语:Reason: Executing service com.android.bluetooth/.btservice.AdapterService
Service 的各个生命周期函数,如OnStart、OnCreate、OnStop也运行在主线程中,当这些函数超过 20 秒钟没有
返回就会触发 ANR。同样对这种情况的 ANR 系统也不会显示对话框提示,仅是输出 log。

#### ContentProvider 相关操作执行超时
原因: 主线程在执行 ContentProvider 相关操作时没有在规定的时间内执行完毕。
提示语:Reason: ContentProvider not responding

## 4.4新增功能,由应用程序自行设置是否启用以及超时时间。
ContentProviderClient.java
beforeRemote() :例如 query 函数开始执行此方法
afterRemote :例如 query 函数结束时执行此方法
setDetectNotResponding() :提供给应用自行设置是否启用此功能

ContentProvider 相关操作执行超时
源码中只发现一处启用此功能的代码:
DocumentsUI/src/com/android/documentsui/DocumentsApplication.java


## 应用如何避免ANR?
不要假设一个操作不耗时

避免将耗时的操作放在主线程,耗时操作包括:

数据库操作。 数据库操作尽量采用异步方法做处理
初始化的数据和控件太多
频繁的创建线程或者其它大对象;
加载过大数据和图片;
对大数据排序和循环操作;
过多的广播和滥用广播;
大对象的传递和共享;
访问网络

## 如何分析ANR?
问自己三个问题
应用程序主线程在做什么?
CPU占用率多高?
内存使用量多高?

### 应用程序主线程在做什么?
死锁
阻塞
死循环
低性能

### CPU占用率多高?
应用是否CPU占用率过高?
应用的服务端是否CPU占用率过高?
系统服务是否CPU占用率过高?
系统IOWait是否过高?
单核设备上是否CPU占用率100%?
多核设备是否只启动了一个CPU?
多核设备上各CPU的占用率如何?

### 内存使用量多高?
应用是否出现了Out of memory
应用是否在频繁GC?
应用GC时间是否过长?
应用的内存使用量是否够高?
系统内存剩余多少?
系统内存脏页是否过多?
系统是否出现了OOM错误?

System.log中的信息
ANR发生的第一现场，比如Input event dispatching timed out sending to ...

通过ANR第一现场的时间和ANR类型,可以找到出错时间段,
压缩需要分析的时间范围


### 坏的ANR分析
缺乏逻辑联系
孤证和臆断

### 好的ANR分析
查找异常现象
Camera Handler被sigkill杀死,而Camera需要用它与HAL通信,故Camera发生ANR。
Kernel信息显示写SD卡命令超时,Trace文件中看到应用主线程停在写文件上,请检查SD卡相关模块

### 找到异常与ANR可能的联系
CPU负载超过14,main.log中一秒打出500行logANR发生前发现信息stack corruption detected: aborted ,请
调查是否异常。
Kernel.log有5个,平时只有一个
