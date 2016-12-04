---
title: Android popupwindow 使用方法
date: 2015-10-22 15:09:20
category: Android_note
tag: [Android_UI]
toc: true
---


## 首先创建一个XML文件：
例如：popup.xml
```xml
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical" >

<Button
    android:id="@+id/button1"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:textSize="26sp"
    android:text="触发事件1"
    />
<Button
    android:id="@+id/button2"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:textSize="26sp"
    android:text="触发事件2"
    />
</LinearLayout>
```
这个是弹窗的内容。可以看到，定义了2个按钮。分别触发两个事件。

## 接着在类中新定义一个popupwindow的方法：
```java
private void showPopupWindow(View view){
		View contentView = LayoutInflater.from(mContext).inflate(R.layout.changephoto, null);
		// 设置按钮的点击事件
        Button button1 = (Button) contentView.findViewById(R.id.button1);
        button1.setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                //触发事件1

            }
        });
        Button button2 = (Button) contentView.findViewById(R.id.button2);
        button2.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				//触发事件2

			}

        });
        final PopupWindow popupWindow = new PopupWindow(contentView,
                LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, true);
        popupWindow.setTouchable(true);
        popupWindow.setBackgroundDrawable(new BitmapDrawable());
        popupWindow.setOutsideTouchable(true);  
        // 设置好参数之后再show
        popupWindow.showAsDropDown(view);   
    }
```
接下来在需要的地方直接调用showPopupWindow()。注意往里传入View。

例如某个代码片段，按钮点击：
```java
@Override
public void onClick(View v) {
    showPopupWindow(v);
}
```
