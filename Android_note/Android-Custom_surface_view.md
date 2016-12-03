---
title: Android - 自定义SurfaceView
date: 2016-10-28 20:47:12
tag: [Android_UI]
toc: true
---

使用SurfaceView的原因之一，是能够在子线程中更新图像。减轻UI线程的压力。
要确保绘图线程仅在surface可用期间进行绘图。

SurfaceView主要由SurfaceHolder来控制，holder相当于一个控制器。
SurfaceView相当于是在屏幕里面。给它设置背景色就能把它盖住。
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
