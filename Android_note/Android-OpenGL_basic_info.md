---
title: Android OpenGL 基础知识
date: 2018-02-18 20:52:18
category: Android_note
toc: true
---

Android通过Open Graphics Library (OpenGL®)中的OpenGL ES API支持高性能2D和3D图形。
OpenGL为硬件3D图形处理指定了软件接口。Android支持几种OpenGL ES API：
* OpenGL ES 1.0 and 1.1 - Android 1.0 and higher.
* OpenGL ES 2.0 - Android 2.2 (API level 8) and higher.
* OpenGL ES 3.0 - Android 4.3 (API level 18) and higher.
* OpenGL ES 3.1 - Android 5.0 (API level 21) and higher.

### 基础
Android框架中为OpenGL ES API提供了2个基础类，分别是`GLSurfaceView`和`GLSurfaceView.Renderer`

#### `GLSurfaceView`类
这个类是一个视图View，可以像在SurfaceView上那样使用OpenGL API绘制和操作图像。
使用方式是创建一个`GLSurfaceView`实例并把Renderer添加进去。
如果想要获取屏幕触摸事件，应该继承`GLSurfaceView`类并实现touch监听器。

#### `GLSurfaceView.Renderer`接口
定义了在`GLSurfaceView`上绘制图形的方法。必须另外提供一个`GLSurfaceView.Renderer`接口的实现，
并且通过`GLSurfaceView.setRenderer()`方法与`GLSurfaceView`实例关联起来。

`GLSurfaceView.Renderer`接口要求实现的方法有：
* onSurfaceCreated() 系统在创建`GLSurfaceView`时调用这个方法一次。可在这个方法里进行一些初始化操作。
* onDrawFrame() 每次重绘`GLSurfaceView`时系统会调用这个方法。在这里进行一些绘制相关的主要操作。
* onSurfaceChanged() 当`GLSurfaceView`变换时系统会调用这个方法。比如尺寸变换或者方向变换。

### Android OpenGL API
可参考 https://www.khronos.org/registry/OpenGL-Refpages/gl4/

##### `GLES20.glClear(int mask);`
为预设值清空缓存区  
输入值mask： GL_COLOR_BUFFER_BIT, GL_DEPTH_BUFFER_BIT, GL_STENCIL_BUFFER_BIT

##### `GLES20.glGetError()`
如果函数参数不符或者不符合当前上下文设置的状态，则会导致 OpenGL Error。
以error code来表示。绝大多数情况下 OpenGL functions 产生 errors，则不会生效。少数有效。
OpenGL Error 存储在一个队列中，直到该错误被处理。
因此，如果你不定期的检测错误，你将不会知道某个函数某个函数的调用触发了错误。
错误检测应该定期检测，确保知道错误的详细信息。

* GL_NO_ERROR ：（0）当前无错误值
* GL_INVALID_ENUM ：（1280）仅当使用非法枚举参数时，如果使用该参数有指定环境，则返回 GL_INVALID_OPERATION 
* GL_INVALID_VALUE ：（1281）仅当使用非法值参数时，如果使用该参数有指定环境，则返回 GL_INVALID_OPERATION 
* GL_INVALID_OPERATION ：（1282）命令的状态集合对于指定的参数非法。
* GL_STACK_OVERFLOW ：（1283）压栈操作超出堆栈大小。
* GL_STACK_UNDERFLOW ：（1284）出栈操作达到堆栈底部。
* GL_OUT_OF_MEMORY ：（1285）不能分配足够内存时。
* GL_INVALID_FRAMEBUFFER_OPERATION ：（1286）当操作未准备好的真缓存时。
* GL_CONTEXT_LOST ：（1287）由于显卡重置导致 OpenGL context 丢失。

##### `GLES20.glCreateShader`
创建着色器

##### `GLES20.glCompileShader`
编译着色器程序

##### `GLES20.glVertexAttribPointer`
`GLES20.glVertexAttribPointer(maPositionLoc, coordsPerVertex, GLES20.GL_FLOAT, false, vertexStride, vertexBuffer);`

将顶点数据与Attribute关联

```
GLES20.glShaderSource
GLES20.glDeleteShader
GLES20.glGetShaderInfoLog

GLES20.glGetAttribLocation
GLES20.glGetUniformLocation

GLES20.glDeleteTextures
GLES20.glGenTextures
GLES20.glBindTexture
GLES20.glActiveTexture
GLES20.glTexImage2D
GLES20.glTexParameterf

GLES20.glUseProgram
GLES20.glEnableVertexAttribArray
GLES20.glUniform1i
GLES20.glDrawArrays
GLES20.glFinish

GLES20.glDisableVertexAttribArray
GLES20.glTexParameteri
```

### 参考资料
* [OpenGL ES - Android](https://developer.android.com/guide/topics/graphics/opengl.html)
* [OpenGL - The Industry Standard for High Performance Graphics](https://www.opengl.org/)
* [如何在Android APP中使用OpenGL ES](https://code.tutsplus.com/zh-hans/tutorials/how-to-use-opengl-es-in-android-apps--cms-28464)
* [现代 OpenGL 教程 - 极客学院](http://wiki.jikexueyuan.com/project/modern-opengl-tutorial/tutorial1.html)
