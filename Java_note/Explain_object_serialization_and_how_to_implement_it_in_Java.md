---
title: 解释对象的序列化，Java中的序列化
date: 2015-07-24 22:11:39
category: Java_note
tag: [Java]
toc: true
---


## Serialization 序列化
在计算机科学的数据存储方面，序列化是将数据结构或对象状态转换为一种可存储格式，并能在同样电脑环境中复原的的操作。
可存储格式比如文件，字节流，或能通过网络连接传输的格式。
根据序列化的规则，重新读取序列化后的字符串，能够重新创建出与原来一样的对象。比如扩展引用这样的复杂对象，
并不能直接进行序列化操作。对象的序列化并不包含原先任何相关的方法。

## Serialization in Java
JAVA中实现序列化的两个类：ObjectOuputStream 和 ObjectInputStream
这两个类都是装饰者（decorator）模式的，在创建他们的时候，都要传入一个基于字节的流。真正在底下存贮序列化数
据的都是这些流。JAVA IO系统里的 OutputStream 和 InputStream 的子类。可以像操作一般的流一样来操作他们。
被持久化的类要实现 Serializable 接口，这是标记接口，没有任何函数。在这个类里面要定义 serialVersionUID
```java
import com.rust.utils.BasePaper;

import java.io.*;

/**
 * Learn serialization in Java
 * Must implements Serializable and define serialVersionUID
 */
public class JavaSerialization extends BasePaper implements Serializable {
    private static final long serialVersionUID = -1874850715617681161L;
    private int type;
    private String name;

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public JavaSerialization(int type, String name) {
        this.type = type;
        this.name = name;
    }

    public static void main(String[] args) throws ClassNotFoundException {
        try {
            // serialize the object
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(bos);
            oos.writeObject(new JavaSerialization(1, "Jack"));

            // read the serialization result
            // DO NOT USE toString() to get ByteArray
            ByteArrayInputStream bis = new ByteArrayInputStream(bos.toByteArray());
            ObjectInputStream ois = new ObjectInputStream(bis);
            JavaSerialization serialRes = (JavaSerialization) ois.readObject();
            outputln("name " + serialRes.getName() + "; type " + serialRes.getType());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```
输出：
```
name Jack; type 1
```
