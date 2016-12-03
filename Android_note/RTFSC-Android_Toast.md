---
title: Android 源码 Toast.show() 小记
date: 2015-12-12 20:10:20
category: Android_note
tag: [Android]
---
Android M

`Toast.java (frameworks/base/core/java/android/widget)`

Toast为用户弹出一个小的消息框，Toast类可以创建并显示这些消息框

传入Context，字符串，周期值。makeText返回一个Toast实例。消息装入TextView中，设定周期值。
```java
public static Toast makeText(Context context, CharSequence text, @Duration int duration) {
    Toast result = new Toast(context);

    LayoutInflater inflate = (LayoutInflater)
            context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    View v = inflate.inflate(com.android.internal.R.layout.transient_notification, null);
    TextView tv = (TextView)v.findViewById(com.android.internal.R.id.message);
    tv.setText(text);

    result.mNextView = v;
    result.mDuration = duration;

    return result;
}
```
有了Toast实例后，调用show方法，将消息弹出。弹出的动作要依靠INotificationManager
```java
public void show() {
    if (mNextView == null) {
        throw new RuntimeException("setView must have been called");
    }

    INotificationManager service = getService();
    String pkg = mContext.getOpPackageName();
    TN tn = mTN;
    tn.mNextView = mNextView;

    try {
        service.enqueueToast(pkg, tn, mDuration);
        //这里是 NotificationManagerService，塞进队列中
    } catch (RemoteException e) {
        // Empty
    }
}
```

```java
static private INotificationManager getService() {
    if (sService != null) {
        return sService;
    }
    sService = INotificationManager.Stub.asInterface(ServiceManager.getService("notification"));
    return sService;
}
```

`frameworks/base/core/java/android/app/INotificationManager.aidl`

`frameworks/base/core/java/android/app/NotificationManager.java`
```java
/** @hide */
static public INotificationManager getService()
{
    if (sService != null) {
        return sService;
    }
    IBinder b = ServiceManager.getService("notification");
    sService = INotificationManager.Stub.asInterface(b);
    return sService;
}
```

`ServiceManager.java (frameworks/base/core/java/android/os)`

根据传入的名字返回一个service实例
```java
public static IBinder getService(String name) {
    try {
        IBinder service = sCache.get(name);
        if (service != null) {
            return service;
        } else {
            return getIServiceManager().getService(name);
        }
    } catch (RemoteException e) {
        Log.e(TAG, "error in getService", e);
    }
    return null;
}
```

frameworks/base/services/core/java/com/android/server/notification/NotificationManagerService.java
```java
private final IBinder mService = new INotificationManager.Stub() {
    // Toasts
    // ......

    @Override
    public void enqueueToast(String pkg, ITransientNotification callback, int duration)
    {
// ......
```

最后弹出消息的是  
`Toast.java`中的内部类TN，`Toast.java` (frameworks/base/core/java/android/widget)
```java
final Runnable mShow = new Runnable() {
    @Override
    public void run() {
        handleShow();// 处理弹出动作
    }
};
//......
@Override
public void show() {
    if (localLOGV) Log.v(TAG, "SHOW: " + this);
    mHandler.post(mShow);
}
//...... handleShow处理弹出消息的样式
public void handleShow() {
    if (localLOGV) Log.v(TAG, "HANDLE SHOW: " + this + " mView=" + mView
            + " mNextView=" + mNextView);
    if (mView != mNextView) {
        // remove the old view if necessary
        handleHide();
        mView = mNextView;
        Context context = mView.getContext().getApplicationContext();
        String packageName = mView.getContext().getOpPackageName();
        if (context == null) {
            context = mView.getContext();
        }
        mWM = (WindowManager)context.getSystemService(Context.WINDOW_SERVICE);
        // We can resolve the Gravity here by using the Locale for getting
        // the layout direction
        final Configuration config = mView.getContext().getResources().getConfiguration();
        final int gravity = Gravity.getAbsoluteGravity(mGravity, config.getLayoutDirection());
        mParams.gravity = gravity;
        if ((gravity & Gravity.HORIZONTAL_GRAVITY_MASK) == Gravity.FILL_HORIZONTAL) {
            mParams.horizontalWeight = 1.0f;
        }
        if ((gravity & Gravity.VERTICAL_GRAVITY_MASK) == Gravity.FILL_VERTICAL) {
            mParams.verticalWeight = 1.0f;
        }
        mParams.x = mX;
        mParams.y = mY;
        mParams.verticalMargin = mVerticalMargin;
        mParams.horizontalMargin = mHorizontalMargin;
        mParams.packageName = packageName;
        if (mView.getParent() != null) {
            if (localLOGV) Log.v(TAG, "REMOVE! " + mView + " in " + this);
            mWM.removeView(mView);
        }
        if (localLOGV) Log.v(TAG, "ADD! " + mView + " in " + this);
        mWM.addView(mView, mParams);
        trySendAccessibilityEvent();
    }
}
```
