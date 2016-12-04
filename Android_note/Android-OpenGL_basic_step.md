---
title: Android OpenGL 基本环境，绘制简易图形
date: 2018-01-26 20:32:14
category: Android_note
toc: true
---

* win7
* Android Studio 3.0.1

本文目的，记录Android端OpenGL开发的基本流程。记录一些常见的代码。

### Android 使用 OpenGL 进行绘制
Andoird框架提供了大量的标准工具，用于创建丰富的，吸引人的图形界面。若是想要对屏幕上的内容进行更深度地UI，或是绘制3D图像，则需要另外的工具。
Android中提供的OpenGL ES API。可以利用设备上的GPU进行图形加速。许多设备已支持GPU。

#### 基本环境要求
在AndroidManifest中声明使用OpenGL 2.0
```xml
    <uses-feature android:glEsVersion="0x00020000" android:required="true" />
```

要绘制界面，需要“画布”和“画笔”。“画布”由`GLSurfaceView`实现，“画笔”在这里是渲染器`GLSurfaceView.Renderer`

创建渲染器类`MyGLRenderer`
```java
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;

import javax.microedition.khronos.opengles.GL10;

public class MyGLRenderer implements GLSurfaceView.Renderer {
    @Override
    public void onDrawFrame(GL10 unused) {
        // Redraw background color
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);
    }

    @Override
    public void onSurfaceCreated(GL10 gl, javax.microedition.khronos.egl.EGLConfig config) {
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    }

    @Override
    public void onSurfaceChanged(GL10 unused, int width, int height) {
        GLES20.glViewport(0, 0, width, height);
    }
}
```

创建“画布”类`MyGLSurfaceView`，其中使用了前面定义的渲染器
```java
import android.content.Context;
import android.opengl.GLSurfaceView;

public class MyGLSurfaceView extends GLSurfaceView {

    private final MyGLRenderer mRenderer;

    public MyGLSurfaceView(Context context) {
        super(context);
        // Create an OpenGL ES 2.0 context
        setEGLContextClientVersion(2);

        mRenderer = new MyGLRenderer();

        // Set the Renderer for drawing on the GLSurfaceView
        setRenderer(mRenderer);
    }
}
```

将“画布”显示出来。例如添加到Activity的视图中
```java
import android.opengl.GLSurfaceView;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.FrameLayout;

public class MainActivity extends AppCompatActivity {
    private GLSurfaceView mGLView; // “画布”

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mGLView = new MyGLSurfaceView(this);
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(300,300); // 加入现有视图中
        addContentView(mGLView, layoutParams);
    }
}
```
至此，会得到一个“黑色的”的画布。

#### 画一个三角形
OpenGL ES允许使用3D坐标来绘制。绘制之前，先定义三角形的坐标。
在OpenGL中，常用方法是使用定义顶点坐标的数组。为了效率，把这些坐标写入ByteBuffer，然后传给OpenGL ES图形管道进行处理。

[Shaders 可被看做是一系列的指令，但是这些指令会对屏幕上的每个像素同时下达。](https://thebookofshaders.com/01/?lan=ch)

默认情况下，OpenGL ES假设[0,0,0] (X,Y,Z)是GLSurfaceView的中心点。[1,1,0]是右上角顶点，[-1,-1,0]是左下角顶点。

形状的顶点值是按逆时针（counterclockwise）排列的。

##### 定义三角形类
我们会用到`ShaderCode`来定义图形。

修改`MyGLRenderer`，持有`Triangle`对象实例

首先定义顶点着色器和片段着色器。确定三角形的坐标和颜色信息。    
初始化`Triangle`：
* 初始化顶点ByteBuffer
    * 确定字节顺序
    * 从ByteBuffer中创建FloatBuffer
    * 将预置的坐标值填入FloatBuffer
    * 设置从第一个坐标开始
* 加载顶点和片段着色器
* 创建空的OpenGL ES Program，标记为`mProgram`
* ES Program加入顶点着色器
* ES Program加入片段着色器fragmentShader
* 创建可执行的OpenGL ES程序

```java
import android.opengl.GLES20;
import com.rust.glone.MyGLRenderer;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;

/**
 * OpenGL 三角形图形类
 */
public class Triangle {

    private FloatBuffer vertexBuffer;

    private static final String vertexShaderCode =
            "attribute vec4 vPosition;" +
                    "void main() {" +
                    "  gl_Position = vPosition;" +
                    "}";

    // 所有的浮点值都是中等精度 （precision mediump float;）
    // 也可以选择把这个值设为“低”（precision lowp float;）或者“高”（precision highp float;）
    private static final String fragmentShaderCode =
            "precision mediump float;" +
                    "uniform vec4 vColor;" +
                    "void main() {" +
                    "  gl_FragColor = vColor;" +
                    "}";

    private static final int COORDS_PER_VERTEX = 3; // 每个点由3个数值定义
    private static float triangleCoords[] = {       // 逆时针顺序
            0.0f, 0.622008459f, 0.0f,   // top
            -0.5f, -0.311004243f, 0.0f, // bottom left
            0.5f, -0.311004243f, 0.0f   // bottom right
    };

    // 设置red, green, blue and alpha 颜色值
    private float color[] = {0.63671875f, 0.76953125f, 0.22265625f, 1.0f};

    private final int mProgram;

    public Triangle() {
        // 初始化顶点ByteBuffer
        ByteBuffer bb = ByteBuffer.allocateDirect(
                triangleCoords.length * 4); // 1个float占4个byte
        bb.order(ByteOrder.nativeOrder());  // 使用硬件指定的字节顺序 一般而言是ByteOrder.LITTLE_ENDIAN

        vertexBuffer = bb.asFloatBuffer();  // 从ByteBuffer中创建FloatBuffer
        vertexBuffer.put(triangleCoords);   // 将预置的坐标值填入FloatBuffer
        vertexBuffer.position(0);           // 设置从第一个坐标开始

        int vertexShader = MyGLRenderer.loadShader(GLES20.GL_VERTEX_SHADER,
                vertexShaderCode);
        int fragmentShader = MyGLRenderer.loadShader(GLES20.GL_FRAGMENT_SHADER,
                fragmentShaderCode);

        mProgram = GLES20.glCreateProgram();// 创建空的OpenGL ES Program

        GLES20.glAttachShader(mProgram, vertexShader);  // ES Program加入顶点着色器
        GLES20.glAttachShader(mProgram, fragmentShader);// ES Program加入片段着色器fragmentShader
        GLES20.glLinkProgram(mProgram);                 // 创建可执行的OpenGL ES程序
    }

    private int mPositionHandle;
    private int mColorHandle;

    private static final int vertexCount = triangleCoords.length / COORDS_PER_VERTEX;
    private static final int vertexStride = COORDS_PER_VERTEX * 4; // 每个顶点4字节

    public void draw() {
        GLES20.glUseProgram(mProgram); // 将程序添入OpenGL ES环境中

        // 获取顶点着色器的vPosition成员位置
        mPositionHandle = GLES20.glGetAttribLocation(mProgram, "vPosition");
        GLES20.glEnableVertexAttribArray(mPositionHandle); // 激活这个三角形顶点的handle

        // 准备这个三角形的坐标数据
        GLES20.glVertexAttribPointer(mPositionHandle, COORDS_PER_VERTEX,
                GLES20.GL_FLOAT, false,
                vertexStride, vertexBuffer);

        // 获取片段着色器的颜色成员信息
        mColorHandle = GLES20.glGetUniformLocation(mProgram, "vColor");
        GLES20.glUniform4fv(mColorHandle, 1, color, 0);   // 设置三角形的颜色
        GLES20.glDrawArrays(GLES20.GL_TRIANGLES, 0, vertexCount); // 绘制三角形
        GLES20.glDisableVertexAttribArray(mPositionHandle); // Disable vertex array
    }
}
```
##### Renderer绘制三角形
`MyGLRenderer`持有并初始化`Triangle`对象

在`onDrawFrame`中直接调用`draw()`方法
```java
public class MyGLRenderer implements GLSurfaceView.Renderer {
    private Triangle mTriangle;

    /**
     * @param type       GLES20.GL_VERTEX_SHADER or GLES20.GL_FRAGMENT_SHADER
     * @param shaderCode shader code string
     * @return GLES20.glCreateShader(type)
     */
    public static int loadShader(int type, String shaderCode) {
        // create a vertex shader type (GLES20.GL_VERTEX_SHADER)
        // or a fragment shader type (GLES20.GL_FRAGMENT_SHADER)
        int shader = GLES20.glCreateShader(type);

        // add the source code to the shader and compile it
        GLES20.glShaderSource(shader, shaderCode);
        GLES20.glCompileShader(shader);

        return shader;
    }

    @Override
    public void onSurfaceCreated(GL10 gl, javax.microedition.khronos.egl.EGLConfig config) {
        mTriangle = new Triangle(); // 创建时初始化三角形实例
        GLES20.glClearColor(-255.5f, 0.0f, 0.0f, 1.0f);
    }

    @Override
    public void onDrawFrame(GL10 unused) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT); // 每次都重绘背景
        mTriangle.draw(); // 直接调用draw()方法
    }

    @Override
    public void onSurfaceChanged(GL10 unused, int width, int height) {
        GLES20.glViewport(0, 0, width, height);
    }
}
```
在屏幕上显示为
![opengl_triangle_1.png](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Android_note/pics/opengl_triangle_1.png)

### 参考资料
* [什么是 Fragment Shader(片段着色器)？](https://thebookofshaders.com/01/?lan=ch)
* [OpenGL - The Industry Standard for High Performance Graphics](https://www.opengl.org/)
* [如何在Android APP中使用OpenGL ES](https://code.tutsplus.com/zh-hans/tutorials/how-to-use-opengl-es-in-android-apps--cms-28464)
* [现代 OpenGL 教程 - 极客学院](http://wiki.jikexueyuan.com/project/modern-opengl-tutorial/tutorial1.html)
