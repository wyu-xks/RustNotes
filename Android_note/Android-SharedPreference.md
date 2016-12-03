---
title: Android SharedPreference 存储
date: 2016-03-16 15:10:05
category: Android_note
tag: [Android_note]
---

键值对的方式来存储数据。不要把密码存在这里。

## 将数据存储到SharedPreference中，首先需要一个SharedPreference对象。  
获取这个对象有三种方法：

### 1.Context类中的getSharedPreferences()方法  
    往这个方法中传入2个参数。首先是文件名。其次是指定操作模式。
getSharedPreferences("文件名",操作模式);文件名自取。

操作模式主要两种：

* MODE_PRIVATE;只有当前程序能对这个SharedPreference文件进行读写。
* MODE_MULTI_PROCESS;多个进程对这个文件进行读写。

例如：
```java
SharedPreferences.Editor editor = getSharedPreferences("fileName",MODE_PRIVATE).edit();
```
得到一个SharedPreference.Editor对象editor。

### 2.Activity类中的getPreferences()方法
使用这个方法，会将当前活动的类名作为SharedPreference的文件名。

### 3.PreferenceManager类中的getDefaultSharedPreference()方法
使用这个方法，会将当前活动的类名作为前缀来命名SharedPreference文件。

## 获取对象之后，向文件中存储数据
例如我们获得了editor对象。可以直接调用很多方法：
```java
editor.putString("name","Rust"); // 输入字符串
editor.putBoolean("option",ture);// 输入布尔值
editor.putInt("age",62);         // 输入整型
......
editor.commit();    // 提交数据；输入数据后别忘了提交。

editor.clear();     // 我们也可以清除数据：
```
## 从SharedPreference文件中读取数据
取数据使用get方法。每个get方法对应一个put方法。

首先还是得到一个对象，再逐个取出数据：
```java
SharedPreferences prefData = getSharedPreferences("fileName",MODE_PRIVATE);
int age =  prefData.getInt("age", 0 );    //这个0是默认值
String name = prefData.getString("name", "" );    //默认为空
```
