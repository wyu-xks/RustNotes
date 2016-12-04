---
title: RTFSC Android Broadcast
date: 2015-12-19 20:10:31
category: Android_note
tag: [Android,RTFSC]
---

|Android版本|系统|IDE|
|:-----:|:-----:|:------:|
|5.1|Ubuntu 14.04|SourceInsight3|

四大组件之一；BroadCast与BroadCastReceiver配合使用；进程间的通讯机制  
我们知道，Android进程间可以使用Binder进行通讯；广播也是进程间通讯的方式

* 普通广播：sendBroadcast  谁都可以接收  
* 串行广播：sendOrderedBroadcast  按接受者的优先级将广播一个个地发送过去，上一个处理
完毕后，才会发送给下一个接受者。任一个接受者都可以终止后续的广播流程。  
* Sticky广播：sendStickyBroadcast  接收器立即收到系统发送的sticky广播

## sendBroadcast(Intent)流程分析
###### 1.ContextWrapper类
ContextWrapper继承自Context，并且复写了发送广播的方法。先看看普通广播的发送流程  
ContextWrapper.java (frameworks/base/core/java/android/content)  
```java
public class ContextWrapper extends Context {
    Context mBase;

    @Override
    public void sendBroadcast(Intent intent) {
        mBase.sendBroadcast(intent);
    }
    @Override
    public void sendBroadcast(Intent intent, String receiverPermission) {
        mBase.sendBroadcast(intent, receiverPermission);
    }
```
Context.java (frameworks/base/core/java/android/content)  
在Context类中，对发送广播的抽象方法有详细的解释  
例如sendBroadcast的说明：把收到的intent发送给所有感兴趣的广播接收器。这个调用是异步的，
能的立刻返回，在接收器继续执行时，程序能继续执行。接收器不能停止广播。

###### 2.ContextImpl类
和ContextWrapper一样，也继承自Context，复写了Context的API，提供给activity和其他组件  
`ContextImpl.java` (frameworks/base/core/java/android/app)

以sendBroadcast方法为例
```java
@Override
public void sendBroadcast(Intent intent) {
    warnIfCallingFromSystemProcess();
    String resolvedType = intent.resolveTypeIfNeeded(getContentResolver());
    try {
        intent.prepareToLeaveProcess();
        ActivityManagerNative.getDefault().broadcastIntent(
            mMainThread.getApplicationThread(), intent, resolvedType, null,
            Activity.RESULT_OK, null, null, null, AppOpsManager.OP_NONE, false, false,
            getUserId());
    } catch (RemoteException e) {
    }
}
```
如果系统进程直接调用了系统级的方法，打个警告log  
intent准备离开这个进程；接下来进入ActivityManagerNative

###### 3.ActivityManagerNative
ActivityManagerNative.java (frameworks/base/core/java/android/app)  
```java
class ActivityManagerProxy implements IActivityManager
//... ...
    public int broadcastIntent(IApplicationThread caller,
            Intent intent, String resolvedType,  IIntentReceiver resultTo,
            int resultCode, String resultData, Bundle map,
            String requiredPermission, int appOp, boolean serialized,
            boolean sticky, int userId) throws RemoteException
    {
        Parcel data = Parcel.obtain();
        Parcel reply = Parcel.obtain();
        data.writeInterfaceToken(IActivityManager.descriptor);
        data.writeStrongBinder(caller != null ? caller.asBinder() : null);
        intent.writeToParcel(data, 0);
        data.writeString(resolvedType);
        data.writeStrongBinder(resultTo != null ? resultTo.asBinder() : null);
        data.writeInt(resultCode);
        data.writeString(resultData);
        data.writeBundle(map);
        data.writeString(requiredPermission);
        data.writeInt(appOp);
        data.writeInt(serialized ? 1 : 0);
        data.writeInt(sticky ? 1 : 0);
        data.writeInt(userId);
        mRemote.transact(BROADCAST_INTENT_TRANSACTION, data, reply, 0);
        reply.readException();
        int res = reply.readInt();
        reply.recycle();
        data.recycle();
        return res;
    }
```
内部类ActivityManagerProxy中定义了broadcastIntent；把参数封装好
###### 4.ActivityManagerService接受Binder传来的broadcastIntent数据
ActivityManagerService.java (frameworks/base/services/core/java/com/android/server/am）
```java
    public final int broadcastIntent(IApplicationThread caller,
            Intent intent, String resolvedType, IIntentReceiver resultTo,
            int resultCode, String resultData, Bundle map,
            String requiredPermission, int appOp, boolean serialized, boolean sticky, int userId) {
        enforceNotIsolatedCaller("broadcastIntent");
        synchronized(this) {
            intent = verifyBroadcastLocked(intent);

            final ProcessRecord callerApp = getRecordForAppLocked(caller);
            final int callingPid = Binder.getCallingPid();
            final int callingUid = Binder.getCallingUid();
            final long origId = Binder.clearCallingIdentity();
            int res = broadcastIntentLocked(callerApp,
                    callerApp != null ? callerApp.info.packageName : null,
                    intent, resolvedType, resultTo,
                    resultCode, resultData, map, requiredPermission, appOp, serialized, sticky,
                    callingPid, callingUid, userId);
            Binder.restoreCallingIdentity(origId);
            return res;
        }
    }
```
调用方法broadcastIntentLocked；

###### 5.ActivityManagerService.broadcastIntentLocked
这个方法执行了很多操作；比如改变时区，改变时间
```java
case Intent.ACTION_TIMEZONE_CHANGED:
    // If this is the time zone changed action, queue up a message that will reset
    // the timezone of all currently running processes. This message will get
    // queued up before the broadcast happens.
    mHandler.sendEmptyMessage(UPDATE_TIME_ZONE);
    break;
```

```java
queue.enqueueOrderedBroadcastLocked(r);
queue.scheduleBroadcastsLocked();
```

###### 6.BroadcastQueue.java
(frameworks/base/services/core/java/com/android/server/am)

```java
    public void scheduleBroadcastsLocked() {
        if (DEBUG_BROADCAST) Slog.v(TAG, "Schedule broadcasts ["
                + mQueueName + "]: current="
                + mBroadcastsScheduled);

        if (mBroadcastsScheduled) {
            return;
        }
        mHandler.sendMessage(mHandler.obtainMessage(BROADCAST_INTENT_MSG, this));
        mBroadcastsScheduled = true;
    }
```
```java
final void processNextBroadcast(boolean fromMsg)
```
```java
private final void deliverToRegisteredReceiverLocked(BroadcastRecord r,
            BroadcastFilter filter, boolean ordered)
```
```java
    private static void performReceiveLocked(ProcessRecord app, IIntentReceiver receiver,
            Intent intent, int resultCode, String data, Bundle extras,
            boolean ordered, boolean sticky, int sendingUser) throws RemoteException {
        // Send the intent to the receiver asynchronously using one-way binder calls.
        if (app != null) {
            if (app.thread != null) {
                // If we have an app thread, do the call through that so it is
                // correctly ordered with other one-way calls.
                app.thread.scheduleRegisteredReceiver(receiver, intent, resultCode,
                        data, extras, ordered, sticky, sendingUser, app.repProcState);
            } else {
                // Application has died. Receiver doesn't exist.
                throw new RemoteException("app.thread must not be null");
            }
        } else {
            receiver.performReceive(intent, resultCode, data, extras, ordered,
                    sticky, sendingUser);
        }
    }
```

###### 7.ApplicationThreadNative.java
(frameworks\base\core\java\android\app)  

```java
class ApplicationThreadProxy implements IApplicationThread {
    private final IBinder mRemote;
//..........
    public void scheduleRegisteredReceiver(IIntentReceiver receiver, Intent intent,
            int resultCode, String dataStr, Bundle extras, boolean ordered,
            boolean sticky, int sendingUser, int processState) throws RemoteException {
        Parcel data = Parcel.obtain();
        data.writeInterfaceToken(IApplicationThread.descriptor);
        data.writeStrongBinder(receiver.asBinder());
        intent.writeToParcel(data, 0);
        data.writeInt(resultCode);
        data.writeString(dataStr);
        data.writeBundle(extras);
        data.writeInt(ordered ? 1 : 0);
        data.writeInt(sticky ? 1 : 0);
        data.writeInt(sendingUser);
        data.writeInt(processState);
        mRemote.transact(SCHEDULE_REGISTERED_RECEIVER_TRANSACTION, data, null,
                IBinder.FLAG_ONEWAY);
        data.recycle();
    }
```
是谁调用了scheduleRegisteredReceiver？还在``ApplicationThreadNative.java``中
```java
    @Override
    public boolean onTransact(int code, Parcel data, Parcel reply, int flags)
            throws RemoteException {
        switch (code) {
//......
        case SCHEDULE_REGISTERED_RECEIVER_TRANSACTION: {
            data.enforceInterface(IApplicationThread.descriptor);
            IIntentReceiver receiver = IIntentReceiver.Stub.asInterface(
                    data.readStrongBinder());
            Intent intent = Intent.CREATOR.createFromParcel(data);
            int resultCode = data.readInt();
            String dataStr = data.readString();
            Bundle extras = data.readBundle();
            boolean ordered = data.readInt() != 0;
            boolean sticky = data.readInt() != 0;
            int sendingUser = data.readInt();
            int processState = data.readInt();
            scheduleRegisteredReceiver(receiver, intent,
                    resultCode, dataStr, extras, ordered, sticky, sendingUser, processState);
            return true;
        }
```
接下来进入到应用程序的线程中
