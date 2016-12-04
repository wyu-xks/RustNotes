---
title: Gradle for Android 开始
date: 2017-01-19 19:01:15
category: Android_note
tag: [gradle]
toc: true
---


参考：*Gradle for Android*  Kevin Pelgrims

# Gradle for Android开始

Google在Gradle中的目标：能复用代码，创建构建变量，能配置和定制构建过程。

## Gradle基础

Gradle构建脚本并不是用XML来写的，而是基于Groovy的一种（domain-specifc language）
DSL语言。这是一种运行在JVM上的动态语言。

如果要构建新的任务和插件，我们需要了解这门语言。

## Projects and tasks
这是Gradle种最重要的两个概念。每个构建（build）至少包含一个project，每一个project包含
一个或多个task。每个`build.gradle`代表一个project。task被定义在这个构建脚本中。
一个task对象包含一列需要被执行的Action对象。一个Action对象就是一块被执行的代码，就像
Java中的方法。

当初始化构建进程时，Gradle收集build文件中的project和task对象。

## 构建的生命周期（The build lifecycle）
为简化构建过程，构建工具创造了一种工作流的动态模型DAG（Directed Acyclic Graph）。  
这意味着所有的任务会一个接一个地执行，不会出现循环的情况。  
一个任务一旦被执行就不会再被调用。没有依赖的任务永远是最优先执行的。  
在配置过程中生成依赖关系。

一个Gradle构建过程有3个步骤：
* 初始化：工程实例被创建时初始化。如果有多个模块，每个模块有自己的`build.gradle`文件，
多个project被创建。
* 配置：这一步执行build脚本，创建并配置每个project的task。
* 执行：Gradle决定执行那些任务。根据当前目录和传入参数执行task。

## build配置文件
`build.gradle`文件。配置build的地方。

```
buildscript {
    repositories {
        jcenter()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:2.2.2'
    }
}
```

repositories块中，指定JCenter作为依赖仓库。  
这个脚本获取了Android构建工具。这个Android插件提供了构建和测试应用所需的功能。

插件被用来扩展Gradle构建脚本的功能。在project中使用插件，就可以定义属性和任务。

## Gradle Wrapper初步
Gradle是一个开发中的工具。使用Gradle Wrapper可以避免一些问题，确保能构建顺利。  
Gradle在Windows系统上提供了batch文件，在其他系统上提供了shell脚本。试图运行脚本时，会
自动检查并下载Gradle。但在我们的网络比较令人着急。可以尝试在网络上找资源。

比如我下载了一个`gradle-2.14.1-all.zip`，将其放到Android工程的gradle/wrapper下

```
gradle
`-- wrapper
    |-- gradle-2.14.1-all.zip
    |-- gradle-wrapper.jar
    `-- gradle-wrapper.properties
```

然后修改`gradle-wrapper.properties`文件，把Url修改成
`distributionUrl=gradle-2.14.1-all.zip`

在Android Studio提供的Terminal中运行`grawdlew`，先unzipping，然后开始下载依赖文件。
这些文件在windows中默认存放到
`C:\Users\UserName\.gradle\wrapper\dists\gradle-2.14.1-all`，还是很占空间的。  
此时你可以在项目下的命令行中使用grawdlew命令。比如查看版本。

```
G:\rust_proj\NDKProj>gradlew -v

------------------------------------------------------------
Gradle 2.14.1
------------------------------------------------------------

Build time:   2016-07-18 06:38:37 UTC
Revision:     d9e2113d9fb05a5caabba61798bdb8dfdca83719

Groovy:       2.4.4
Ant:          Apache Ant(TM) version 1.9.6 compiled on June 29 2015
JVM:          1.8.0_77 (Oracle Corporation 25.77-b03)
OS:           Windows 7 6.1 amd64
```

如果在另一个Android项目下同样复制了`gradle-2.14.1-all.zip`，并且尝试运行gradlew，
C盘里相应目录下又会多一个文件夹。

## 获取Gradle Wrapper
打开Windows CMD，进入前面配置好的Android工程目录，同样可以运行gradlew。

此时我们的C盘里已经有`gradle-2.14.1-all.zip`了。找到`gradle.bat`的路径，将其添加到
电脑PATH中。这里添加到用户的环境变量中。

在G盘新建一个目录`gradleTest`，然后创建一个`build.gradle`文件；其中填写如下代码

```
task wrapper(type: Wrapper) {
    gradleVersion = '2.4'
}
```

进入刚才的目录，在CMD中直接运行gradle

```
G:\gradleTest>gradle
:help
Welcome to Gradle 2.14.1.
To run a build, run gradle <task> ...
To see a list of available tasks, run gradle tasks
To see a list of command-line options, run gradle --help
To see more detail about a task, run gradle help --task <task>
BUILD SUCCESSFUL
Total time: 1.714 secs
```

此时目录下生成了一个`.gradle`目录

如果当前目录下没有`build.gradle`文件，gradle也会执行并生成`.gradle`目录。

我们来观察Android项目里Gradle Wrapper的情况
```
NDKProj/
├── gradlew
├── gradlew.bat
└── gradle/wrapper/
    ├── gradle-wrapper.jar
    └── gradle-wrapper.properties
```
Gradle Wrapper包含3个部分：
* MS可执行的gradlew.bat和Linux， Mac OS X可执行的gradlew
* 脚本需要的Jar文件
* 一个properties文件

在前面我们已经把properties文件修改成了这样：
```
#Mon Aug 29 19:26:36 CST 2016
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=gradle-2.14.1-all.zip
```

原distributionUrl如下：
```
distributionUrl=https\://services.gradle.org/distributions/gradle-2.14.1-all.zip
```

这意味着我们可以使用不同的URL和Gradle。我们前面已经这么做了。

## 运行基本的构建任务（task）
进入Android工程目录下，用命令行执行gradlew
`gradlew tasks`会打印出任务列表；`gradlew tasks --all`打印出所有的任务

`gradlew assembleDebug`编译当前项目，创建一个debug版本的apk

`gradlew clean`清理当前项目的output

`gradlew check`运行所有的检查，通常是在真机或者模拟器上运行测试

`gradlew build`触发assemble 和 check

这些功能在Android Studio上都有相应按键

