---
title: Android Button selector 自定义背景
date: 2016-09-04 21:26:14
category: Android_note
tag: [Android_UI]
---

在xml中给ImageButton自定义背景图片。在代码中动态改变按钮的状态。
```java
mImageBtn.setEnabled(false);
```
设置完后，按钮背景图会变成自定义中的样子。

例如： `\app\src\main\res\drawable\switch_btn_bg.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<selector xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@drawable/ic_switch_dark" android:state_enabled="false" android:state_pressed="true" />
    <item android:drawable="@drawable/ic_switch_dark" android:state_enabled="false" android:state_pressed="false" />
    <item android:drawable="@drawable/ic_switch_light" android:state_enabled="true" android:state_pressed="false" />
    <item android:drawable="@drawable/ic_switch_dark" android:state_enabled="true" android:state_pressed="true" />
</selector>
```
直接在xml中给按钮设置背景
```xml
android:background="@drawable/switch_btn_bg"
```

设置背景时，一定要列举出所有的情况。
否则可能出现改变Enabled状态时，背景图片不更换的情况。
