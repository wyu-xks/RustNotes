---
title: 使用Android Studio
date: 2015-08-29 20:11:37
category: Android_note
tag: [AndroidStudio,Tools]
toc: true
---
ubuntu14.04

用命令行打开Android Studio

编译需要jdk7，网上下载一个，解压。打开Android Studio，设置那里找到jdk7的文件夹即可

此时java -version 还是open jdk7   不影响

## android studio很卡解决方法

每次升级/安装 Android Studio 之后最好都修改一下这个参数：到 Android Studio 安装目录，找到 bin/studio.vmoptions（文件名可能因操作系统而不同，但大同小异），然后把 -xmx 后面的数字改大一点，比如 2048m 或4096m。

-xmx 参数是 Java 虚拟机启动时的参数，用于限制最大堆内存。Android Studio 启动时设置了这个参数，并且默认值很小，没记错的话，只有 768mb。 一旦你的工程变大，IDE 运行时间稍长，内存就开始吃紧，频繁触发 GC，自然会卡。

修改一下bin/studio.vmoptions文件
```
-server
-Xms512m
-Xmx2048m
-XX:MaxPermSize=2048m
-XX:ReservedCodeCacheSize=1024m
```
启动速度快很多

## 快捷键

可以自己改变风格，在File-Settings-Keymap里面有个下拉框选项

想要正确的提示，必须区分大小写

CodeCompletion （代码完成）属性可以快速地在代码中完成各种不同地语句
方法是先键入一个类名地前几个字母然后再用 Ctrl+win+Space 完成全称。如果有多个选项，它们会列在速查列表里。

代码自动对齐
`Ctrl + win + Alt + L`

折叠/展开代码块（Collapse Expand Code Block）
`Cmd + Ctrl + “+”/“-”(Ubuntu)`

隐藏所有面板
`Ctrl + Shift + F12`

界面跳转；可以跳转到代码，或者其他面板
`Ctrl + Tab`

列选择/块选择（Column Selection）
描述：正常选择时，当你向下选择时，会直接将当前行到行尾都选中，而块选择模式下，则是根据鼠标选中的矩形区域来选择。
调用：按住Alt，然后拖动鼠标选择。
开启/关闭块选择：Menu → Edit → Column Selection Mode
快捷键：切换块选择模式：`Cmd + Shift + 8(OS X)`、`Shift + Alt + Insert﻿(Windows/Linux)`

提取方法（Extract Method）
描述：提取一段代码块，生成一个新的方法。当你发现某个方法里面过于复杂，需要将某一段代码提取成单独的方法时，该技巧是很有用的。
调用：Menu → Refactor → Extract → Method
快捷键：`Shift + Alt + M(Windows/Linux)`
更多：在提取代码的对话框，你可以更改方法的修饰符和参数的变量名。

移动方法（Move Methods）
描述：这个操作和移动行操作很类似，不过该操作是应用于整个方法的，在不需要复制、粘贴的情况下，
就可以将整个方法块移动到另一个方法的前面或后面。该操作的实际叫做“移动语句”，这意味着你可以移动任何类型
的语句，你可以方便地调整字段或内部类的顺序。
快捷键：`Cmd + Alt + Up/Down`

重命名
`Alt + Shift + R`

## 设置代理服务器（Proxy）
有时候需要代理来连接服务器
打开 `Android SDK Manager` -> 在`Default Settings`里选择`HTTP Proxy`
点选 `Manual proxy configuration` -> 选择`HTTP`；填写`Host name` 和 `Port number`
以腾讯代理服务器为例，填写如下设置：
```
android-mirror.bugly.qq.com
8080
```
点击OK即可

需要比如更新sdk的时候，打开独立的SDK Manager
在最上方有标题栏`Tools` -> `Options`；填入服务器地址和端口，病勾选`Force https://...`

在AboutView工程中，设置完代理后后弹出错误：Gradle Sync failed while using proxy server
取消代理：在File-Setting-HTTP Proxy-勾选Auto-detect proxy settings
AboutView可正常编译

## 解决Android studio中找不到so文件的问题

>java.lang.UnsatisfiedLinkError

表示我们不编译jni代码，直接从libs里面复制so库  
文件路径：`app\build.gradle`

```
android {
    compileSdkVersion 23
    buildToolsVersion "23.0.3"
    defaultConfig {
        applicationId "com.example.rust"
        minSdkVersion 21
        targetSdkVersion 23
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
    sourceSets {
        main {
            jni.srcDirs = []
            jniLibs.srcDirs = ['libs']// 这是实际路径
        }
    }
}
```

## Android Studio2.1 Run APP时，遇到错误

`Error: Execution failed for task ':app:clean'. Unable to delete file`

关闭AS，kill掉Java进程，打开资源管理器找到相应文件，仍旧无法删除这个文件。下载安装lockhunter，发现是金山杀毒软件占用着。
关闭金山毒霸仍旧无法删除文件，卸载金山毒霸后，可以删除文件。并能正常Run APP。

## `app\build.gradle`文件显示黄色警告，但可正常编译
win7 64，Android Studio2.1

显示黄色警告  
![warning](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Android_note/pics/as_build_waring.png)  
Settings>Build,Execution,Deployment>Build Tools>Gradle里面使用了  
`Use default gradle wrapper(recommennded)`  
![default](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Android_note/pics/as_settings_use_default_gradle.png)  

勾选`Use local gradle distribution`  

![local](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Android_note/pics/as_settings_use_local_gradle.png)  

修改设置后，警告颜色消失。

## Android Studio 自带的截屏和录屏工具
录屏后配合迅雷影音的生成GIF功能，就能很方便地得到GIF图

![rec](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Android_note/pics/as_rec.png)  

## 处理 android studio 卡在 build project info.. 的方法
win7， Android Studio 2.3  
卡在这一步，一般是下载gradle太慢。那么我们去下载gradle的离线包。先关闭AS。  
打开`C:\Users\Administrator\.gradle\wrapper\dists`，可以看到当前正在使用的gradle版本  
假设正在使用`gradle-3.3-all`，进入这个目录可以看到一个文件夹，将下载好的`gradle-3.3-all.zip`
放进去。启动AS即可。

## gradle本地缓存的配置
win7中，gradle默认缓存在C盘当前用户的目录中，例如`C:\Users\Administrator\.gradle`  
可以通过配置系统变量，来改变缓存位置  
如果当前.gradle文件夹已经在C盘，可以将它复制到目标路径，例如`G:\gradleRepo\.gradle`  
在系统变量中增加`GRADLE_USER_HOME`=`G:\gradleRepo\.gradle`

稳妥起见重启计算机即可

