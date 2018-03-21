---
title: Android 问题、参考资料汇总
date: 2000-11-11 11:11:11
category: Android_note
tag: [Android]
toc: true
---

按顺序收集Android相关的参考书籍与资料网址与相关要点

![](https://raw.githubusercontent.com/RustFisher/Rustnotes/master/Android_note/pics/android_t1.png)

大致内容太如下：
* Activity， Service， Broadcast， Content Provider
* 线程
* 进程与AIDL
* Handler机制
* View，自定义view，view分析
* NDK
* gradle相关
* 图片处理，图像相关
* 音视频相关
* 错误分析，例如ANR，OOM
* 性能优化
* Android框架解析，源码学习
------

## Android 组件，机制，框架，调优，debug和源码学习
https://www.gitbook.com/book/izobs/android-framework-development-guide

### Activity
* [Andorid Activity Basic - RustFisher](http://rustfisher.github.io/2017/09/09/Android_note/Android-Activity_basic/)
* [Google API Guide Activity](https://developer.android.com/guide/components/activities.html)
* [Activity Manager Flow](https://izobs.gitbooks.io/android-framework-development-guide/content/activitymanager/activity_manager_flow.html)
* [Android Activity 启动流程分析 - RustFisher](http://rustfisher.github.io/2017/09/06/Android_note/RTFSC-Android_Activity_start_flow_analysis/)
* [Android Fragment 基础概念](http://rustfisher.github.io/2015/09/25/Android_note/Android-app_fragment_1_define/)
* [Android Fragment 加载方法](http://rustfisher.github.io/2015/09/24/Android_note/Android-app_fragment_2_load_fragment/)
* [Android Fragment 间的通信](http://rustfisher.github.io/2015/09/29/Android_note/Android-app_fragment_3_contact_fragments/)

### Service
* [Google API Guide Service](https://developer.android.com/guide/components/services.html)
* [Google API Guide AIDL](https://developer.android.com/guide/components/aidl.html)
* [Android IntentService 分析和用法](http://rustfisher.github.io/2017/06/09/Android_note/Android-IntentService/)
* [startService启动过程分析 - Gityuan](http://gityuan.com/2016/03/06/start-service/)

### Broadcast
* [Google API Guide Broadcasts](https://developer.android.com/guide/components/broadcasts.html)
* [Android Broadcast 广播机制，用法和介绍 - RustFisher](http://rustfisher.github.io/2015/10/29/Android_note/Android-broadcast/)  
* [Broadcast 源码跟踪分析 - RustFisher](http://rustfisher.github.io/2015/12/19/Android_note/RTFSC-Android_sendBroadcast_analysis/)

### Content Provider
* [Google developer content-providers](https://developer.android.com/guide/topics/providers/content-providers.html)

### 线程
* [Java中的线程 - RustFisher](http://rustfisher.github.io/2017/01/08/Java_note/Java_Multi_thread/)
* [Android 线程用法 - RustFisher](http://rustfisher.github.io/2015/08/01/Android_note/Android-thread_intro/)
* [Android ThreadPoolExecutor 初步 - RustFisher](http://rustfisher.github.io/2016/12/01/Android_note/Android-ThreadPoolExecutor_intro/)
* [Android AsyncTask - 简单介绍并从源码角度分析它的流程和特点 - RustFisher](http://rustfisher.github.io/2017/06/22/Android_note/Android-AsyncTask/)

### 进程，Binder
* [universus的专栏 - Android Binder设计与实现 - 设计篇](http://blog.csdn.net/universus/article/details/6211589)
* [老罗的Android之旅 - Android进程间通信（IPC）机制Binder简要介绍和学习计划](http://blog.csdn.net/luoshengyang/article/details/6618363)
* [Android Binder 是什么，用来干什么，怎么用 - RustFisher](http://rustfisher.github.io/2015/10/26/Android_note/Android-Binder/)

### Android Handler
* [Android Handler 机制 - Looper，Message，MessageQueue - RustFisher](http://rustfisher.github.io/2017/06/07/Android_note/Android-Handler/)
* [Android Handler可能会造成内存泄漏以及应对方法 - RustFisher](http://rustfisher.github.io/2015/10/07/Android_note/Android-Handler_may_leak_memory/)

### UI View 分析
* [Android 自定义SurfaceView - RustFisher](http://rustfisher.github.io/2016/10/28/Android_note/Android-Custom_surface_view/)
* [Android View 事件分发机制](http://www.cnblogs.com/linjzong/p/4191891.html)

### NDK
* [Android NDK 初步配置 - RustFisher](http://rustfisher.github.io/2016/06/14/Android_note/Android-NDK_Getting_Started/)
* [Android NDK 示例-返回字符串，数组，Java对象；兼容性问题 - RustFisher](http://rustfisher.github.io/2016/08/02/Android_note/Android-NDK_first_example/)
* [Android NDK 读写文件 - RustFisher](http://rustfisher.github.io/2017/03/16/Android_note/Android-NDK-read-write-file/)

### gradle
* [Gradle for Android 开始 - RustFisher](http://rustfisher.github.io/2017/01/19/Android_note/Gradle_for_android_Start/)
* [Gradle 基础自定义构建 - RustFisher](http://rustfisher.github.io/2017/01/19/Android_note/Gradle_for_android_Basic_Build_Customization/)
* [Gradle 构建多种版本 - RustFisher](http://rustfisher.github.io/2017/01/19/Android_note/Gradle_for_android_Creating_Build_Variants/)

### 性能优化
* [Android性能与优化 龚振杰](https://yq.aliyun.com/articles/73518?spm=5176.100240.searchblog.8.DKrFCO)
从编码习惯到编译发布和工具参考，作者给出了很多关于Android应用开发的建议。

### Android框架解析，源码学习
* [Android Volley 使用与源码解析 - RustFisher](http://rustfisher.github.io/2015/08/03/Android_note/Android-volley/)

### Android OpenGL ES
* [Android OpenGL 基础知识](https://rustfisher.github.io/2018/02/18/Android_note/Android-OpenGL_basic_info/)
* [Android OpenGL 基本环境，绘制简易图形](https://rustfisher.github.io/2018/01/26/Android_note/Android-OpenGL_basic_step/)
* [The Book of Shaders - 关于 Fragment Shaders（片段着色器）的入门指南](http://thebookofshaders.com/?lan=ch)
* 使用OpenGL的Android库 https://github.com/Rajawali/Rajawali 
* 关于OpenGL http://www.learnopengles.com/android-lesson-one-getting-started/
* 讲解Opengl http://www.songho.ca/opengl/index.html
* Vulkan https://developer.android.com/ndk/guides/graphics/getting-started.html#downloading

### Android 音视频从入门到提高
* [Android AudioRecord和AudioTrack实现音频PCM数据的采集和播放，并读写音频wav文件](https://rustfisher.github.io/2018/02/24/Android_note/Android-audio_AudioRecord_AudioTrack_pcm_wav/)
* [Android 分别使用 SurfaceView 和 TextureView 来预览 Camera，获取NV21数据](https://rustfisher.github.io/2018/02/24/Android_note/Android-camera_nv21_surfaceview_textureview/)
* [Android 使用 MediaExtractor 和 MediaMuxer 解析和封装 mp4 文件](https://github.com/RustFisher/RustNotes/blob/master/Android_note/Android-media_MediaMuxer_MediaExtractor_mp4.md)
* [Android 编解码 MediaCodec, Image](https://github.com/RustFisher/RustNotes/blob/master/Android_note/Android-MediaCodec_about.md)
* 解释数字视频技术 https://github.com/leandromoreira/digital_video_introduction/blob/master/simplified-chinese/README-cn.md
* 《雷霄骅的专栏》：http://blog.csdn.net/leixiaohua1020
* 《Android音频开发》：http://ticktick.blog.51cto.com/823160/d-15
* 《FFMPEG Tips》：http://ticktick.blog.51cto.com/823160/d-17
* 《Learn OpenGL 中文》：https://learnopengl-cn.readthedocs.io/zh/latest/
* Android Graphic https://source.android.com/devices/graphics/

### basic
* [Java ConcurrentHashMap 简介与源码阅读](https://rustfisher.github.io/2018/01/24/Java_note/Java_concurrenthashmap_note/)

## 参考资料网址

* Android 源码国内镜像站 https://mirror.tuna.tsinghua.edu.cn/help/AOSP/
* 分析apk中方法数量 http://inloop.github.io/apk-method-count/
* Android multi-media selector based on MVP mode.
https://github.com/Bilibili/boxing
* Okio is a new library that complements java.io and java.nio to make it much easier to access, store, and process your data.  
https://github.com/square/okio
* alibaba VirtualLayout  
https://github.com/alibaba/vlayout/blob/master/README-ch.md
* Android MediaCodec stuff http://bigflake.com/mediacodec/
