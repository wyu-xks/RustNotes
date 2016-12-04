---
title: Android UI 画布
date: 2015-12-21 20:11:37
category: Android_note
tag: [Android_UI]
toc: true
---

[TOC]

## little tricks
### 封装 findViewById
```java

private <T extends View> T fv(int resId) {
return (T) super.findViewById(resId);
}

```
用的时候就这样儿 `ibTakePicture = fv(R.id.ib_camera_take_picture);`
主要是不用写那么多findViewById了

## TextView 设定点击事件
setOnClickListener 方法是 View.java 里的  
public class Button extends TextView  
    public class TextView extends View implements ViewTreeObserver.OnPreDrawListener

Button 和 TextView 都有 setOnClickListener 方法，直接调用即可 :)
```xml
    <TextView
        android:id="@+id/tv_broadcast"
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_below="@id/tv_hello"
        android:text="wating for broadcast..." />
```
```java
        tvBroadcast = (TextView) findViewById(R.id.tv_broadcast);

        View textButton = findViewById(R.id.tv_broadcast);// 建立View，可以使用Button的方法
        textButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(getApplicationContext(), "fffff", Toast.LENGTH_SHORT).show();
                tvBroadcast.setText("u click me");
            }
        });
```

## Canvas drawText 实现中文垂直居中
使用自定义View画文字时，会需要设定文字的水平位置和竖直位置

```java
    @Override
    public void onDraw (Canvas canvas) {
        Rect targetRect = new Rect(50, 50, 1000, 200);  
        Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);  
        paint.setStrokeWidth(3);  
        paint.setTextSize(80);  
        String testString = "测试：qwert字体居中、/";  
        paint.setColor(Color.CYAN);  
        canvas.drawRect(targetRect, paint);  
        paint.setColor(Color.RED);  
        FontMetricsInt fontMetrics = paint.getFontMetricsInt();  
        int baseline = (targetRect.bottom + targetRect.top - fontMetrics.bottom
                - fontMetrics.top) / 2;
        // 下面这行是实现水平居中，drawText对应改为传入targetRect.centerX()  
        paint.setTextAlign(Paint.Align.CENTER);  
        canvas.drawText(testString, targetRect.centerX(), baseline, paint);  
    }
```
FontMetrics.top的数值是个负数，其绝对值就是字体绘制边界到baseline的距离。  
所以如果是把文字画在 FontMetrics高度的矩形中， drawText就应该传入 -FontMetrics.top。  
要画在targetRect的居中位置，baseline的计算公式就是：  
targetRect.centerY() - (FontMetrics.bottom - FontMetrics.top) / 2 - FontMetrics.top  
优化后即：
```
(targetRect.bottom + targetRect.top - fontMetrics.bottom - fontMetrics.top) / 2
```
在自定义的ScrollChooserView中有应用

## 自定义控件 - 圈圈
Android L； Android Studio
效果：能够自定义圆圈半径和位置；设定点击效果；改变背景颜色

下面是demo图
点击前: ![1](https://raw.githubusercontent.com/RustFisher/Rustnotes/master/Android_note/pics/circles_rendering1.png) 点击后: ![](https://raw.githubusercontent.com/RustFisher/Rustnotes/master/Android_note/pics/circles_rendering2.png)
自定义控件一般要继承View；写出构造方法，并设定属性；复写`onDraw`方法
并在xml中配置一下
例子：`OptionCircle.java` `CirclesActivity.java` `activity_circle_choose.xml`
这个例子没有使用`attrs.xml`
### 控件 OptionCircle
这里继承的是ImageView；设定了多个属性，有半径，圆心位置，背景颜色和字体颜色等等
针对这些属性，开放set方法；方便设置属性；可以改变这些属性来做出一些动画效果
构造方法中预设几个属性，设置画笔，背景颜色和圆圈的半径
`onDraw`方法中开始绘制控件；先画圆形，在圆形中心画上文字；文字中心定位需要特别计算一下

```java
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.widget.ImageView;

public class OptionCircle extends ImageView {

    private final Paint paint;
    private final Context context;
    boolean clicked = false;// 是否被点击
    boolean addBackground = false;
    int radius = -1;      // 半径值初始化为-1
    int centerOffsetX = 0;// 圆圈原点的偏移量x
    int centerOffsetY = 0;// 偏移量y
    int colorCircle;      // 圆圈颜色
    int colorBackground;  // 背景填充颜色
    int colorText;        // 文字颜色
    String textCircle = "";

    public OptionCircle(Context context) {
        this(context, null);
    }

    public OptionCircle(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.context = context;
        this.paint = new Paint();
        this.paint.setAntiAlias(true);
        this.paint.setStyle(Paint.Style.STROKE);
        colorCircle = Color.argb(205, 245, 2, 51);// 默认颜色
        colorText = colorCircle;      // 字体颜色默认与圈圈颜色保持一致
        colorBackground = colorCircle;// 设定默认参数
    }
    // 属性设置方法
    public void setRadius(int r) {
        this.radius = r;
    }

    public void setCenterOffset(int x, int y) {
        this.centerOffsetX = x;
        this.centerOffsetY = y;
    }

    public void setColorCircle(int c) {
        this.colorCircle = c;
    }

    public void setColorText(int c) {
        this.colorText = c;
    }

    public void setColorBackground(int c) {
        this.colorBackground = c;
    }

    public void setText(String s) {
        this.textCircle = s;
    }

    public void setClicked(boolean clicked) {
        this.clicked = clicked;
    }

    public void setAddBackground(boolean add) {
        this.addBackground = add;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        int center = getWidth() / 2;// 当前宽度的一半
        int innerCircle = 86;       // 默认半径为86
        if (radius > 0) {
            innerCircle = dip2px(context, radius); // 如果没有另外设置半径，取半径86
        }

        Drawable drawable = getDrawable();
        if (addBackground) {
        } else {
            // 画圈圈；被点击后会变成实心的圈圈，默认是空心的
            this.paint.setStyle(clicked ? Paint.Style.FILL : Paint.Style.STROKE);
            this.paint.setColor(clicked ? colorBackground : colorCircle);
            this.paint.setStrokeWidth(1.5f);
            canvas.drawCircle(center + centerOffsetX, center + centerOffsetY,
                    innerCircle, this.paint);// 画圆圈时带上偏移量
        }

        // 绘制文字
        this.paint.setStyle(Paint.Style.FILL);
        this.paint.setStrokeWidth(1);
        this.paint.setTextSize(22);
        this.paint.setTypeface(Typeface.MONOSPACE);// 设置一系列文字属性
        this.paint.setColor(clicked ? Color.WHITE : colorText);
        this.paint.setTextAlign(Paint.Align.CENTER);// 文字水平居中
        Paint.FontMetricsInt fontMetrics = paint.getFontMetricsInt();
        canvas.drawText(textCircle, center + centerOffsetX,
                center + centerOffsetY - (fontMetrics.top + fontMetrics.bottom) / 2, this.paint);// 设置文字竖直方向居中
        super.onDraw(canvas);
    }

    /**
     * convert dp to px
     */
    public static int dip2px(Context context, float dpValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }
}
```
### 配置 activity_circle_choose.xml
控件文件定义完毕，在`activity_circle_choose.xml`中配置一下
定义4个圈圈；center_circle定位在中心；circle_0是红色的；circle_1是绿色的；circle_2是洋红色的
```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <TextView
        android:id="@+id/top_title"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:layout_centerHorizontal="true"
        android:layout_marginTop="5dp"
        android:text="@string/circles_top_title"
        android:textSize="26sp" />

    <com.rust.aboutview.view.OptionCircle
        android:id="@+id/center_circle"
        android:layout_width="140dp"
        android:layout_height="140dp"
        android:layout_centerHorizontal="true"
        android:layout_centerVertical="true" />

    <com.rust.aboutview.view.OptionCircle
        android:id="@+id/circle_0"
        android:layout_width="200dp"
        android:layout_height="200dp"
        android:layout_marginStart="130dp"
        android:layout_marginTop="53dp" />

    <com.rust.aboutview.view.OptionCircle
        android:id="@+id/circle_1"
        android:layout_width="210dp"
        android:layout_height="210dp"
        android:layout_below="@+id/circle_0"
        android:layout_toEndOf="@+id/center_circle" />

    <com.rust.aboutview.view.OptionCircle
        android:id="@+id/circle_2"
        android:layout_width="210dp"
        android:layout_height="210dp"
        android:layout_below="@id/center_circle" />

</RelativeLayout>
```
### 在 CirclesActivity.java 中使用圈圈
圈圈类`OptionCircle.java`已经开放了设置属性的方法，我们可以利用这些方法来调整圈圈的样式，比如半径，颜色，圆心偏移量
center_circle固定在屏幕中间不动
circle_0仿造一个放大缩小的效果，改变半径值即可实现
circle_1仿造一个浮动的效果，改变圆心偏移量来实现
circle_2仿造抖动效果，也是改变圆心偏移量
这些圈圈都可以自定义背景颜色
```java
import android.app.Activity;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.View;

import com.rust.aboutview.view.OptionCircle;

public class CirclesActivity extends Activity {

    public static final String TAG = "CirclesActivity";
    public static final int circle0_r = 88;

    private static final int SLEEPING_PERIOD = 100; // 刷新UI间隔时间
    private static final int UPDATE_ALL_CIRCLE = 99;
    int circleCenter_r;
    int circle1_r;
    boolean circle0Clicked = false;
    boolean circle1Clicked = false;

    OptionCircle centerCircle;
    OptionCircle circle0;
    OptionCircle circle1;
    OptionCircle circle2;

    CircleHandler handler = new CircleHandler(this);

    /**
     * Handler : 用于更新UI
     */
    static class CircleHandler extends Handler {
        CirclesActivity activity;
        boolean zoomDir = true;
        boolean circle2Shaking = false;
        int r = circle0_r;
        int moveDir = 0;  // 浮动方向
        int circle1_x = 0;// 偏移量的值
        int circle1_y = 0;
        int circle2_x = 0;
        int circle2ShakeTime = 0;
        int circle2Offsets[] = {10, 15, -6, 12, 0};// 抖动偏移量坐标

        CircleHandler(CirclesActivity a) {
            activity = a;
        }

        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case UPDATE_ALL_CIRCLE: {
                    if (zoomDir) {// 用简单的办法实现半径变化
                        r++;
                        if (r >= 99) zoomDir = false;
                    } else {
                        r--;
                        if (r <= circle0_r) zoomDir = true;
                    }
                    activity.circle0.invalidate();
                    activity.circle0.setRadius(r);
                    calOffsetX();// 计算圆心偏移量
                    activity.circle1.invalidate();
                    activity.circle1.setCenterOffset(circle1_x, circle1_y);

                    if (circle2Shaking) {
                        if (circle2ShakeTime < circle2Offsets.length - 1) {
                            circle2ShakeTime++;
                        } else {
                            circle2Shaking = false;
                            circle2ShakeTime = 0;
                        }
                        activity.circle2.invalidate();
                        activity.circle2.setCenterOffset(circle2Offsets[circle2ShakeTime], 0);
                    }
                }
            }
        }
        // 计算circle1圆心偏移量；共有4个浮动方向
        private void calOffsetX() {
            if (moveDir == 0) {
                circle1_x--;
                circle1_y++;
                if (circle1_x <= -6) moveDir = 1;
            }
            if (moveDir == 1) {
                circle1_x++;
                circle1_y++;
                if (circle1_x >= 0) moveDir = 2;
            }
            if (moveDir == 2) {
                circle1_x++;
                circle1_y--;
                if (circle1_x >= 6) moveDir = 3;
            }
            if (moveDir == 3) {
                circle1_x--;
                circle1_y--;
                if (circle1_x <= 0) moveDir = 0;
            }
        }
    }

    class UpdateCircles implements Runnable {

        @Override
        public void run() {
            while (true) {// 配合Handler，循环刷新UI
                Message message = new Message();
                message.what = UPDATE_ALL_CIRCLE;
                handler.sendEmptyMessage(message.what);
                try {
                    Thread.sleep(SLEEPING_PERIOD); // 暂停
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_circle_choose);
        centerCircle = (OptionCircle) findViewById(R.id.center_circle);
        circle0 = (OptionCircle) findViewById(R.id.circle_0);
        circle1 = (OptionCircle) findViewById(R.id.circle_1);
        circle2 = (OptionCircle) findViewById(R.id.circle_2);

        circleCenter_r = 38;
        circle1_r = 45;
        // 设置圈圈的属性
        centerCircle.setRadius(circleCenter_r);
        centerCircle.setColorText(Color.BLUE);
        centerCircle.setColorCircle(Color.BLUE);
        centerCircle.setText("点击圈圈");

        circle0.setColorText(Color.RED);
        circle0.setRadius(circle0_r);
        circle0.setText("RED");

        circle1.setColorCircle(Color.GREEN);
        circle1.setColorText(Color.GREEN);
        circle1.setText("Green");
        circle1.setRadius(circle1_r);

        circle2.setColorCircle(getResources().getColor(R.color.colorMagenta));
        circle2.setColorText(getResources().getColor(R.color.colorMagenta));
        circle2.setText("Frozen!");

        // 设定点击事件，可在这里改变控件的属性
        circle0.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                circle0Clicked = !circle0Clicked;  // 每次点击都取反
                circle0.setClicked(circle0Clicked);
            }
        });

        circle1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                circle1Clicked = !circle1Clicked;
                circle1.setColorBackground(Color.GREEN);
                circle1.setClicked(circle1Clicked);
            }
        });

        circle2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                handler.circle2Shaking = true;// 颤抖吧！
            }
        });

        Thread t = new Thread(new UpdateCircles());
        t.start();// 开启子线程
    }
}

```
至此，圈圈demo结束。通过简单的计算，模拟出浮动，抖动，缩放的效果
以上的代码，复制粘贴进工程里就能使用。圆心移动的轨迹，用三角函数来计算会更好
这里继承的是ImageView，应该有办法在圈内动态添加背景Bitmap，效果更好看
