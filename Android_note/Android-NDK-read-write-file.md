---
title: Android NDK 读写文件
date: 2017-03-16 21:01:11
category: Android_note
tag: [NDK]
toc: true
---

开发环境： win7 64，Android Studio 2.2.3, Cygwin

使用NDK，就进入了Linux的世界。理解了这一点，很多事情就好办了。  
在这里吃的亏是C语言操作文件不熟练，耗费了很多时间。

## 准备事项
### 申请权限
申请SD卡的读写权限
```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### 使用Linux中的文件绝对路径
手机sd卡中存放着文件。目录为 `/sdcard/hello.txt` ； `/sdcard/egdir/csv/eg_data.csv`

## 读写示例1

```
jni/
|-- Android.mk
|-- com_rustfisher_ndkalgo_RWFile.h
`-- RWFile.c
```

`RWFile.java`

```java
public class RWFile {

    static {
        System.loadLibrary("NDKMan");
    }

    public String readIn() {
        return nativeRead();
    }

    public String writeToFile(String msg) {
        return nativeWrite(msg);
    }

    public String readSDFile(String fileName) {
        return nativeReadSDFile(fileName);
    }

    private native String nativeRead();

    /**
     * @param fileName e.g. FolderName/textFile.txt
     */
    private native String nativeReadSDFile(String fileName);

    private native String nativeWrite(String msg);
}
```

`RWFile.c`中的方法

```
void join(char *s1, char *s2,char *result)  // 拼接char的函数
Java_com_rustfisher_ndkalgo_RWFile_nativeRead // 读取固定文件的内容
Java_com_rustfisher_ndkalgo_RWFile_nativeReadSDFile // 根据文件名读取文件内容
Java_com_rustfisher_ndkalgo_RWFile_nativeWrite // 将内容写入文件
```

`RWFile.c` 代码如下  

```c
#include <stdio.h>
#include <stdlib.h>

#include "com_rustfisher_ndkalgo_RWFile.h"

const char *sdcardDir = "/sdcard/";

void join(char *s1, char *s2,char *result) {
    result = (char *) malloc(strlen(s1)+strlen(s2)+1);// +1 for the zero-terminator
    if (result == NULL) {
        return;
    }
    strcpy(result, s1);
    strcat(result, s2);
}

JNIEXPORT jstring JNICALL Java_com_rustfisher_ndkalgo_RWFile_nativeRead
(JNIEnv *env, jobject jObj) {
    FILE* file = fopen("/sdcard/hello.txt","r+");
    char myStr[128];
    if (file != NULL) {
        char* readInPtr = fgets(myStr, 128, file);
        fclose(file);
        if (NULL != readInPtr) {
            return (*env)->NewStringUTF(env, myStr);
        }
        return (*env)->NewStringUTF(env, "JNI read file fail!");
    }
    return (*env)->NewStringUTF(env, "JNI read file fail!");
}

JNIEXPORT jstring JNICALL Java_com_rustfisher_ndkalgo_RWFile_nativeReadSDFile
(JNIEnv *env, jobject jObj, jstring fileName) {
    char *fileNamePtr = (*env)->GetStringUTFChars(env, fileName, 0);
    char * result;
    join(sdcardDir,fileNamePtr,result);

    FILE* file = fopen(result,"r+");

    if (file != NULL) {
        char myStr[128];
        char* readInPtr = fgets(myStr, 128, file);
        fclose(file);
        if (NULL != readInPtr) {
            return (*env)->NewStringUTF(env, myStr);
        }
        return (*env)->NewStringUTF(env, "JNI read fail - NULL == readInPtr");
    }
    return (*env)->NewStringUTF(env, "JNI read file fail! - file is NULL ");
}


JNIEXPORT jstring JNICALL Java_com_rustfisher_ndkalgo_RWFile_nativeWrite
(JNIEnv *env, jobject jObj, jstring msg) {

    FILE* file = fopen("/sdcard/hello.txt","w+");
    const char *nativeMsg = (*env)->GetStringUTFChars(env, msg, 0);

    if (file != NULL) {
        fputs(nativeMsg, file);
        fflush(file);
        fclose(file);
    }

    return (*env)->NewStringUTF(env, "Write finished.");
}

```

## 需关注的函数
要特别关心函数的返回值，返回值往往代表着调用的结果。

### 打开文件 fopen
`FILE * fopen(const char * path,const char * mode);`  
mode模式选择，例如`"r"`  
* r(read): 读
* w(write): 写
* a(append): 追加
* t(text): 文本文件，可省略不写
* b(banary): 二进制文件
* +: 读和写

凡用“r”打开一个文件时，该文件必须已经存在，且只能从该文件读出。

用“w”打开的文件只能向该文件写入。若打开的文件不存在，则以指定的文件名建立该文件，若打开的文件已
经存在，则将该文件删去，重建一个新文件。这个方法保证目标文件里写入的只有我们要的数据。

若要向一个已存在的文件追加新的信息，只能用“a”方式打开文件。但此时该文件必须是存在的，否则将会出错。

在打开一个文件时，如果出错，fopen将返回一个空指针值NULL。在程序中可以用这一信息来判别是否完成
打开文件的工作，并作相应的处理。

如果成功的打开一个文件, fopen()函数返回文件指针, 否则返回空指针

### 从文件中读取数据 fgets
`char *fgets(char *s, int n, FILE *stream);`  
从文件指针stream中读取n-1个字符，存到以s为起始地址的空间里，直到读完一行，如果成功则返回s的指
针，否则返回NULL。

### NDK中生成jstring的函数  `(*env)->NewStringUTF(env, char *);`
`(*env)->NewStringUTF(env, char *);`  
如果传入的char*是一个空值，在一些平台上会报错。  
比如红米手机会直接崩溃，而魅族手机能得到一个空的String。

## 不写文件而持久化数据的方式
可以主动序列化一个对象。例如把数据全部转成byte数组，返回给Java层。  
调用native方法时将这个数组传进去。
