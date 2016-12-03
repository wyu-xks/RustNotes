---
title: 导入原Eclipse工程到Android Studio中
date: 2016-07-26 22:02:16
category: Android_note
tag: [Tools,AndroidStudio]
---

原工程中有2个模块，一个主一个副。导入AS时遇到很多问题。

导入AS时，选择导入主工程，依赖的模块会自动导入进来。

### 打包apk时报错
>Duplicate files copied in APK

根据提示，在主模块的build.gradle文件添加：

```
android {
    compileSdkVersion 17
    buildToolsVersion "24.0.0"
// ........
    // Must to ignore these files
    packagingOptions {
        exclude 'AndroidManifest.xml'
        exclude 'res/layout/main.xml'
    }
}
```

### merge manifest 出现错误
一定要看错误提示，看看是什么标签重复了。

```
Error:Execution failed for task ':XXXX:processDebugManifest'.
> Manifest merger failed with multiple errors, see logs
```

根据错误提示，在manifest里面添加相应标签即可，例如：

```xml
  tools:replace="android:icon,android:label,android:theme"
```

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="xxx.xxx.xxx">

    <uses-sdk android:minSdkVersion="10" />

    <application
        android:label="@string/app_name"
        tools:replace="android:label">

    </application>
// .....
</manifest>
```
像上面的代码里是label和主工程的重复了，所以replace指定label即可。
