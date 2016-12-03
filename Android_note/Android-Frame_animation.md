---
title: Android 自定义动画
date: 2015-10-06 15:09:41
category: Android_note
tag: [Android_UI]
---
Android L ； Android Studio

[TOC]

## 帧动画
和gif图片类似，顺序播放准本好的图片文件；图片资源在xml文件中配置好  
将图片按照预定的顺序一张张切换，即成动画

### Android 帧动画 demo1
可以把动画放进子线程中启动，也可以在主线程直接启动动画  
主线程更容易控制动画的启停；  
子线程需要关注线程的状态，不好控制动画

主线程的UI不能放进子线程去设置；即子线程不能直接修改主UI；
屏幕旋转后，activity重启；动画也就停止了；  
在 AndroidManifest.xml 设置 configChanges 即可
```xml
<activity
    android:name=".MainActivity"
    android:configChanges="orientation|keyboardHidden|screenSize"
    android:label="@string/app_name"
    android:theme="@style/AppTheme.NoActionBar" >
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />

        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
</activity>
```
#### 动画资源
图片资源来自Android L Launcher3 res  
图片全部放在 res/drawable 里面  

配置文件 transition_stack.xml   
`oneshot="false"` 动画会一直循环播放下去
```xml
<animation-list
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/transition_stack" android:oneshot="false">
    <item android:drawable="@drawable/stack_00000" android:duration="30" />
    <item android:drawable="@drawable/stack_00001" android:duration="30" />
......
</animation-list>
```
#### Java代码
* 1.取得ImageView
* 2.为ImageView设置背景资源文件
* 3.把ImageView的背景赋给动画AnimationDrawable
```java
public class MainActivity extends AppCompatActivity {
    private ImageView mTransitionIcon;
    private ImageView mStackIcon;
    private AnimationDrawable frameAnimation;
    private AnimationDrawable stackAnimation;
    private Thread stackThread;
    private Button stopButton;
    public boolean action = false;

    private TextView tvState;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        tvState = (TextView) findViewById(R.id.tv_state);

        stopButton = (Button) findViewById(R.id.btn_stop);
        Button btn1 = (Button) findViewById(R.id.btn1);
        Button btn2 = (Button) findViewById(R.id.btn2);

        /*************************************************
         * AnimationDrawable extends DrawableContainer
         *************************************************/
         // 1.取得ImageView
        mTransitionIcon = (ImageView) findViewById(R.id.settings_transition_image);
        // 2.为ImageView设置背景资源文件
        mTransitionIcon.setBackgroundResource(R.drawable.transition_none);
        // 3.把ImageView的背景赋给动画AnimationDrawable
        frameAnimation = (AnimationDrawable) mTransitionIcon.getBackground();

        mStackIcon = (ImageView) findViewById(R.id.transition_stack);
        mStackIcon.setBackgroundResource(R.drawable.transition_stack);
        stackAnimation = (AnimationDrawable) mStackIcon.getBackground();
        stackThread = new Thread() {
            @Override
            public void run() {
                stackAnimation.start();// 子线程中开始动画
            }
        };

        btn1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                action = !action;// 主线程中控制动画启动与停止
                if (action) {
                    frameAnimation.start(); // 启动（重启）动画
                } else {
                    frameAnimation.stop(); // 停止动画
                }
            }
        });

        btn2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (stackThread.getState() == (Thread.State.NEW))
                    stackThread.start();// 放到子线程中开启动画
            }// 先查询子线程状态再启动，避免Thread报错导致app退出
        });

        stopButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String s = "";// 用于显示状态
                s = action ? "action! " + stackThread.getState().toString() :
                        "stop!" + stackThread.getState().toString();
                tvState.setText(s);
            }
        });
    }
}
```
### Android 帧动画 demo2
和 demo1 使用同样的动画资源，新建一个activity
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical">

    <Button
        android:id="@+id/btn_none_effect"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="start"/>

    <!-- 配置文件和ImageView绑定，使用src-->
    <ImageView
        android:id="@+id/none_effect_animation"
        android:src="@drawable/transition_none"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content" />

</LinearLayout>
```
启动帧动画的方法如下：
找到配置了动画资源的ImageView，用ImageView的getDrawable()得到AnimationDrawable
调用AnimationDrawable的start()方法即可
这里使用button来启动动画
```java
        final ImageView syncNoneEffect = (ImageView) findViewById(R.id.none_effect_animation);
        final AnimationDrawable noneAnimation = (AnimationDrawable) syncNoneEffect.getDrawable();

        findViewById(R.id.btn_none_effect).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                syncNoneEffect.post(new Runnable() {
                    @Override
                    public void run() {
                        noneAnimation.start();
                    }
                });
            }
        });

```

**注意**
AnimationDrawable 的 start() 方法不能在Activity的onCreate()方法中调用
这是因为此时图像资源尚未完全加载。

如果在Activity的onCreate()方法中调用start()，可以看到动画播放出错的情况。这里是先
倒放一些帧，然后正常。

## 附录
#### Thread 类
状态一览：
```java
    /**
     * A representation of a thread's state. A given thread may only be in one
     * state at a time.
     */
    public enum State {
        /**
         * The thread has been created, but has never been started.
         */
        NEW,
        /**
         * The thread may be run.
         */
        RUNNABLE,
        /**
         * The thread is blocked and waiting for a lock.
         */
        BLOCKED,
        /**
         * The thread is waiting.
         */
        WAITING,
        /**
         * The thread is waiting for a specified amount of time.
         */
        TIMED_WAITING,
        /**
         * The thread has been terminated.
         */
        TERMINATED
    }
```
一个Button用于启动子线程，可以先判断子线程的状态，再决定是否启动
