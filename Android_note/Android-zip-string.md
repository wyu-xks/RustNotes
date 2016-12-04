---
title: Android 压缩字符串
date: 2017-08-09 21:10:47
category: Android_note
toc: true
---

Android端可以对字符串进行压缩。  
在进行大量简单文本传输时，可以先压缩字符串再发送。接收端接收后再解压。  
也可以将字符串压缩后存入数据库中。

使用到的类库
* GZIPOutputStream

### 代码示例

```java
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;

public class StrZipUtil {

    /**
     * @param input 需要压缩的字符串
     * @return 压缩后的字符串
     * @throws IOException IO
     */
    public static String compress(String input) throws IOException {
        if (input == null || input.length() == 0) {
            return input;
        }
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        GZIPOutputStream gzipOs = new GZIPOutputStream(out);
        gzipOs.write(input.getBytes());
        gzipOs.close();
        return out.toString("ISO-8859-1");
    }

    /**
     * @param zippedStr 压缩后的字符串
     * @return 解压缩后的
     * @throws IOException IO
     */
    public static String uncompress(String zippedStr) throws IOException {
        if (zippedStr == null || zippedStr.length() == 0) {
            return zippedStr;
        }
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ByteArrayInputStream in = new ByteArrayInputStream(zippedStr
                .getBytes("ISO-8859-1"));
        GZIPInputStream gzipIs = new GZIPInputStream(in);
        byte[] buffer = new byte[256];
        int n;
        while ((n = gzipIs.read(buffer)) >= 0) {
            out.write(buffer, 0, n);
        }
        // toString()使用平台默认编码，也可以显式的指定如toString("GBK")
        return out.toString();
    }
}
```

红米手机测试输出
```
08-09 13:16:53.388 32248-32267/com.rustfisher.ndkproj D/rustApp: 开始存入数据库 ori1 len=304304
08-09 13:16:53.418 32248-32267/com.rustfisher.ndkproj D/rustApp: 已存入数据库  ori1 len=304304 , 耗时约37 ms
08-09 13:16:53.418 32248-32267/com.rustfisher.ndkproj D/rustApp: 开始压缩  ori1 len=304304
08-09 13:16:53.438 32248-32267/com.rustfisher.ndkproj D/rustApp: 压缩完毕  zip1 len=1112 , 耗时约19 ms
08-09 13:16:53.438 32248-32267/com.rustfisher.ndkproj D/rustApp: 存压缩后的数据进数据库 zip1.length=1112
08-09 13:16:53.448 32248-32267/com.rustfisher.ndkproj D/rustApp: 压缩后的数据已进数据库 zip1.length=1112 , 耗时约8 ms
08-09 13:16:53.448 32248-32267/com.rustfisher.ndkproj D/rustApp: 解压开始
08-09 13:16:53.488 32248-32267/com.rustfisher.ndkproj D/rustApp: 解压完毕 耗时约36 ms
```
存储时间受存储字符串的长度影响。字符串长度与存储耗时正相关。   


荣耀手机测试
```
08-09 10:38:42.759 23075-23109/com.rustfisher D/rustApp: 开始压缩  ori1 len=304304
08-09 10:38:42.764 23075-23109/com.rustfisher D/rustApp: 压缩完毕  zip1 len=1112
08-09 10:38:42.764 23075-23109/com.rustfisher D/rustApp: 解压开始
08-09 10:38:42.789 23075-23109/com.rustfisher D/rustApp: 解压完毕 
```
此例中，荣耀压缩耗时约5ms，解压耗时约25ms。  

可以看出，压缩后与原长度之比 1112/304304， 约0.365%  
压缩和解压缩耗时视手机情况而定。
