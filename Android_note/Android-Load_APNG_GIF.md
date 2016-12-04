---
title: Android load GIF or APNG
date: 2016-05-28 16:09:14
category: Android_note
tag: [Android_UI]
toc: true
---

主要记的是第三方库的使用。

#### 使用Glide加载图片
添加依赖
```
    compile 'com.github.bumptech.glide:glide:3.7.0'   // glide
    compile 'jp.wasabeef:glide-transformations:2.0.1' // 另外的库
```
第二个库是用来添加图片效果的，例如添加高斯糊化效果

例如下面加载一个高斯糊化后的图片
```java
    Glide.with(getApplicationContext())
            .load(R.drawable.work_bg)
            .bitmapTransform(new BlurTransformation(getApplicationContext(), 23, 4))
            .into(view1);
```

#### Load GIF
尝试把GIF解成PNG图片，然后做成帧动画。结果图片太多，帧动画内存溢出
>java.lang.OutOfMemoryError: Failed to allocate a 14080012 byte allocation with 12451176 free bytes and 11MB until OOM

用Android的android.graphics.Movie 时，同样的GIF图，在不同的屏幕上会显示出不同的大小。  
因为屏幕的像素点大小不同。高清晰度的屏幕显示出来的图片，比低像素的屏幕的图片小。

而且一般要关闭Activity的硬件加速。或在复写的View中`setLayerType(View.LAYER_TYPE_SOFTWARE, null);`

或者是在manifest中设置。若不关闭，应用在魅族手机上会报错闪退。

使用第三方库glide(https://github.com/bumptech/glide) 来异步加载图片。注意调用diskCacheStrategy方法。
```java
Glide.with(this).load(R.drawable.float_island)
.asGif().diskCacheStrategy(DiskCacheStrategy.SOURCE).into(floatImageView);
```
图像大小可以用dp单位来设定。很好地解决了问题。性能上还要测试一下。

#### Load APNG
很可惜的是Android目前对apng支持不好。

使用的库是： https://github.com/sahasbhop/apng-view  
`compile 'com.github.sahasbhop:apng-view:1.3'`

初始化
```java
public class MyApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        ApngImageLoader.getInstance().init(getApplicationContext());
    }
}
```
新建assets目录，把APNG图片放进去。参考： http://www.jianshu.com/p/e84710dee554

在layout中定义一个ImageView，图片的大小可以按需求定义。它会以显示出完整图片为优先。
```xml
    <ImageView
        android:id="@+id/apng_image_view"
        android:layout_width="200dp"
        android:layout_height="200dp"
        android:layout_centerHorizontal="true" />
```
Activity中加载图片：
```java
public class AnimationActivity extends Activity {
    ImageView floatImageView;
    ImageView apngImageView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_frame_anima);
        floatImageView = (ImageView) findViewById(R.id.gif_2);
        apngImageView = (ImageView) findViewById(R.id.apng_image_view);

        String uri = "assets://apng/anima_a.png";// 注意uri的格式
        ApngImageLoader.getInstance().displayApng(uri, apngImageView,
                new ApngImageLoader.ApngConfig(3, true));// 直接显示图片
    }

}
```
