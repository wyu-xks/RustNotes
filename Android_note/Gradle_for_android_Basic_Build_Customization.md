---
title: Gradle 基础自定义构建
date: 2017-01-19 20:11:11
category: Android_note
tag: [gradle]
toc: true
---


参考：*Gradle for Android*  Kevin Pelgrims

win7  Android Studio 2.1.3

基础自定义构建 Basic Build Customization

本章目的
* 理解Gradle文件
* build tasks入门
* 自定义构建M

## 理解Gradle文件
在Android Studio中新建一个项目后，会自动创建3个Gradle文件。

```
MyApp
├── build.gradle
├── settings.gradle
└── app
    └── build.gradle
```
每个文件都有自己的作用

### settings.gradle文件
新建工程的settings文件类似下面这样

```
include ':app'
```

Gradle为每个settings文件创建`Settings`对象，并调用其中的方法。

### The top-level build file 最外层的构建文件

能对工程中所有模块进行配置。如下

```
buildscript {
    repositories {
        jcenter()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:2.1.3'

        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}

allprojects {
    repositories {
        jcenter()
        maven { url "https://jitpack.io" }
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
```

`buildscript`代码块是具体配置的地方，引用JCenter仓库。
本例中，一个仓库代表着依赖库，换句话说是app可以从中下载使用库文件。  
JCenter是一个有名的 Maven 仓库。

`dependencies`代码块用来配置依赖。上面注释说明了，不要在此添加依赖，而应该到独立的模块
中去配置依赖。

`allprojects`能对所有模块进行配置。

### 模块中的build文件

模块中的独立配置文件，会覆盖掉top-level的`build.gradle`文件

```
apply plugin: 'com.android.application'

android {
    compileSdkVersion 25
    buildToolsVersion "25.0.2"

    defaultConfig {
        applicationId "com.xxx.rust.newproj"
        minSdkVersion 18
        targetSdkVersion 25
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    testCompile 'junit:junit:4.12'
    compile 'com.android.support:appcompat-v7:25.1.0'
}
```

下面来看3个主要的代码块。

#### plugin

第一行应用了Android 应用插件。Android插件由Google团队开发维护。该插件提供构建，测试，
打包应用和模块需要的所有的task。

#### android

最大的一个区域。defaultConfig区域对app核心进行配置，会配置覆盖AndroidManifest.xml中
的配置。

applicationId复写掉manifest文件中的包名。但applicationId和包名有区别。  
manifest中的包名，在源代码和R文件中使用。所以package name在android studio中理解为一个
查询类的路径比较合理。  
applicationId在Android系统中是作为应用的唯一标识，即在一个Android设备中所有的应用程序的applicationId都是唯一的。

#### dependencies

是Gradle标准配置的一部分。

## 定制化构建 Customizing the build

### BuildConfig and resources

自从SDK17以来，构建工具会生成一个BuildConfig类，包含着静态变量DEBUG和一些信息。  
如果你想在区分debug和正式版，比如打log，这个BuildConfig类很有用。  
可以通过Gradle来扩展这个类，让它拥有更多的静态变量。

以NewProj工程为例，`app\build.gradle`

```
android {
    compileSdkVersion 25
    buildToolsVersion "25.0.2"

    defaultConfig {
        applicationId "com.xxx.rust.newproj"
        minSdkVersion 18
        targetSdkVersion 25
        versionCode 1
        versionName "1.0"
    }
    buildTypes {
        debug {
            buildConfigField("String", "BASE_URL", "\"http://www.baidu.com\"")
            buildConfigField("String", "A_CONTENT", "\"debug content\"")
            resValue("string", "str_version", "debug_ver")
        }
        release {
            buildConfigField("String", "BASE_URL", "\"http://www.qq.com\"")
            buildConfigField("String", "A_CONTENT", "\"release content\"")
            resValue("string", "str_version", "release_ver")

            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

上面的`buildConfigField`和`resValue`在编译后，能在源代码中使用  
注意上面那个转义的分号不可少；注意里面的大小写，这里传入的参数就像是直接填入的代码一样

下面是编译后生成的BuildConfig文件，可以看到buildConfigField的东西已经在里面了

```java
public final class BuildConfig {
  public static final boolean DEBUG = Boolean.parseBoolean("true");
  public static final String APPLICATION_ID = "com.xxx.rust.newproj";
  public static final String BUILD_TYPE = "debug";
  public static final String FLAVOR = "";
  public static final int VERSION_CODE = 1;
  public static final String VERSION_NAME = "1.0";
  // Fields from build type: debug
  public static final String A_CONTENT = "debug content";
  public static final String BASE_URL = "http://www.baidu.com";
}
```

resValue会被添加到资源文件中

```java
mTv2.setText(R.string.str_version);
```

### 通过 build.gradle 增加获取 applicationId 的方式

模块`build.gradle`中添加属性`applicationId`，会被编译到BuildConfig中
```
project.afterEvaluate {
    project.android.applicationVariants.all { variant ->
        def applicationId = [variant.mergedFlavor.applicationId, variant.buildType.applicationIdSuffix].findAll().join()
    }
}
```

在代码中可以直接使用
```java
String appID = BuildConfig.APPLICATION_ID;
```

### 工程范围的设置

如果一个工程中有多个模块，可以对整个工程应用设置，而不用去修改每一个模块。

`NewProj\build.gradle`  
```
allprojects {
    repositories {
        jcenter()
    }
}

ext {
    compileSDKVersion = 25
    local = 'Hello from the top-level build'
}
```

每一个`build.gradle`文件都能定义额外的属性，在ext代码块中。

在一个模块的`libmodule\build.gradle`文件中，可以引用rootProject的ext属性

```
android {
    compileSdkVersion rootProject.ext.compileSDKVersion
    buildToolsVersion "25.0.2"
    // ....
}
```

### 工程属性 Project properties

定义properties的地方
* ext代码块
* gradle.properties文件
* 命令行 -P 参数

工程`build.gradle`文件
```
ext {
    compileSDKVersion = 25
    local = 'Hello from the top-level build'
}

/**
 * Print properties info
 */
task aPrintSomeInfo {
    println(local)
    println('project dir: ' + projectDir)
    println(projectPropertiesFileText)
}

task aPrintAllProperites() {
    println('\nthis is aPrintAllProperites task\n')
    Iterator pIt = properties.iterator()
    while (pIt.hasNext()) {
        println(pIt.next())
    }
}
```

gradle.properties文件中增加
```
projectPropertiesFileText = Hello there from gradle.properties
```

在as的Gradle栏上双击执行aPrintSomeInfo，会连带下一个task也执行

```
13:08:10: Executing external task 'aPrintSomeInfo'...
Hello from the top-level build
project dir: G:\openSourceProject\NewProj
Hello there from gradle.properties

this is aPrintAllProperites task
......
BUILD SUCCESSFUL

Total time: 1.025 secs
13:08:11: External task execution finished 'aPrintSomeInfo'.
```
