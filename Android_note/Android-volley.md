---
title: Android 使用Volley请求网络数据
date: 2015-08-03 11:11:09
category: Android_note
tag: [Internet]
---
Android L ； Android Studio 14

个人使用volley的小记，简述使用方法，不涉及volley源码
## 准备工作
导入Volley.jar包：我使用的是现成的jar包，将其放到app/libs目录下即可  
网上可以下载到Volley.jar包

### 使用volley源代码
从github上pull一个下来  
`git pull https://github.com/mcxiaoke/android-volley.git`

把这个文件夹放到工程中，与app目录同级
```
ImportTest/
├── app
├── build.gradle
├── gradle
├── gradle.properties
├── gradlew
├── gradlew.bat
├── ImportTest.iml
├── local.properties
├── settings.gradle
└── volley
```
在android studio中，编辑ImportTest/settings.gradle，加入`':volley'`
```
include ':app',':volley'
```
编辑ImportTest/app/build.gradle；在dependencies中加入`compile project(':volley')`
```
dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    compile project(':volley')//加进来
    testCompile 'junit:junit:4.12'
    compile 'com.android.support:appcompat-v7:23.0.1'
    compile 'com.android.support:design:23.0.1'
}
```
同步一下gradle；可能会错：Gradle sync failed: SSL peer shut down incorrectly

找到这个地方volley/build.gradle，注释掉这两句
```
//apply from: 'https://raw.github.com/mcxiaoke/gradle-mvn-push/master/jar.gradle'
//apply from: 'https://raw.github.com/mcxiaoke/gradle-mvn-push/master/gradle-mvn-push.gradle'
```
## 使用volley
导入jar包已经完成，接下来需要：
- 申请网络权限 `<uses-permission android:name="android.permission.INTERNET"/>`
- 建立网络请求队列 RequestQueue
- 准备Url
- 请求数据

主要代码在VolleyTest.java中，新建了一个LinearLayout来显示数据  
加载String，图片，JSON数据；能够实现异步加载网络图片

VolleyTest.java
```java
        /* 用于显示的控件 */
        cityName = (TextView) findViewById(R.id.city_name);
        temper = (TextView) findViewById(R.id.temper);
        weatherType = (TextView) findViewById(R.id.weather_type);
        webText = (TextView) findViewById(R.id.web_text);
        cat = (ImageView) findViewById(R.id.image_cat);
        wallpaper = (NetworkImageView) findViewById(R.id.image_wallpaper);

		/* 0.准备url，放到HashMap中备用 */
        Map<String, String> sourceUrl = new HashMap<>();/* store url */
        sourceUrl.put("beijing", "http://www.weather.com.cn/adat/cityinfo/101010100.html");
        sourceUrl.put("cat_earphone", "http://pic.cnblogs.com/avatar/706293/20150628195334.png");
        sourceUrl.put("wallpaper0010",
                "http://s.cn.bing.net/az/hprichbg/" +
                        "rb/MaroonBellsVideo_ZH-CN9667920788_1920x1080.jpg");

		/* 1.建立RequestQueue */
        RequestQueue requestQueue = Volley.newRequestQueue(getApplicationContext());/* context */

        /* 2.请求JSON文件；这里利用的是天气预报接口 */
        JsonObjectRequest jsonRequest = new JsonObjectRequest(sourceUrl.get("beijing"), null,
                new Response.Listener<JSONObject>() {
                    @Override
                    public void onResponse(JSONObject jsonObject) {
                        Log.d("rust", jsonObject.toString());
                        /* 2.1处理JSON文件 */
                        try {
                            JSONObject weather = jsonObject.getJSONObject("weatherinfo");
                            cityName.setText(weather.getString("city"));
                            StringBuilder temperRange = new StringBuilder();
                            temperRange.append(weather.getString("temp1"));
                            temperRange.append(" ~ ");
                            temperRange.append(weather.getString("temp2"));
                            temper.setText(temperRange.toString());
                            weatherType.setText(weather.getString("weather"));
                        } catch (JSONException e) {
                            e.printStackTrace();
                            cityName.setText("ERROR");
                        }
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                Log.e("rust", volleyError.toString());
            }
        });
        /* 不要忘记添加到队列中 */
        requestQueue.add(jsonRequest);/* add to request queue */

		/* 3.请求网络图片 */
        ImageRequest catRequest = new ImageRequest(sourceUrl.get("cat_earphone"),
                new Response.Listener<Bitmap>() {
                    @Override
                    public void onResponse(Bitmap bitmap) {
                        cat.setImageBitmap(bitmap);
                    }
                }, 0, 0, Bitmap.Config.RGB_565,
                new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError volleyError) {
                        Log.e("rust", volleyError.toString());
                    }
                }
        );
        requestQueue.add(catRequest);/* add to request queue */

		/* 3.1异步加载图片 */
        ImageLoader imageLoader = new ImageLoader(requestQueue, new BitmapCache());
        ImageLoader.ImageListener listener = ImageLoader.getImageListener(
                wallpaper, R.drawable.orange01, R.drawable.orange02
        );/* ImageView，默认显示图片，加载失败后显示的图片*/
        imageLoader.get(sourceUrl.get("wallpaper0010"), listener, 400, 400);/* 可指定图片最大尺寸 */
        wallpaper.setImageUrl(sourceUrl.get("wallpaper0010"), imageLoader); /* 显示图片 */

        /* 4.获取文本，以获取网站文本为例 */
        StringRequest stringRequest = new StringRequest(
                "http://www.cnblogs.com/",
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        webText.setText(response);
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.e("TAG", error.getMessage(), error);
            }
        });
        requestQueue.add(stringRequest);
```

BitmapCache.java
```java
import android.graphics.Bitmap;
import android.util.LruCache;

import com.android.volley.toolbox.ImageLoader;

public class BitmapCache implements ImageLoader.ImageCache {

    private LruCache<String, Bitmap> mCache;

    public BitmapCache() {
        int maxSize = 10 * 1024 * 1024;/* 10M */
        mCache = new LruCache<String, Bitmap>(maxSize) {
            @Override
            protected int sizeOf(String key, Bitmap bitmap) {
                return bitmap.getRowBytes() * bitmap.getHeight();
            }
        };
    }

    @Override
    public Bitmap getBitmap(String url) {
        return mCache.get(url);
    }

    @Override
    public void putBitmap(String url, Bitmap bitmap) {
        mCache.put(url, bitmap);
    }

}

```
## final
Volley是一个不错的网络框架，源代码可以在`frameworks/volley`中找到

这里的代码仅仅是实现功能；具体使用中会发现，解析JSON时可能会出现乱码，受网络影响JSON可能加载很慢
