---
title: Android 分别使用 SurfaceView 和 TextureView 来预览 Camera，获取NV21数据
date: 2018-02-26 21:52:04
category: Android_note
toc: true
---

* win7
* Android Studio 3.0.1

本文目的：使用 Camera API 进行视频的采集，分别使用 SurfaceView、TextureView 来预览 Camera 数据，取到 NV21 的数据回调

### 准备
使用相机权限
```xml
<uses-permission android:name="android.permission.CAMERA" />
```
camera预览回调中默认使用NV21格式。

检查手机是否支持摄像头。

UI准备
```xml
    <!-- 全屏显示 -->
    <style name="FullScreenTheme" parent="AppTheme">
        <item name="windowNoTitle">true</item>
        <item name="android:windowFullscreen">true</item>
    </style>
```
承载预览图像
```xml
    <FrameLayout
        android:id="@+id/camera_preview"
        android:layout_width="match_parent"
        android:layout_height="match_parent" />
```

### 使用 SurfaceView 预览 Camera，取到NV21数据
自定义`CameraPreview`继承`SurfaceView`，实现`SurfaceHolder.Callback`接口

获取NV21数据，`Camera.setPreviewCallback()` 要放在 `Camera.startPreview()` 之前。
使用`Camera.PreviewCallback`获取预览数据回调。默认是NV21格式。

`surfaceChanged`中，camera启动预览前可以进行设置，例如设置尺寸，调整方向
```java
/**
 * camera预览视图
 * Created by Rust on 2018/2/26.
 */
public class CameraPreview extends SurfaceView implements SurfaceHolder.Callback {
    private static final String TAG = "rustApp";
    private SurfaceHolder mHolder;
    private Camera mCamera;
    private int mFrameCount = 0;

    public CameraPreview(Context context) {
        super(context);
    }

    public CameraPreview(Context context, Camera camera) {
        super(context);
        mCamera = camera;
        mHolder = getHolder();
        mHolder.addCallback(this);
        mHolder.setType(SurfaceHolder.SURFACE_TYPE_PUSH_BUFFERS);
    }

    public void setCamera(Camera c) {
        this.mCamera = c;
    }

    @Override
    public void surfaceCreated(SurfaceHolder holder) {
        // 开启预览
        try {
            mCamera.setPreviewDisplay(holder);
            mCamera.startPreview();
        } catch (IOException e) {
            Log.d(TAG, "Error setting camera preview: " + e.getMessage());
        }
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder holder) {
        // 可在此释放camera
    }

    @Override
    public void surfaceChanged(SurfaceHolder holder, int format, int w, int h) {
        // 若需要旋转、更改大小或重新设置，请确保证已停止预览
        if (mHolder.getSurface() == null) {
            return;
        }
        try {
            mCamera.stopPreview();
        } catch (Exception e) {
            // ignore: tried to stop a non-existent preview
        }
        Camera.Parameters parameters = mCamera.getParameters();
        // ImageFormat.NV21 == 17
        Log.d(TAG, "parameters.getPreviewFormat(): " + parameters.getPreviewFormat());
        if (this.getResources().getConfiguration().orientation != Configuration.ORIENTATION_LANDSCAPE) {
            mCamera.setDisplayOrientation(90);
        } else {
            mCamera.setDisplayOrientation(0);
        }
        try {
            mCamera.setPreviewDisplay(mHolder);
            mCamera.setPreviewCallback(mCameraPreviewCallback); // 回调要放在 startPreview() 之前
            mCamera.startPreview();
        } catch (Exception e) {
            Log.d(TAG, "Error starting camera preview: " + e.getMessage());
        }
    }

    private Camera.PreviewCallback mCameraPreviewCallback = new Camera.PreviewCallback() {
        @Override
        public void onPreviewFrame(byte[] data, Camera camera) {
            mFrameCount++;
            Log.d(TAG, "onPreviewFrame: data.length=" + data.length + ", frameCount=" + mFrameCount);
        }
    };
}
```

为了防止阻塞UI线程，在子线程中打开camera。camera常放在try catch中使用。
```java
public class MainActivity extends AppCompatActivity {

    private static final String TAG = "rustApp";

    private Camera mCamera;
    private CameraPreview mPreview;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        new InitCameraThread().start();
    }

    @Override
    protected void onResume() {
        if (null == mCamera) {
            if (safeCameraOpen()) {
                mPreview.setCamera(mCamera); // 重新获取camera操作权
            } else {
                Log.e(TAG, "无法操作camera");
            }
        }
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        releaseCamera();
    }

    private boolean safeCameraOpen() {
        boolean qOpened = false;
        try {
            releaseCamera();
            mCamera = Camera.open();
            qOpened = (mCamera != null);
        } catch (Exception e) {
            Log.e(TAG, "failed to open Camera");
            e.printStackTrace();
        }
        return qOpened;
    }

    private void releaseCamera() {
        if (mCamera != null) {
            mCamera.setPreviewCallback(null);
            mCamera.release();        // release the camera for other applications
            mCamera = null;
        }
    }

    private class InitCameraThread extends Thread {
        @Override
        public void run() {
            super.run();
            if (safeCameraOpen()) {
                Log.d(TAG, "开启摄像头");
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mPreview = new CameraPreview(MainActivity.this, mCamera);
                        FrameLayout preview = findViewById(R.id.camera_preview);
                        preview.addView(mPreview);
                    }
                });
            }
        }
    }
}
```

### 使用 TextureView 预览 Camera，取到NV21数据
`TextureView`可用于显示内容流。内容流可以是视频或者OpenGL的场景。内容流可来自应用进程或是远程其它进程。

`Textureview`必须在硬件加速开启的窗口中使用。若是软解，`TextureView`不会显示东西。

不同于`SurfaceView`，`TextureView`不会建立一个单独的窗口，而是像一个常规的View一样（个人认为这是个优点）。
这使得`TextureView`可以被移动，转换或是添加动画。比如，可以调用`myView.setAlpha(0.5f)`将其设置成半透明。

使用`TextureView`很简单：获取到它的`SurfaceTexture`，使用`SurfaceTexture`呈现内容。

`CameraPreview`继承了`TextureView`，外部需要传入camera实例。在`onSurfaceTextureAvailable`中，配置camera，比如设置图像方向。
通过设置`Camera.PreviewCallback`来取得预览数据。
```java
import java.io.IOException;
import android.content.Context;
import android.content.res.Configuration;
import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import android.util.Log;
import android.view.TextureView;

public class CameraPreview extends TextureView implements TextureView.SurfaceTextureListener {
    private static final String TAG = "rustApp";
    private Camera mCamera;

    public CameraPreview(Context context) {
        super(context);
    }

    public CameraPreview(Context context, Camera camera) {
        super(context);
        mCamera = camera;
    }

    public void setCamera(Camera camera) {
        this.mCamera = camera;
    }

    @Override
    public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
        Log.d(TAG, "TextureView onSurfaceTextureAvailable");
        if (this.getResources().getConfiguration().orientation != Configuration.ORIENTATION_LANDSCAPE) {
            mCamera.setDisplayOrientation(90);
        } else {
            mCamera.setDisplayOrientation(0);
        }
        try {
            mCamera.setPreviewCallback(mCameraPreviewCallback);
            mCamera.setPreviewTexture(surface); // 使用SurfaceTexture
            mCamera.startPreview();
        } catch (IOException ioe) {
            // Something bad happened
        }
    }

    @Override
    public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
        Log.d(TAG, "TextureView onSurfaceTextureSizeChanged"); // Ignored, Camera does all the work for us
    }

    @Override
    public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
        Log.d(TAG, "TextureView onSurfaceTextureDestroyed");
        mCamera.stopPreview();
        mCamera.release();
        return true;
    }

    @Override
    public void onSurfaceTextureUpdated(SurfaceTexture surface) {
        // Invoked every time there's a new Camera preview frame
    }

    private Camera.PreviewCallback mCameraPreviewCallback = new Camera.PreviewCallback() {
        @Override
        public void onPreviewFrame(byte[] data, Camera camera) {
            Log.d(TAG, "onPreviewFrame: data.length=" + data.length);
        }
    };
}
```

操作界面`TextureAct`。获取camera操作权，初始化`CameraPreview`并添加到布局中。第一次获取camera时在子线程中操作。

在`onPause`中释放camera，`onResume`中尝试取回camera控制权。这样应用暂时退回后台时，其他应用可以操作摄像头。
```java
public class TextureAct extends AppCompatActivity {
    private static final String TAG = "rustApp";
    private Camera mCamera;
    private CameraPreview mPreview;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_texture);
        new InitCameraThread().start();
    }

    @Override
    protected void onResume() {
        if (null == mCamera) {
            if (safeCameraOpen()) {
                mPreview.setCamera(mCamera); // 重新获取camera操作权
            } else {
                Log.e(TAG, "无法操作camera");
            }
        }
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        releaseCamera();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        releaseCamera();
    }

    private boolean safeCameraOpen() {
        boolean qOpened = false;
        try {
            releaseCamera();
            mCamera = Camera.open();
            qOpened = (mCamera != null);
        } catch (Exception e) {
            Log.e(TAG, "failed to open Camera");
            e.printStackTrace();
        }
        return qOpened;
    }

    private void releaseCamera() {
        if (mCamera != null) {
            mCamera.setPreviewCallback(null);
            mCamera.release();        // release the camera for other applications
            mCamera = null;
        }
    }

    private class InitCameraThread extends Thread {
        @Override
        public void run() {
            super.run();
            if (safeCameraOpen()) {
                Log.d(TAG, "TextureAct 开启摄像头");
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mPreview = new CameraPreview(TextureAct.this, mCamera);
                        mPreview.setSurfaceTextureListener(mPreview);
                        FrameLayout preview = findViewById(R.id.camera_preview);
                        preview.addView(mPreview);
                    }
                });
            }
        }
    }
}
```
`Textureview`必须在硬件加速开启的窗口中使用。`android:hardwareAccelerated="true"` 默认的这个属性就是true，无需再设置。

每接到一帧数据，就会调用一次`onSurfaceTextureUpdated()`。通过这个接口。能够将上来的SurfaceTexture送给OpenGL再去处理。

### 参考资料
* [Controlling the Camera - Android Developer](https://developer.android.com/training/camera/cameradirect.html)
* [Camera API - Android Developer](https://developer.android.com/guide/topics/media/camera.html)
* [TextureView - Android Developer](https://developer.android.com/reference/android/view/TextureView.html)
