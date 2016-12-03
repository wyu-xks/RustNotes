---
title: Android show menu icon problem 选项摆放问题
date: 2016-05-24 21:39:13
category: Android_note
tag: [Android_UI]
---

使用menu时，遇到如下警告：
> Should use app:showAsAction with the appcompat library with xmlns:app="http://schemas.android.com/apk/res-auto" less... (Ctrl+F1)
 When using the appcompat library, menu resources should refer to the showAsAction in the app: namespace, not the android: namespace.  Similarly, when not using the appcompat library, you should be using the android:showAsAction attribute.

原来的menu文件使用的是：
```xml
<menu xmlns:android="http://schemas.android.com/apk/res/android">
    <item
        android:id="@+id/start_training"
        android:orderInCategory="103"
        android:title="@string/start_training"
        android:showAsAction="ifRoom|withText" />
```
按照提示改为：
```xml
<menu xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto">
    <item
        android:id="@+id/start_training"
        android:orderInCategory="103"
        android:title="@string/start_training"
        app:showAsAction="ifRoom|withText" />
```
修改后，如果activity的标题栏上面有足够的空间，菜单的按键就会被显示在标题栏上。
