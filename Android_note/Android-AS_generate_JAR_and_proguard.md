---
title: Android Studio 模块打包成JAR包并混淆
date: 2016-05-12 15:09:30
category: Android_note
tag: [JAR,Tools]
---

IDE    Android studio 2.1

打包jar与混淆全部在 Android studio 中使用gradle完成。  
混淆的效果并不算太好。后续建议用C++复写算法，打成.so库文件。JNI调用即可。

主要步骤：
* 1.新建library模块，将目标代码装入这个模块
* 2.主模块app添加对新建library模块的依赖，编译整个工程
* 3.library模块中添加gradle任务，打包jar包并混淆

## 详细步骤
在原工程中新建library模块`libmodule`；将要打包的文件都放入这个模块，并编译整个APP，
保证能够正常运行。

修改文件`libmodule\proguard-rules.pro`  
一个是public类，一个是接口；这些都不要混淆，以免找不到文件。
```
-keep public class * extends android.app.Fragment
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference
-keep public class * extends android.support.v4.**

-keep public class * {
    public protected *;
    public interface *;
}
// 保护内部类不被混淆
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,SourceFile,LineNumberTable,*Annotation*,EnclosingMethod
```
给模块的`build.gradle`文件添加任务
```
task jarMyLib(type: Jar, dependsOn: ['build']) {
    archiveName = 'my-lib.jar'// 打出的jar包名字
    from('build/intermediates/classes/release')
    destinationDir = file('build/libs')
    exclude('com/rustfisher/libmodule/BuildConfig.class')
    // 注意这些路径
    // 打jar包的时候，如果class文件不在同一个目录下，需要分别指定它们各自的路径
    exclude('com/rustfisher/libmodule/BuildConfig\$*.class')
    exclude('**/R.class')
    exclude('**/R\$*.class')
    include('com/rustfisher/libmodule/*.class')// 需要打包的class
}

def androidSDKDir = plugins.getPlugin('com.android.library').sdkHandler.getSdkFolder()
def androidJarDir = androidSDKDir.toString() + '/platforms/' + "${android.compileSdkVersion}" + '/android.jar'

task proguardMyLib(type: proguard.gradle.ProGuardTask, dependsOn: ['jarMyLib']) {
    injars('build/libs/my-lib.jar')
    outjars('build/libs/my-pro-lib.jar')// 输出的jar包位置和名字
    libraryjars(androidJarDir)
    configuration 'proguard-rules.pro'// 配置过的混淆文件
}
```
在主模块app的gradle文件中增加对模组的依赖，然后build app，让它编译所有的文件
```
compile project(':libmodule')
```
再去as面板右侧直接执行gradle任务，先执行jarMyLib，后执行proguardMyLib。  
即可在`libmodule\build\libs`下找到混淆过的jar包。  
反编译`my-pro-lib.jar`，可以看到里面的大部分内容都被混淆了。但是接口还在。

### 附录
一个典型的混淆配置文件，来自 http://proguard.sourceforge.net/manual/examples.html#serializable  
这个网站详细解释了proguard。
后续都可以直接使用这个文件。

A typical library  
These options shrink, optimize, and obfuscate an entire library, keeping all public
and protected classes and class members, native method names, and serialization code.
The processed version of the library can then still be used as such, for developing
code based on its public API.
```
-injars       in.jar
-outjars      out.jar
-libraryjars  <java.home>/lib/rt.jar
-printmapping out.map

-keepparameternames
-renamesourcefileattribute SourceFile
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,
                SourceFile,LineNumberTable,*Annotation*,EnclosingMethod

-keep public class * {
    public protected *;
}

-keepclassmembernames class * {
    java.lang.Class class$(java.lang.String);
    java.lang.Class class$(java.lang.String, boolean);
}

-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

-keepclassmembers,allowoptimization enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
```
