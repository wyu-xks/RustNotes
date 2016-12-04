---
title: Android ProgressDialog 使用
date: 2017-01-12 19:00:00
category: Android_note
tag: [Android_UI]
---

记录ProgressDialog的使用方式，为统一样式而创建的`DialogFactory`

进度条能让用户了解当前任务的进度，可以提高用户体验

### 使用ProgressDialog

使用ProgressDialog需要当前Activity的实例。因此在Activity销毁前，最好主动销毁这个dialog

例如`DemoActivity.java`创建一个有文字消息的水平进度条
```java
ProgressDialog dialog = new ProgressDialog(activity);
dialog.setIndeterminate(false);// 可以设置进度  setProgress(int)
dialog.setCancelable(false);
dialog.setMessage("正在处理...");
dialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
dialog.setProgressNumberFormat("%d/%d");// 必不可少的样式
```

显示进度条前需要设置最大值
```java
dialog.setMax(999);
dialog.show();
```

改变进度值
```java
dialog.setProgress(3);
```

取消dialog的两种方法

- dismiss()
取消这个dialog，将其从屏幕上移除。可以从任意线程调用这个方法。此方法不应该被复写。可以
复写onStop方法。

- cancel()
取消这个dialog，将其从屏幕上移除。本质上和`dismiss()`相同，但是会调用已注册的
`DialogInterface.OnCancelListener`

### 创建并使用 DialogStore
如果同样的ProgressDialog在不同的界面调用，为了方便管理样式，简化代码，可以创建一个管理类。

```java
/**
 * 统一管理进度条样式
 */
public final class DialogStore {

    public static ProgressDialog newUploadDialog(Activity activity) {
        ProgressDialog dialog = new ProgressDialog(activity);
        dialog.setIndeterminate(false);
        dialog.setCancelable(true);
        dialog.setMessage("正在上传");
        dialog.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
        dialog.setProgressNumberFormat("%d/%d");
        return dialog;
    }
    // 添加更多类型的进度条...    
}
```

在Activity中调用
```java
mDialog = DialogStore.newUploadDialog(this);
```
