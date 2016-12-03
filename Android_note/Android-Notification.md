---
title: Android Notification 使用
date: 2015-11-05 15:10:03
category: Android_note
tag: [Android_note]
---
Android L ; Android Studio 14

## 使用过程
- **NotificationManager** - 用于提示的管理，例如发送、取消
- **NotificationCompat.Builder** - Builder模式构造notification；可参考《Effective Java》第2条
- **Notification** - 提示，能够显示在状态栏和下拉栏上；构造实例能设定flags

## NotificationDemo
本例意在记录android notification的使用方法。

界面中放置了很多个按钮，每个按钮发送的提示并不完全相同。流程都一样。  
设定一个NotificationManager，
使用NotificationCompat.Builder来建立Notification；点击按钮时NotificationManager.notify发送提示  
其中有接收广播发送notification的例子

`build.gradle`部分代码，最低API 19：
```
android {
    compileSdkVersion 23
    buildToolsVersion "23.0.1"

    defaultConfig {
        applicationId "com.rust.rustnotifydemo"
        minSdkVersion 19
        targetSdkVersion 23
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

主要代码 `MainActivity.java` ：
```java
package com.rust.rustnotifydemo;

import android.app.NotificationManager;
import android.app.Notification;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v4.app.NotificationCompat;
import android.support.v7.widget.Toolbar;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;

class notifyBroadcast extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        NotificationManager nMgr =
                (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        Intent goHome = new Intent(Intent.ACTION_MAIN);
        goHome.addCategory(Intent.CATEGORY_HOME);
        NotificationCompat.Builder builder = new NotificationCompat.Builder(context)
                .setSmallIcon(R.drawable.signal_horn_26px)
                .setContentText("点击返回桌面")
                .setContentTitle("Go home")
                .setTicker("来自广播的提示")
                .setContentIntent(PendingIntent.getActivity(context, 0, goHome, 0));
        Notification notificationBroadcast = builder.build();
        notificationBroadcast.flags |= Notification.FLAG_AUTO_CANCEL;
        nMgr.notify(002, notificationBroadcast);/* id相同；此提示与 Notification 2 只能显示一个 */
    }
}

public class MainActivity extends AppCompatActivity {
    public static final String BroadcastNotify = "com.rust.notify.broadcast";

    private EditText editContent;
    private Button sendNotification;
    private Button notifyButton1;
    private Button notifyButton2;
    private Button cleanButton;
    private Button notifyBroadcast;

    private int notificationId = 001;

    private BroadcastReceiver notifyReceiver;
    private InputMethodManager inputMgr;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        IntentFilter filter = new IntentFilter(BroadcastNotify);
        notifyReceiver = new notifyBroadcast();
        registerReceiver(notifyReceiver, filter);

        /* get the widgets */
        editContent = (EditText) findViewById(R.id.et_content);
        sendNotification = (Button) findViewById(R.id.btn_send_content);
        notifyButton1 = (Button) findViewById(R.id.btn_notify_1);
        notifyButton2 = (Button) findViewById(R.id.btn_notify_2);
        notifyBroadcast = (Button) findViewById(R.id.btn_notify_broadcast);
        cleanButton = (Button) findViewById(R.id.btn_clean_notification);

        /* 构造一个Bitmap，显示在下拉栏中 */
        final Bitmap notifyBitmapTrain = BitmapFactory
                .decodeResource(this.getResources(), R.drawable.train);

        /* 管理器-用来发送notification */
        final NotificationManager nMgr =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);

        notifyButton1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent();
                intent.setClass(getApplicationContext(), MainActivity.class);

                NotificationCompat.Builder nBuilder1 =
                        new NotificationCompat.Builder(getApplicationContext())
                                .setTicker("Notify 1 ! ")/* 状态栏显示的提示语 */
                                .setContentText("Go back to RustNotifyDemo")/* 下拉栏中的内容 */
                                .setSmallIcon(R.drawable.notification_small_icon_24)/* 状态栏图片 */
                                .setLargeIcon(notifyBitmapTrain)/* 下拉栏内容显示的图片 */
                                .setContentTitle("notifyButton1 title")/* 下拉栏显示的标题 */
                                .setContentIntent(PendingIntent
                                        .getActivity(getApplicationContext(), 0, intent,
                                                PendingIntent.FLAG_UPDATE_CURRENT));
                                        /* 直接使用PendingIntent.getActivity()；不需要实例 */
                                        /* getActivity() 是 static 方法*/
                Notification n = nBuilder1.build();/* 直接创建Notification */
                n.flags |= Notification.FLAG_AUTO_CANCEL;/* 点击后触发时间，提示自动消失 */
                nMgr.notify(notificationId, n);
            }
        });

        notifyButton2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                NotificationCompat.Builder nBuilder2 =
                        new NotificationCompat.Builder(getApplicationContext())
                                .setTicker("Notify 2 ! ")/* 状态栏显示的提示语 */
                                .setContentText("Notification 2 content")/* 下拉栏中的内容 */
                                .setSmallIcon(R.drawable.floppy_16px)/* 状态栏图片 */
                                .setLargeIcon(notifyBitmapTrain)/* 下拉栏内容显示的图片 */
                                .setContentTitle("title2");/* 下拉栏显示的标题 */
                nMgr.notify(notificationId + 1, nBuilder2.build());
                /* 两个id一样的notification不能同时显示，会被新的提示替换掉 */
            }
        });

        sendNotification.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String content = editContent.getText().toString();
                if (content.equals("")) {
                    content = "U input nothing";
                }
                NotificationCompat.Builder contentBuilder =
                        new NotificationCompat.Builder(getApplicationContext())
                                .setTicker(content)/* 状态栏显示的提示语 */
                                .setContentText("I can auto cancel")/* 下拉栏中的内容 */
                                .setSmallIcon(R.drawable.rain_32px)/* 状态栏图片 */
                                .setLargeIcon(notifyBitmapTrain)/* 下拉栏内容显示的图片 */
                                .setContentTitle("Edit title");/* 下拉栏显示的标题 */
                Notification n = contentBuilder.build();
                nMgr.notify(notificationId + 2, n);
            }
        });

        notifyBroadcast.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent(BroadcastNotify);
                sendBroadcast(i);
            }
        });

        cleanButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                nMgr.cancel(notificationId);/* 根据id，撤销notification */
            }
        });
    }

    /**
     * 点击空白处，软键盘自动消失
     */
    @Override
    public boolean onTouchEvent(MotionEvent event) {
        if (event.getAction() == MotionEvent.ACTION_DOWN) {
            if (getCurrentFocus() != null && getCurrentFocus().getWindowToken() != null) {
                inputMgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                inputMgr.hideSoftInputFromWindow(
                        getCurrentFocus().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
            }
        }
        return super.onTouchEvent(event);
    }

    @Override
    protected void onDestroy() {
        unregisterReceiver(notifyReceiver);
        super.onDestroy();
    }
}
```
MainActivity launchMode="singleInstance"；便于返回 activity

图片资源都是网络下载
