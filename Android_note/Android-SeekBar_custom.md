---
title: Android SeekBar 自定义
date: 2016-09-08 22:26:14
category: Android_note
tag: [Android_UI]
toc: true
---

有时会遇到自定义拖动条的需求，这里用SeekBar来自定义拖动条。

### 自定义seekbar例子1
自定义一个SeekBar；可设置高度和颜色

![SeekBar1](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Android_note/pics/seek_bar_green.png)

layout中使用SeekBar，加载自定义的drawable
```xml
<SeekBar
    android:id="@+id/seek_bar_1"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:layout_marginTop="10dp"
    android:maxHeight="7dp"
    android:minHeight="7dp"
    android:progressDrawable="@drawable/seek_bar_progress_drawable_1"
    android:thumb="@drawable/thumb_1" />
```
`android:maxHeight="7dp"` 和 `android:minHeight="7dp"` 定死了进度条的高度

自定义进度条，有渐变色效果  
`drawable\seek_bar_progress_drawable_1.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@android:id/background">
        <shape>
            <gradient
                android:angle="180"
                android:endColor="#0000000f"
                android:startColor="#7a95a4" />
            <size
                android:width="5dp"
                android:height="3dp" />
            <corners android:radius="7dp" />
        </shape>
    </item>
    <item android:id="@android:id/progress">
        <clip>
            <shape>
                <gradient
                    android:angle="0"
                    android:centerColor="#04d5ff"
                    android:endColor="#178cd7"
                    android:startColor="#9effe5" />
                <corners android:radius="7dp" />
            </shape>
        </clip>
    </item>
</layer-list>
```

自定义一个thumb `drawable\thumb_1.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#5fffff" />
    <stroke
        android:width="2dp"
        android:color="#c5fbfe" />
    <size
        android:width="16dp"
        android:height="16dp" />
</shape>
```
而SeekBar上的那个thumb大小，由xml中的size决定

如果使用的是图片，则由图片实际大小决定

### 自定义seekbar例子2
滑块`thumb_1.xml`，指定了滑块的大小和颜色；这里是个圆形滑块
```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="oval">
    <solid android:color="#ffffff" />
    <stroke
        android:width="2dp"
        android:color="#efefef" />
    <size
        android:width="50dp"
        android:height="50dp" />
</shape>
```
seekbar滑动条背景`seek_bar_progress_drawable_1.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:id="@android:id/background">
        <shape>
            <gradient
                android:angle="180"
                android:endColor="#ffc100"
                android:startColor="#ffc100" />
            <size android:height="40dp" />
            <corners android:radius="20dp" />
        </shape>
    </item>
    <item android:id="@android:id/progress">
        <clip>
            <shape>
                <gradient
                    android:angle="0"
                    android:centerColor="#b4ff00"
                    android:endColor="#60ff00"
                    android:startColor="#ffc100" />
                <corners android:radius="20dp" />
            </shape>
        </clip>
    </item>
</layer-list>
```
`background`背景中，`<size>`的width其实可以不用指定。设定height是radius的2倍，可以得到半圆的效果。
`<gradient>`中指定颜色渐变。

layout中的seekbar
```xml
    <SeekBar
        android:id="@+id/seek_bar"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_centerInParent="true"
        android:layout_marginEnd="12dp"
        android:layout_marginStart="12dp"
        android:maxHeight="35dp"
        android:paddingEnd="12dp"
        android:paddingStart="12dp"
        android:progressDrawable="@drawable/seek_bar_progress_drawable_1"
        android:thumb="@drawable/thumb_1" />
```
`maxHeight`指定了seekbar条的高度，不影响thumb的大小。使用前面自定义的滑块和背景drawable。

效果图  
![seekbar1](https://raw.githubusercontent.com/RustFisher/Rustnotes/master/Android_note/pics/seek_bar_custom1.png)

拖动效果图  
![seekbar_drag](https://raw.githubusercontent.com/RustFisher/Rustnotes/master/Android_note/pics/seek_bar_custom1_drag1.png)

### 禁止SeekBar点击设置progress，只允许拖动，可自动重置
在`OnSeekBarChangeListener`对progress进行设定。如果progress改变值过大，则重置回上一个值。  
设置标志位`mAutoResetSeekBar`，如果是自动重置，则不受上面progress的限制。  

Java代码
```java
private static final int SEEK_BAR_CLICK_PROGRESS_OFFSET = 10;
private static final int AUTO_RESET_SEEK_BAR_TIME = 1000; // 手指离开SeekBar后自动重置的时间间隔
SeekBar mSeekBar;
private int mSeekBarOldProgress = 0;
private Handler mHandler; // main handler
private boolean mAutoResetSeekBar = false;

    mSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
                @Override
                public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                    if (!mAutoResetSeekBar &&
                            (progress > mSeekBarOldProgress + SEEK_BAR_CLICK_PROGRESS_OFFSET ||
                                    progress < mSeekBarOldProgress - SEEK_BAR_CLICK_PROGRESS_OFFSET)) {
                        seekBar.setProgress(mSeekBarOldProgress);
                        return;
                    }
                    seekBar.setProgress(progress);
                    mSeekBarOldProgress = progress;
                }

                @Override
                public void onStartTrackingTouch(SeekBar seekBar) {
                    seekBar.setProgress(mSeekBarOldProgress);
                    mHandler.removeCallbacks(mResetSeekBarRunnable);
                }

                @Override
                public void onStopTrackingTouch(SeekBar seekBar) {
                    if (seekBar.getProgress() == seekBar.getMax()) {
                        // 业务代码....
                    } else {
                        mHandler.postDelayed(mResetSeekBarRunnable, AUTO_RESET_SEEK_BAR_TIME);
                    }
                }
            });

    private Runnable mResetSeekBarRunnable = new Runnable() {
        @Override
        public void run() {
            mAutoResetSeekBar = true;
            mSeekBar.setProgress(0); // 回到最小值，不一定是0
            mAutoResetSeekBar = false;
        }
    };
```

### 参考
* [Android 坑爹大全 —— SeekBar](http://light3moon.com/2015/01/26/Android%20%E5%9D%91%E7%88%B9%E5%A4%A7%E5%85%A8%20%E2%80%94%E2%80%94%20SeekBar/)
* [自定义SeekBar只能滑动，禁止点击响应 - CSDN](http://blog.csdn.net/tingfengzheshuo/article/details/44858187)
