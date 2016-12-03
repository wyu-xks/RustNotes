---
title: Change Android toolbar overflow menu icon color and menu icon text color
date: 2016-05-24 21:09:13
category: Android_note
tag: [Android_UI]
---

首先设置使用了Toolbar的layout文件
```xml
    <android.support.v7.widget.Toolbar xmlns:app="http://schemas.android.com/apk/res-auto"
        android:id="@+id/toolbar"
        android:layout_width="match_parent"
        android:layout_height="?attr/actionBarSize"
        android:background="?attr/colorPrimary"
        android:theme="@style/AppTheme.Toolbar"
        app:popupTheme="@style/ThemeOverlay.AppCompat.Light" />
```
修改`styles.xml`文件
```xml
    <!-- Toolbar theme. -->
    <style name="AppTheme.Toolbar" parent="AppTheme">
        <item name="windowNoTitle">true</item>
        <item name="actionMenuTextColor">@color/white</item>
        <item name="android:textColorSecondary">@android:color/white</item>
    </style>
```
这里actionMenuTextColor是显示在Toolbar上menu icon字体颜色
android:textColorSecondary 是溢出菜单按键的颜色
