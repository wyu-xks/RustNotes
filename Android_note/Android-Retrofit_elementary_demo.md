---
title: Android Retrofit 使用入门-简单示例
date: 2016-10-13 20:51:14
category: Android_note
tag: [Internet]
toc: true
---

Retrofit 一款针对Android网络请求框架。  
https://github.com/square/retrofit

Type-safe HTTP client for Android and Java by Square, Inc.

## 使用Retrofit - 以连接到github为例

### 开始前的网络准备
使用火狐浏览器插件HttpRequester向github发起查询square的网络请求
请求地址为：`https://api.github.com/repos/square/retrofit/contributors`
用GET的方式发请求，获得的结果中包含retrofit贡献者的信息（JSON格式）
```
{
    "login": "xxxxxx",
    ......
    "contributions": 123
  }
```
AndroidStudio插件：GsonFormat；需要翻墙安装

装好后可以直接根据JSON信息生成相应的对象；这里生成`GitHubContributor.java`

### Android 工程
AndroidStudio中添加依赖
```
    compile 'com.squareup.retrofit2:retrofit:2.0.2'
    compile 'com.squareup.retrofit2:converter-gson:2.0.2'
```

申请网络权限
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

部分工程文件如下
```
|-- beans
|   `-- GitHubContributor.java
|-- center
|   `-- NetworkCenter.java
|-- github
|   `-- GitHubService.java
|-- MainActivity.java
```

网络相关配置
```java
public class NetworkCenter {
    public static final String GITHUB_BASE_URL = "https://api.github.com/";
    public static final String GITHUB_CONTRIBUTORS_URL =
    "repos/{owner}/{repo}/contributors";
}
```

这里的`{owner}/{repo}`可以使用传入的参数
如果是要改变Header，使用`@Header`；非常灵活
```java
/**
* 定义请求接口 - 要按照后台的协议来定
*/
public interface GitHubService {
    //    @GET("repos/{owner}/{repo}/contributors")
    @GET(NetworkCenter.GITHUB_CONTRIBUTORS_URL)
    Call<List<GitHubContributor>> contributors(
            @Path("owner") String owner,
            @Path("repo") String repo);
}
```

网络请求部分
```java
// 构建Retrofit对象，加入base url，指定转换器为GsonConverterFactory
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(NetworkCenter.GITHUB_BASE_URL)
                .addConverterFactory(GsonConverterFactory.create())
                .build();
        // 创建 GitHubService API interface 的实例
        GitHubService githubService = retrofit.create(GitHubService.class);
        // 创建一个Call的实例；指定"square" "retrofit"
        Call<List<GitHubContributor>> callSquare = githubService.contributors("square", "retrofit");

        // 获取这个github仓库的列表
        callSquare.enqueue(new Callback<List<GitHubContributor>>() {

            @Override
            public void onResponse(Call<List<GitHubContributor>> call, Response<List<GitHubContributor>> response) {
                Log.d(TAG, "github onResponse: " + response.raw().toString());
                String res = "Square retrofit\n";
                if (response.isSuccessful()) {
                    for (GitHubContributor gitHubContributor : response.body()) {
                        res += (gitHubContributor.getLogin() + " commits " + gitHubContributor.getContributions() + "\n");
                    }
                }
                mResTv1.setText(res);// 显示出来
            }

            @Override
            public void onFailure(Call<List<GitHubContributor>> call, Throwable t) {
                Log.e(TAG, "request square onFailure");
            }

        });
```
如果要获取另一个仓库的信息，在创建Call实例时传入仓库名和用户名即可

例如
```java
Call<List<GitHubContributor>> callRust = githubService.contributors("RustFisher", "aboutView");
```
至此，单独使用Retrofit的例子完毕
