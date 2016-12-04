---
title: Android 使用OpenCV - 将OpenCV相关库做成模块形式
date: 2017-12-22 16:59:14
category: Android_note
toc: true
---

* win7
* Android Studio 3.0.1

## 将OpenCV库做成一个模块
官网[OpenCV4Android SDK](https://docs.opencv.org/2.4/doc/tutorials/introduction/android_binary_package/O4A_SDK.html)
可以找到下载地址 https://sourceforge.net/projects/opencvlibrary/files/opencv-android/  
这里使用的是2.4.9版本

下载得到 OpenCV-2.4.9-android-sdk，需要的代码和库在这里在里面的`sdk/native`目录
```
OpenCV-2.4.9-android-sdk/sdk/native
$ tree -L 2
.
|-- 3rdparty
|   `-- libs
|-- jni
|   `-- ......
`-- libs
    |-- armeabi
    |-- armeabi-v7a
    |-- mips
    `-- x86
```

新建一个Android项目`TestOpenCVProj`，`File->New->Import Module...`，选择`OpenCV-2.4.9-android-sdk\sdk\java`，
导入模块名为`openCVLibrary249`

将目录`OpenCV-2.4.9-android-sdk\sdk\native\libs`复制到模块`openCVLibrary249`下，与`src`同级
```
OpenCVTest/TestOpenCVProj/openCVLibrary249
$ tree -L 1
.
|-- build
|-- build.gradle
|-- libs
|-- lint.xml
|-- openCVLibrary249.iml
`-- src
```
修改模块openCVLibrary249的`build.gradle`文件
```
apply plugin: 'com.android.library'

android {
    compileSdkVersion 26
    buildToolsVersion "26.0.3" // 根据实际情况修改

    defaultConfig {
        minSdkVersion 8
        targetSdkVersion 26
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.txt'
        }
    }

    sourceSets {
        main {
            jni.srcDirs = []
            jniLibs.srcDirs = ['libs'] // 指定so库的位置
        }
    }
}
```
至此，OpenCV相关库已经成了一个Android Studio的模块

在App中调用，添加模块依赖后，调用`OpenCVLoader.initDebug()`进行初始化


## 使用OpenCV模块的例子
实现一个识别的功能，预先准备好特征文件hand.xml，放到手机存储根目录

在工程中先加载并初始化模块
```java
    // OpenCV库静态加载并初始化
    private void staticLoadCVLibraries() {
        boolean load = OpenCVLoader.initDebug();
        if (load) {
            Log.i(TAG, "Open CV Libraries loaded...");
        }
    }
```

加载后初始化相关对象
```java
    private Bitmap mSelectedBitmap;  // 选中的bitmap
    CascadeClassifier mCHandCascade;
    private String mHandXMLPath = Environment.getExternalStorageDirectory() + File.separator + "hand.xml";
    
    // 初始化
    private void initCVUtils() {
        File xmlFile = new File(mHandXMLPath);
        Log.d(TAG, "xmlFile.exists: " + xmlFile.exists());

        mCHandCascade = new CascadeClassifier(mHandXMLPath);
        Log.d(TAG, "mCHandCascade: " + mCHandCascade.toString());
    }
```
在图片中识别特定物体。利用模块提供的方法，将bitmap转换成mat。
```java
    private void detectObject() {
        Mat src = new Mat();
        Utils.bitmapToMat(mSelectedBitmap, src); // bitmap转成mat
        handGestureRecognition(src);
    }
    private void handGestureRecognition(Mat srcFrame) {
        Log.d(TAG, "Try to detect hand srcFrame: " + srcFrame);
        MatOfRect hands = new MatOfRect();
        Mat frame_gray = new Mat();

        Imgproc.cvtColor(srcFrame, frame_gray, Imgproc.COLOR_BGR2GRAY);
        Imgproc.equalizeHist(frame_gray, frame_gray);

        mCHandCascade.detectMultiScale(frame_gray, hands); // Detect hand
//        mCHandCascade.detectMultiScale(frame_gray, hands, 1.1, 2, Objdetect.CASCADE_DO_CANNY_PRUNING,
//                new Size(20, 20), new Size(2000, 2000));
        mCHandCascade.detectMultiScale(frame_gray, hands);
        for (Rect rect : hands.toList()) {
            Log.d(TAG, "handGestureRecognition: " + rect);
        }
        Log.d(TAG, "Try to detect hand - END");
    }
```
识别计算的耗时与若输入的图片尺寸正相关。

裁剪bitmap的相关方法
```java
    public static Bitmap.createBitmap(@NonNull Bitmap source, int x, int y, int width, int height,
            @Nullable Matrix m, boolean filter){...}
    /**
     * 裁剪
     *
     * @param bitmap 原图
     * @return 裁剪后的图像
     */
    private Bitmap cropBitmap(Bitmap bitmap) {
        int w = bitmap.getWidth(); // 得到图片的宽，高
        int h = bitmap.getHeight();
        int cropWidth = w / 3;
        int cropHeight = h / 3;
        return Bitmap.createBitmap(bitmap, w / 3, h / 3, cropWidth, cropHeight, null, false);
    }
```

## 参考资料

* [Android 使用OpenCV的三种方式(Android Studio) - CSDN](http://blog.csdn.net/sbsujjbcy/article/details/49520791)
* [Android Studio中配置及使用OpenCV示例（一） - CSDN](http://blog.csdn.net/gao_chun/article/details/49359535)
