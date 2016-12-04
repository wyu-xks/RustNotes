---
title: 认识 Android Context
date: 2015-09-23 15:09:13
category: Android_note
tag: [Android_frameworks]
---


Android L

## Context 自身
**Q：为何要了解Context？**  
**A：为了在使用的时候不犯迷糊**

context 意思有语境，上下文，背景，环境等等  
Android程序需要一个完整的工程环境。
Context是维持Android程序中各组件能够正常工作的一个核心功能类。

Context 类是一个 app 全局环境的“接口”，由 Android 系统提供继承类（例如Activity）。
它能连接到应用的资源和类，也能使用应用级的操作，比如启动activity，广播和接收intent。
```java
/**
 * Interface to global information about an application environment.  This is
 * an abstract class whose implementation is provided by
 * the Android system.  It
 * allows access to application-specific resources and classes, as well as
 * up-calls for application-level operations such as launching activities,
 * broadcasting and receiving intents, etc.
 */
public abstract class Context {
```
这是一个抽象类，接下来看看主要的几个实现类

## Context 的子类
先看我们熟悉的几个类：

Activity -> ContextThemeWrapper -> ContextWrapper -> Context
```java
public class Activity extends ContextThemeWrapper
```

Application -> ContextWrapper -> Context
```java
public abstract class Service extends ContextWrapper implements ComponentCallbacks2 {
```

Service - ContextWrapper -> Context
```java
public class Application extends ContextWrapper implements ComponentCallbacks2 {
```

简单的继承关系示意
```
Context
├── ContextImpl
└── ContextWrapper
    ├── Application
    ├── ContextThemeWrapper
    │   └── Activity
    └── Service
```

### ContextImpl
Context 是一个抽象类，子类 ContextImpl 实现了Context的方法；
为Activity和其他应用组件提供基本的context对象  
ContextImpl.java (frameworks\base\core\java\android\app)
```java
/**
 * Common implementation of Context API, which provides the base
 * context object for Activity and other application components.
 */
class ContextImpl extends Context {
    ......
    @Override
    public Context getApplicationContext() {
        return (mPackageInfo != null) ?
                mPackageInfo.getApplication() : mMainThread.getApplication();
    }
    ......
}
```

### ContextWrapper
Wrapper 有封装的意思；ContextWrapper是Context的封装类  

ContextWrapper.java (frameworks\base\core\java\android\content)
```java
/**
 * Proxying implementation of Context that simply delegates all of its calls to
 * another Context.  Can be subclassed to modify behavior without changing
 * the original Context.
 */
public class ContextWrapper extends Context {
    Context mBase;

    public ContextWrapper(Context base) {
        mBase = base;
    }
    ......
    @Override
    public Context getApplicationContext() {
        return mBase.getApplicationContext();
    }//
    ......
}
```
构造方法中传入一个 ContextImpl Context 实例，就变成ContextImpl的装饰者模式

### ContextThemeWrapper
允许在封装的context中修改主题（theme）  
ContextThemeWrapper.java (frameworks\base\core\java\android\view)
```java
/**
 * A ContextWrapper that allows you to modify the theme from what is in the
 * wrapped context.
 */
public class ContextThemeWrapper extends ContextWrapper {
```
其中提供了关于theme的方法，app开发中 android:theme 与此有关

相同的代码，相同的调用，使用不同的 theme 会有不同的效果

### getApplicationContext() 和 getBaseContext()

```java
public class ContextWrapper extends Context {
    Context mBase;
    ......
    @Override
    public Context getApplicationContext() {
        return mBase.getApplicationContext();
    }
    ......
    /**
     * @return the base context as set by the constructor or setBaseContext
     */
    public Context getBaseContext() {
        return mBase;// Don't use getBaseContext(), just use the Context you have.
    }
    ......
}
```

```log
getApplicationContext() = android.app.Application@39d42b0e
getBaseContext() = android.app.ContextImpl@1f48c92f
```
getApplicationContext() 从application取得context（上下文）

getBaseContext() 从实现类ContextImpl那得来；

返回由构造函数指定或setBaseContext()设置的上下文

平时使用getApplicationContext()即可  
为何要开放 getBaseContext() 这个 API？

参考blog：   
[http://blog.csdn.net/yanbober/article/details/45967639]

[http://blog.csdn.net/guolin_blog/article/details/47028975]

## 应用
### App 实现全局获取Context的机制
新建一个MyApplication类，继承自Application
```java
import android.app.Application;
import android.content.Context;

public class MyApplication extends Application {
    private static Context context;

    public static Context getMyContext() {
        return context;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        context = getApplicationContext();
    }
}
```
在Manifest中使用MyApplication；
```xml
    <application
        android:name="com.rust.aboutview.MyApplication"
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:supportsRtl="true"
        android:theme="@style/AppTheme">
    ......
```
即可在不同的地方调用 getMyContext() 方法
```java
MyApplication.getMyContext()
```
