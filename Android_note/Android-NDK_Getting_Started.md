---
title: Android NDK 初步
date: 2016-06-14 15:08:16
category: Android_note
tag: [NDK]
toc: true
---

* 开发环境： win7 64，Android Studio 2.1

需要工具：NDK，Cygwin

### 使用 SDK Manager 配置安装 NDK

添加系统环境变量 `G:\SDK\ndk-bundle;G:\SDK\platform-tools`

下载并安装Cygwin：https://cygwin.com/install.html

Cygwin 安装NDK需要的工具包（如果第一次安装时没有选择工具包，可以再次启动安装）：  
make, gcc, gdb, mingw64-x86_64-gcc, binutils
![tools](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Android_note/pics/Cygwin_tools.png)

配置`G:\soft\Cygwin\home\Administrator\.bashrc`，添加下面的指令，使用英文界面。
```
export LANG='en_US'
export LC_ALL='en_US.GBK'
```
配置text选项，在option里的text可设置。  
可以在`G:\soft\Cygwin\home\Administrator\.minttyrc`中看到。

```
Locale=zh_CN
Charset=GBK
```
设置完字体后可以避免中文乱码。

配置 `G:\soft\Cygwin\home\Administrator\.bash_profile`

```
NDK=/cygdrive/G/SDK/ndk-bundle/ndk-build.cmd
export NDK
```

在Cygwin中查找NDK位置，可以看到在SDK目录里面

```bash
Administrator@rust-PC /cygdrive/g/soft/Cygwin/home/Administrator
$ echo $NDK
/cygdrive/G/SDK/ndk-bundle/ndk-build.cmd
```

#### 操作示例NDK工程
生成一次试试。从github上获取android-ndk-android-mk，进入hello-jni工程。

```bash
Administrator@rust-PC /cygdrive/g/rust_proj/android-ndk-android-mk/hello-jni
$ ndk-build.cmd
# 输出很多信息
```

编译成功后，自动生成一个libs目录，编译生成的.so文件放在里面。

```
Administrator@rust-PC /cygdrive/g/rust_proj/NDKTest/app/src/main
$ ndk-build.cmd
[armeabi] Install        : librust_ndk.so => libs/armeabi/librust_ndk.so
# 进入java目录，编译.h文件
Administrator@rust-PC /cygdrive/g/rust_proj/NDKTest/app/src/main/java
$ javah com.rustfisher.ndktest.HelloJNI
# 会生成一个.h文件
```
将它复制到jni文件夹下；这个就是JNI层的代码。

Ubuntu下javah报错。需要添加参数

```
javah -cp /home/rust/Android/Sdk/platforms/android-25/android.jar:. com.example.LibUtil
```

##### 使用C/C++实现JNI

遇到错误： Error:Execution failed for task ':app:compileDebugNdk'.
> Error: NDK integration is deprecated in the current plugin.  Consider trying the new experimental plugin.  For details, see http://tools.android.com/tech-docs/new-build-system/gradle-experimental.  Set "android.useDeprecatedNdk=true" in gradle.properties to continue using the current NDK integration.

解决办法：在`app\build.gradle`文件中添加   
```
    sourceSets.main {
        jniLibs.srcDir 'src/main/libs'
        jni.srcDirs = [] //disable automatic ndk-build call
    }
```

文件有3种：接口文件`.h`； 实现文件`.c`，注意与前面的`.h`文件同名； `.h`与`.c`生成的库文件`.so`

##### 操作步骤小结
From Java to C/C++  
Step 1 定义Java接口文件，里面定义好native方法。   
Step 2 javah生成.h接口文件 。  
Step 3 复制.h文件的文件名，编写C/C++文件。注意要实现.h中的接口。  

### NDK遇到的问题与注意事项

##### 文件关联问题

写cpp源文件的时候，忘记include头文件。产生`java.lang.UnsatisfiedLinkError: No implementation found for` 之类的错误
stackoverflow上有关于`Android NDK C++ JNI (no implementation found for native…)`的问题。

##### NDK本地对象数量溢出问题 `Local ref table overflow `
NDK本地只允许持有512个本地对象，return后会销毁这些对象。必须注意，在循环中创建的本地对象要在使用后销毁掉。

```cpp
env->DeleteLocalRef(local_ref);// local_ref 是本地创建的对象
```

##### 调用Java方法时，注意指定返回值
`env->CallBooleanMethod(resArrayList,arrayList_add, javaObject);` ArrayList的add方法返回Boolean

参考：https://www3.ntu.edu.sg/home/ehchua/programming/java/JavaNativeInterface.html

##### C++调用C方法
C++文件中，需要调用C里面的方法。如果未经任何处理，会出现无引用错误
```
error: undefined reference to '......
```

因此在C++文件中涉及到C方法，需要声明。
例如
```c++
#ifdef __cplusplus
extern "C" {
#include "c_file_header.h"
#ifdef __cplusplus
}
#endif
#endif
// ___ 结束声明
```

javah生成的JNI头文件中也有extern，可作为参考

### NDK中使用logcat
配置：Cygwin， NDK 14.1...  
可以在NDK中使用logcat，方便调试  
需要在mk文件中添加
```
LOCAL_LDLIBS := -L$(SYSROOT)/usr/lib -llog
```

代码中添加头文件，即可调用logcat的方法
```c
#include <android/log.h>
#define LOG_TAG    "rustApp"

__android_log_write(ANDROID_LOG_VERBOSE, LOG_TAG, "My Log");
```

此时编译出现了错误：
```
G:/SDK/ndk-bundle/build//../toolchains/x86_64-4.9/prebuilt/windows-x86_64/lib/gcc/x86_64-linux-android/4.9.x/../../../../x86_64-linux-android/bin\ld: warning: skipping incompatible G:/SDK/ndk-bundle/build//../platforms/android-21/arch-x86_64/usr/lib/libc.a while searching for c
G:/SDK/ndk-bundle/build//../toolchains/x86_64-4.9/prebuilt/windows-x86_64/lib/gcc/x86_64-linux-android/4.9.x/../../../../x86_64-linux-android/bin\ld: error: treating warnings as errors
clang++.exe: error: linker command failed with exit code 1 (use -v to see invocation)
make: *** [G:/openSourceProject/NDKAlgo/app/src/main/obj/local/x86_64/libNDKMan.so] Error 1
```

出现了`error: treating warnings as errors`  
处理方法，在mk文件中添加`LOCAL_DISABLE_FATAL_LINKER_WARNINGS=true`  
再次编译即可

我们可以使用宏定义简化打log的写法
```c
#define LOG_TAG    "rustApp"
#define LOGV(...) __android_log_write(ANDROID_LOG_VERBOSE, LOG_TAG, __VA_ARGS__)
#define LOGD(...) __android_log_print(ANDROID_LOG_DEBUG , LOG_TAG, __VA_ARGS__)  
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO , LOG_TAG, __VA_ARGS__)  
#define LOGW(...) __android_log_print(ANDROID_LOG_WARN , LOG_TAG, __VA_ARGS__)  
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR , LOG_TAG, __VA_ARGS__)  

// 调用
LOGV("This is my log");
```
