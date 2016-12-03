---
title: Android SeekBar 自定义
date: 2016-09-08 22:26:14
category: Android_note
tag: [Android_UI]
---

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
