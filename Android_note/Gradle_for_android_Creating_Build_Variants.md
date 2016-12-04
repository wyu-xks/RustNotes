---
title: Gradle 构建多种版本
date: 2017-01-19 20:31:11
category: Android_note
tag: [gradle]
toc: true
---

参考：*Gradle for Android*  Kevin Pelgrims

本章目的
* Build types 构建类型
*	Product flavors
*	Build variants 构建不同种类
* Signing configurations

开发APP时，会有生成不同版本的需求。比如测试版本和发布版本。不同版本之间通常有不同的设置。

## Build types
定义APP或者模块该被如何构建。

可以用`buildTypes`来定义构建类型。例如：
```
buildTypes {
    release {
        minifyEnabled false
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

默认的`build.gradle`文件会包含一个`release`构建类型

### 创建构建类型
比如创建一个`staging`构建类型
```
buildTypes {
    // staging 是一个自定义名字
    // 生成signed App时可以选择这个类型
    staging.initWith(buildTypes.debug)
    staging {
        applicationIdSuffix ".staging"
        versionNameSuffix "-staging"
        buildConfigField("String", "BASE_URL", "\"http://www.staging.com\"")
    }
}
```
这里定义了`applicationIdSuffix`，让staging版本的applicationId和release版本的不同。

`initWith()`创建一个新的构建类型并复制现有的构建类型。用这个方法可以复写已有的构建类型。

### 资源目录
创建了新的构建类型后，可以建立新的资源文件。例如我们已经有了staging构建类型

```
src
├── androidTest
├── debug
├── greenRelease
├── main
├── redDebug
├── staging// 可以新建资源目录
└── test
```

不同资源目录里的文件可以用相同的文件名。

main目录里的strings.xml
```
<resources>
    <string name="app_name">GDemo</string>
</resources>
```

```
<resources>
    <!-- staging strings.xml -->
    <string name="app_name">GStaging</string>
</resources>
```

生成不同版本的app时，会自动去找相应的资源文件

### 依赖包管理
每一种构建类型可以有自己的依赖。Gradle自动为每个类型创建依赖配置。  
下面就是单独为debug版本添加logging模块的依赖

```
dependencies {
    compile fileTree(dir: 'libs', include: ['*.jar'])
    androidTestCompile('com.android.support.test.espresso:espresso-core:2.2.2', {
        exclude group: 'com.android.support', module: 'support-annotations'
    })
    compile 'com.android.support:appcompat-v7:25.1.1'
    testCompile 'junit:junit:4.12'

    debugCompile 'de.mindpipe.android:android-logging-log4j:1.0.3'
}
```

## Product flavors 产品特征
product flavors用于创建同一个APP的不同版本。最直接的例子就是免费和付费版APP。

当我们要发布APP时，可以选择release或者staging（上面的例子）版。但是对同一个构建类型，比如对
于release版，我们可以用Product flavors打包出有各自特征的APP。比如：

```
// 多渠道打包可以用在这里配置
// 一旦配置了productFlavors，生成apk时会默认选其中一个选项
productFlavors {
    red {
        versionName "1.0-red"
    }
    green {
        applicationId "com.rustfisher.gradletest.green" // 使用另一个签名
        versionNameSuffix "-green"// 版本名添加后缀
    }
}
```

### 资源文件
新建了productFlavors类型后，我们可以新建相应的资源目录。

```
src
├── androidTest
├── debug
├── greenRelease // release版本  采用green
├── main
├── redDebug // debug版本   采用red
├── staging
└── test
```
### 多种特种的变量 Multiflavor variants
在Product flavors中可以进行组合，例如

```
android {

    flavorDimensions("color", "price") // 新建了2种类型

    // 多渠道打包可以用在这里配置
    // 一旦配置了productFlavors，debug时会默认选一个选项
    productFlavors {
        red {
            versionName "1.0-red"
            dimension "color"
        }
        green {
            applicationId "com.rustfisher.gradletest.green" // 使用另一个签名
            versionNameSuffix "-green"
            dimension "color"
        }
        freeApp {
            dimension "price"
        }
        paidApp {
            dimension "price"
        }
    }
}
```

那么在打包apk时，可以有如下4种版本  

```
green-freeApp 
green-paidApp 
red-freeApp 
red-paidApp
```
一旦添加flavorDimensions，就必须为每一个flavor制定dimension。  
就像上面的`color`和`price`必须出现在下面4种productFlavors之中。否则会报错。

## Build Variants
Android Studio左下角可以打开Build Variants窗口。选择模块和`Build Variants`。
前面配置的构建类型都会在这个列表中出现。

### Tasks 任务
Android plugin for Gradle 会自动为每个配置的构建类型创建任务。  
新建项目时，会有默认的assembleDebug 和 assembleRelease。  
经过上面的配置以后，会有产生相对应的任务
```
assemble
assembleAndroidTest
assembleDebug
assembleFreeApp
assembleGreen
assembleGreenFreeApp
assembleGreenPaidApp
assemblePaidApp
assembleRed
assembleRedFreeApp
assembleRedPaidApp
assembleRelease
assembleStaging
```

### Resource and manifest merging
Android的Gradle插件会在打包app前将主要资源和构建类型资源合在一起。另外，lib工程也可以提供
额外可被合并的资源文件。manifest文件也可被合并。比如在debug版本中申请正式版中不需要的权限。

### 定义构建变量
给productFlavors中的类型添加资源

```
productFlavors {
    red {
        versionName "1.0-red"
        dimension "color"
        resValue("color", "flavor_color", "#ff0000")
    }
    green {
        applicationId "com.rustfisher.gradletest.green" // 使用另一个签名
        versionNameSuffix "-green"
        resValue("color", "flavor_color", "#00ff00")
        dimension "color"
    }
// ...
}
```

上面的flavor_color可以在代码中通过R文件找到`R.color.flavor_color`
