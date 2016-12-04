---
title: Android 横屏时 Activity 跳转显示问题
date: 2016-12-15 22:01:40
category: Android_note
tag: [Android_debug]
---

主要出现在红米Note4上面
  MIUI8.1 ， 安全补丁程序级别 2016-11-01

假设有2个activity，分别为Act1 Act2

Act1 有允许横屏，有横屏layout资源  
Act2 只允许竖屏，没有横屏资源

bug重现：

手机设置允许旋转屏幕。Act1横屏，从Act1 startActivity跳转到 Act2；此时Act2是竖屏。
然后finish掉Act2，回到Act1。发现Act1显示不正常，出现部分黑屏现象。  
跳回来时并没有重建Act1。

解决办法：

强制重建Act1

使用`startActivityForResult(intent, CODE)`跳转到Act2，并且返回时调用`recreate()`

强制重建activity

```java
@Override
protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    switch (requestCode) {
        case CODE:
            this.recreate();
            break;
    }
}
```
