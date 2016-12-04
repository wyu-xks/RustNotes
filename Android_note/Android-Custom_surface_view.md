---
title: Android - 自定义SurfaceView
date: 2016-10-28 20:47:12
category: Android_note
tag: [Android_UI]
toc: true
---

## SurfaceView 简介
SurfaceView在Android系统中，是一种特殊的视图。它拥有独立的绘图表面，即它不与宿主窗口共享同一个绘图表面。
由于拥有独立的绘图表面，因此SurfaceView的UI就可以在一个独立的线程中进行绘制，又由于不会占用主线程资源，
运用SurfaceView可以实现复杂而高效的UI，另一方面又不会导致用户输入得不到及时响应。
比较适合应用在视频播放，图片浏览，对画面要求高的游戏上面。  
SurfaceView相当于是在屏幕里面，而屏幕给它开了一个洞。给它设置背景色就能把它盖住。

使用SurfaceView的原因之一，是能够在子线程中更新图像。减轻UI线程的压力。  
所有SurfaceView和SurfaceHolder.Callback的方法都应该在UI线程里调用，一般来说就是应用程序主线程。 
渲染线程所要访问的各种变量应该作同步处理。要确保绘图线程仅在surface可用期间进行绘图。  
SurfaceView主要由SurfaceHolder来控制，holder相当于一个控制器。

### 核心要点
View：必须在UI的主线程中更新画面，用于被动更新画面。  
SurfaceView：UI线程和子线程中都可以。在一个新启动的线程中重新绘制画面，主动更新画面。 

```
java.lang.Object
   ↳    android.view.View
        ↳    android.view.SurfaceView
```

## 使用方法

创建一个类继承SurfaceView并实现`SurfaceHolder.Callback`接口。

```java
public class MySView extends SurfaceView implements SurfaceHolder.Callback {
    .........
}
```

### 获取SurfaceHolder
在构造函数中获取SurfaceHolder。并添加回调。

```java
public MySView(Context context, AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);
    holder = getHolder();
    holder.addCallback(this);
    // ......
}
```

### 复写方法

```java
@Override
public void surfaceCreated(SurfaceHolder holder) {
    Log.d(TAG, "surfaceCreated");
    drawThread = new DrawThread(holder);// 创建一个绘图线程
    drawThread.start();
}

@Override
public void surfaceChanged(SurfaceHolder holder, int format, int width, int height) {
    Log.d(TAG, "surfaceChanged");
}

@Override
public void surfaceDestroyed(SurfaceHolder holder) {
    drawThread.closeThread();// 销毁线程
    Log.d(TAG, "surfaceDestroyed");
}
```
当Activity不可见时，SurfaceView会调用`surfaceDestroyed`方法。此时就要销毁绘图线程。

### 绘图子线程
SurfaceView中绘图操作是在子线程中进行的。正常来说子线程不能操作UI。但是我们可以使用
SurfaceHolder提供的方法锁定画布，绘图完成后释放并更新画布。
下面的线程提供了停止、恢复和结束等功能。
```java
class DrawThread extends Thread {

    private SurfaceHolder mmHolder;
    private boolean mmRunning;
    private boolean mmIsPause;

    public DrawThread(SurfaceHolder holder) {
        this.mmHolder = holder;
        mmRunning = true;
    }

    @Override
    public void run() {
        while (mmRunning && !isInterrupted()) {
            if (!mmIsPause) {
                Canvas canvas = null;
                try {
                    synchronized (mmHolder) {
                        canvas = holder.lockCanvas();        // 锁定画布，获得返回的画布对象Canvas
                        canvas.drawColor(bgSurfaceViewColor);// 设置画布背景颜色
                        // 绘图操作......
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (canvas != null) {
                        mmHolder.unlockCanvasAndPost(canvas);// 释放画布，并提交改变。
                    }
                    pauseThread();
                }
            } else {
                onThreadWait();
            }
        }
    }


    public synchronized void pauseThread() {
        mmIsPause = true;
    }

    /**
     * 线程等待,不提供给外部调用
     */
    private void onThreadWait() {
        try {
            synchronized (this) {
                this.wait();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public synchronized void resumeThread() {
        mmIsPause = false;
        this.notify();
    }

    public synchronized void closeThread() {
        try {
            mmRunning = false;
            notify();
            interrupt();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

### layout中使用

切记不可在layout中设置background，颜色会直接把SurfaceView挡住。
```xml
<com.rustfisher.fisherandroidchart.MySView
    android:id="@+id/mySurfaceView"
    android:layout_width="match_parent"
    android:layout_height="230dp" />
```
