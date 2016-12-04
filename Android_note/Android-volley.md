---
title: Android Volley 使用与源码解析
date: 2015-08-03 11:11:09
category: Android_note
tag: [Internet]
---

* Android L 
* Android Studio 14

年代久远，此篇记录已过时

# 使用 Volley
## 准备工作
个人使用volley的小记，简述使用方法

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

# Volley 源码解析
Volley擅长执行用来显示UI的RPC操作

## 使用时注意事项
- 别忘了添加到请求队列中

## 流程解析
### 使用Volley.newRequestQueue新建请求队列
```java
// 新建一个请求队列，使用Volley.newRequestQueue(Context)
RequestQueue requestQueue = Volley.newRequestQueue(this);
// 或
RequestQueue requestQueue = Volley.newRequestQueue(getApplicationContext());
```

### 例子：建立 JsonObjectRequest ，并添加到请求队列中
首先看 JsonObjectRequest 的继承关系，按照这个关系来解析流程
```java
public class JsonObjectRequest extends JsonRequest<JSONObject>
    public abstract class JsonRequest<T> extends Request<T>
        public abstract class Request<T> implements Comparable<Request<T>>
```

新建JsonObjectRequest实例时，使用JsonRequest.java的构造方法（也可将此看做API）：  
(String url, JSONObject/*JSON对象*/, Listener<JSONObject> /*监听器*/, ErrorListener /*错误监听器*/)  
如果JSON对象为null，则默认参数为Method.GET
```java
    /**
     * Constructor which defaults to <code>GET</code> if <code>jsonRequest</code> is
     * <code>null</code>, <code>POST</code> otherwise.
     *
     * @see #JsonObjectRequest(int, String, JSONObject, Listener, ErrorListener)
     */
    public JsonObjectRequest(String url, JSONObject jsonRequest, Listener<JSONObject> listener,
            ErrorListener errorListener) {
        this(jsonRequest == null ? Method.GET : Method.POST, url, jsonRequest,
                listener, errorListener);
    }
```
跳转到JsonObjectRequest.java中的构造方法：  
```java
    /**
     * Creates a new request.
     * @param method the HTTP method to use
     * @param url URL to fetch the JSON from
     * @param jsonRequest A {@link JSONObject} to post with the request. Null is allowed and
     *   indicates no parameters will be posted along with request.
     * @param listener Listener to receive the JSON response
     * @param errorListener Error listener, or null to ignore errors.
     */
    public JsonObjectRequest(int method, String url, JSONObject jsonRequest,
            Listener<JSONObject> listener, ErrorListener errorListener) {
        super(method, url, (jsonRequest == null) ? null : jsonRequest.toString(), listener,
                errorListener);
    }
```
按照继承关系，再跳到JsonRequest.java中：  
```java
    public JsonRequest(int method, String url, String requestBody, Listener<T> listener,
            ErrorListener errorListener) {
        super(method, url, errorListener);
        mListener = listener;
        mRequestBody = requestBody;
    }

    // listener 请求回传数据
    @Override
    protected void deliverResponse(T response) {
        if (mListener != null) {
            mListener.onResponse(response);
        }
    }

    // requestBody 获取字节
    // PROTOCOL_CHARSET = "utf-8"
    @Override
    public byte[] getBody() {
        try {
            return mRequestBody == null ? null : mRequestBody.getBytes(PROTOCOL_CHARSET);
        } catch (UnsupportedEncodingException uee) {
            VolleyLog.wtf("Unsupported Encoding while trying to get the bytes of %s using %s",
                    mRequestBody, PROTOCOL_CHARSET);
            return null;
        }
    }
```
method, url, errorListener传入到Request.java中：  

```java
    /**
     * Creates a new request with the given method (one of the values from {@link Method}),
     * URL, and error listener.  Note that the normal response listener is not provided here as
     * delivery of responses is provided by subclasses, who have a better idea of how to deliver
     * an already-parsed response.
     */
    public Request(int method, String url, Response.ErrorListener listener) {
        mMethod = method;
        mUrl = url;
        mIdentifier = createIdentifier(method, url);
        mErrorListener = listener;
        setRetryPolicy(new DefaultRetryPolicy());// 默认设定

        mDefaultTrafficStatsTag = findDefaultTrafficStatsTag(url);
    }

/*  Request 使用默认的设定；
    /**
     * Constructs a new retry policy using the default timeouts.
     */
    public DefaultRetryPolicy() {
        this(DEFAULT_TIMEOUT_MS, DEFAULT_MAX_RETRIES, DEFAULT_BACKOFF_MULT);
    }
*/

    // 产生ID
    private static String createIdentifier(final int method, final String url) {
        return InternalUtils.sha1Hash("Request:" + method + ":" + url +
                ":" + System.currentTimeMillis() + ":" + (sCounter++));
    }
```
一个JsonObjectRequest实例创建好，传给请求队列 requestQueue  
`requestQueue.add(jsonRequest);/* add to request queue */`  
在add方法中，判断 request 是否能被cache化，不能被cache化直接添加进 mNetworkQueue  
如果能被cache化，取得 request 的 key，查看是否需要排队  
不用排队的，加入 mCacheQueue；当前队列有请求在排队，则排在后面 mWaitingRequests  
把 mCacheQueue, mNetworkQueue 一起加入
RequestQueue.java
```java

    /**
     * The set of all requests currently being processed by this RequestQueue. A Request
     * will be in this set if it is waiting in any queue or currently being processed by
     * any dispatcher.
     */
    private final Set<Request<?>> mCurrentRequests = new HashSet<Request<?>>();

    /** The cache triage queue. */
    private final PriorityBlockingQueue<Request<?>> mCacheQueue =
        new PriorityBlockingQueue<Request<?>>();

    /** The queue of requests that are actually going out to the network. */
    private final PriorityBlockingQueue<Request<?>> mNetworkQueue =
        new PriorityBlockingQueue<Request<?>>();

    // 存放request
    private final Set<Request<?>> mCurrentRequests = new HashSet<Request<?>>();

    /**
     * Adds a Request to the dispatch queue.
     * @param request The request to service
     * @return The passed-in request
     */
    public <T> Request<T> add(Request<T> request) {
        // Tag the request as belonging to this queue and add it to the set of current requests.
        request.setRequestQueue(this);
        synchronized (mCurrentRequests) {
            mCurrentRequests.add(request);
        }

        // Process requests in the order they are added.
        request.setSequence(getSequenceNumber());
        request.addMarker("add-to-queue");

        // If the request is uncacheable, skip the cache queue and go straight to the network.
        if (!request.shouldCache()) {
            mNetworkQueue.add(request);
            return request;
        }

        // Insert request into stage if there's already a request with the same cache key in flight.
        synchronized (mWaitingRequests) {
            String cacheKey = request.getCacheKey();// 获取 请求的 key
            if (mWaitingRequests.containsKey(cacheKey)) {
                // There is already a request in flight. Queue up.
                Queue<Request<?>> stagedRequests = mWaitingRequests.get(cacheKey);// 等待队列
                if (stagedRequests == null) {
                    stagedRequests = new LinkedList<Request<?>>();
                }
                stagedRequests.add(request);// 需要排队的
                mWaitingRequests.put(cacheKey, stagedRequests);
                if (VolleyLog.DEBUG) {
                    VolleyLog.v("Request for cacheKey=%s is in flight, putting on hold.", cacheKey);
                }
            } else {
                // Insert 'null' queue for this cacheKey, indicating there is now a request in
                // flight.
                mWaitingRequests.put(cacheKey, null);// 当前已无排队的请求
                mCacheQueue.add(request);// 加入队列中
            }
            return request;
        }
    }

    // 启动
    /**
     * Starts the dispatchers in this queue.
     */
    public void start() {
        stop();  // Make sure any currently running dispatchers are stopped.
        // Create the cache dispatcher and start it.
        mCacheDispatcher = new CacheDispatcher(mCacheQueue, mNetworkQueue, mCache, mDelivery);
        mCacheDispatcher.start();// 启动线程

        // Create network dispatchers (and corresponding threads) up to the pool size.
        for (int i = 0; i < mDispatchers.length; i++) {
            NetworkDispatcher networkDispatcher = new NetworkDispatcher(mNetworkQueue, mNetwork,
                    mCache, mDelivery);
            mDispatchers[i] = networkDispatcher;
            networkDispatcher.start();
        }
    }
```
CacheDispatcher 启动线程来进行下载；CacheDispatcher.java
```java
public class CacheDispatcher extends Thread

    ......

    /**
     * Creates a new cache triage dispatcher thread.  You must call {@link #start()}
     * in order to begin processing.
     *
     * @param cacheQueue Queue of incoming requests for triage
     * @param networkQueue Queue to post requests that require network to
     * @param cache Cache interface to use for resolution
     * @param delivery Delivery interface to use for posting responses
     */
    public CacheDispatcher(
            BlockingQueue<Request<?>> cacheQueue, BlockingQueue<Request<?>> networkQueue,
            Cache cache, ResponseDelivery delivery) {
        mCacheQueue = cacheQueue;
        mNetworkQueue = networkQueue;
        mCache = cache;
        mDelivery = delivery;
    }

    // 在复写的run方法中，有一个while(true)循环执行下载
    @Override
    public void run() {
        ......
        Request<?> request;
        while (true) {
            // release previous request object to avoid leaking request object when mQueue is drained.
            request = null;
            try {
                // Take a request from the queue.
                request = mCacheQueue.take();
            } catch (InterruptedException e) {
                // We may have been interrupted because it was time to quit.
                if (mQuit) {
                    return;
                }
                continue;
            }
            try {
                ......

                // We have a cache hit; parse its data for delivery back to the request.
                request.addMarker("cache-hit");
                Response<?> response = request.parseNetworkResponse(
                        new NetworkResponse(entry.data, entry.responseHeaders));
                request.addMarker("cache-hit-parsed");

                if (!entry.refreshNeeded()) {
                    // Completely unexpired cache hit. Just deliver the response.
                    mDelivery.postResponse(request, response);
                } else {
                    // Soft-expired cache hit. We can deliver the cached response,
                    // but we need to also send the request to the network for
                    // refreshing.
                    request.addMarker("cache-hit-refresh-needed");
                    request.setCacheEntry(entry);

                    // Mark the response as intermediate.
                    response.intermediate = true;

                    // Post the intermediate response back to the user and have
                    // the delivery then forward the request along to the network.
                    final Request<?> finalRequest = request;
                    mDelivery.postResponse(request, response, new Runnable() {
                        @Override
                        public void run() {
                            try {
                                mNetworkQueue.put(finalRequest);
                            } catch (InterruptedException e) {
                                // Not much we can do about this.
                            }
                        }
                    });
                }
            } catch (Exception e) {
                VolleyLog.e(e, "Unhandled exception %s", e.toString());
            }
        }
    }
```
