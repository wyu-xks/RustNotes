---
title: Android 连接网络
date: 2015-11-03 15:10:01
category: Android_note
tag: [Android_note]
---

## 连接到网络
- 0.申请权限
- 1.选择一个HTTP Client
- 2.检查网络连接
- 3.在一个单独的线程中执行网络操作
- 4.连接并下载数据
- 5.将输入流转换为字符串

### 需要的权限
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"	/>
```

### 选择一个HTTP Client
Android提供了两种HTTP clients: HttpURLConnection 与 Apache HttpClient。
二者均支持HTTPS,流媒体上传和下载,可配置的超时,IPv6与连接池(connectionpooling).
推荐从Android 2.3 Gingerbread版本开始使用 HttpURLConnection

### 检查网络连接
代码：
```java
        ConnectivityManager connectivityManager =
                (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = connectivityManager.getActiveNetworkInfo();
        if (networkInfo != null && networkInfo.isConnected()) {
            //下载数据
        } else {
            //未联网，错误提示
        }
```

### 单独线程中执行下载操作
在UI线程之外执行网络操作。使用AsyncTask类来解决问题

### 连接并下载数据
在执行网络交互的线程里，使用HttpURLConnection来执行一个GET类型的操作并下载数据。
在你调用connect()之后,你可以通过调用getInputStream()来得到一个包含数据InputStream对象。

请注意,getResponseCode()会返回连接状态码(status code).
这是一种获知额外网络连接信息的有效方式。status code是200则意味着连接成功.
### 处理数据
将InputStream转换为String，然后可以显示出来

### 代码
工程中只有一个视图，一个activity  
```java
public class MainActivity extends AppCompatActivity {

    private TextView tvConnected;
    private Button ConnectBtn;
    private EditText urlText;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);
        toolbar.setSubtitle("Test Http");
        tvConnected = (TextView) findViewById(R.id.tv_website); /* 显示下载到的数据和异常信息 */
        ConnectBtn = (Button) findViewById(R.id.btn_conn);      /* 点击启动联网 */
        urlText = (EditText) findViewById(R.id.et_website);     /* 输入网址 */
        ConnectBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                myConnectHandler(v);
            }
        });
    }

    public void myConnectHandler(View view) {
        String stringUrl = urlText.getText().toString();/* 必须对输入的网址进行判断 */
        if (stringUrl.equals("")) {/* 未输入网址，弹出提示 */
            Toast.makeText(getApplicationContext(),
                    "Please input website", Toast.LENGTH_SHORT).show();
            return;
        }
        /* 检查网络连接 */
        ConnectivityManager connectivityManager =
                (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = connectivityManager.getActiveNetworkInfo();
        if (networkInfo != null && networkInfo.isConnected()) {
            Log.d("rust", "networkInfo == " + networkInfo.toString());
            /* 网络连接正常，可以联网下载数据 */
            /* 传入url进行下载 */
            new DownloadWebpageText().execute(stringUrl);
        } else {
            Toast.makeText(getApplicationContext(),
                    "Please input website", Toast.LENGTH_SHORT).show();
        }
    }

    /**
     * 在UI线程之外执行网络操作
     */
    private class DownloadWebpageText extends AsyncTask {

        @Override
        protected Object doInBackground(Object[] params) {
            Log.d("rust", "DownloadWebpageText doInBackground..." + params[0].toString());
            try {
                return downloadUrl(params[0].toString());/* 开始下载 */
            } catch (IOException e) {
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onPostExecute(Object o) {
            tvConnected.setText(o.toString()); /* 显示下载到的数据 */
        }
    }

    /*
     * 给定一个url，建立一个HttpURLConnection连接，取回网页数据流
     */
    private String downloadUrl(String myurl) throws IOException {
        InputStream is = null;
        String inUrl = myurl;
        String head = "http://";/* 自动添加的前缀 */
        int len = 500;/* 只显示前500个字符 */
        try {
            /* 对输入网址判断 */
            if (myurl.length() >= 7 && !head.equals(myurl.substring(0, 7))) {
                myurl = head + inUrl;/* 加上http:// 注意判断已有字符串长度，不要越界 */
            }
            URL url = new URL(myurl);
            /* 选择使用 HttpURLConnection */
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setReadTimeout(10000/* 毫秒 */);
            conn.setConnectTimeout(15000/* 毫秒 */);
            conn.setDoInput(true);
            int response = conn.getResponseCode();/* http状态码 */
            Log.d("rust", "The response is " + response);
            if (response >= 200 && response <= 206) {/* 连接正常 */
                is = conn.getInputStream();
                String contentAsString = readIt(is, len);/* 转换为字符串 */
                return contentAsString;
            } else {
                return response + " ERROR";/* 状态异常时报错 */
            }
        } catch (IOException e) {
            e.printStackTrace();
            return "ERROR: " + myurl;
        } finally {
            /* 确保关闭输入流 */
            if (is != null)
                is.close();
        }
    }

    /**
     * 将输入流转换为字符串
     */
    public String readIt(InputStream stream, int len) throws IOException, UnsupportedEncodingException {
        Reader reader = null;
        reader = new InputStreamReader(stream, "UTF-8");
        char buffer[] = new char[len];
        reader.read(buffer);
        return new String(buffer);
    }
}
```


------
错误：  
java.net.MalformedURLException: Protocol not found:

url地址错误，一般要加上http:// 或者 https://  
因此在代码中加入了对输入网址的判断
