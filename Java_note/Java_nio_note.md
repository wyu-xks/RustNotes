---
title: Java nio 小记
date: 2018-01-15 21:00:30
category: Java_note
tag: [Java]
---

Java SE 1.4引入了大量用于改进输入输出处理机制的特性。位于java.nio包中。

内存映射文件
大多数操作系统都可以利用虚拟内存实现来将一个文件或文件的一部分“映射”到内存中。
然后这个文件就可以当做是内存数组一样访问，这比传统的文件操作要快的多。

通道（channel）：通道是用于磁盘文件的一种抽象，它使我们可以访问诸如内存映射、文件加锁机制
以及文件间快速数据传递等操作系统特性。

在实践中，常用ByteBuffer和CharBuffer。每个缓冲区都具有：
* 一个容量，它永远不能改变
* 一个读写位置，下一个值将在此进行读写
* 一个界限，超过它进行读写是没有意义的
* 一个可选的标记，用于重复一个读入或写出操作
这些值满足以下条件：  
0 <= 标记 <= 位置 <= 界限 <= 容量

使用缓冲区的主要目的是循环执行“写，然后读入”。

```java
    public static void main(String[] args) {
        byte[] input = {1, 2, 3, 4, 5, 0, -5, -6, -7, -8, -9};
        printlnByteArr(input);
        ByteBuffer bBuffer = ByteBuffer.wrap(input);
        System.out.println(bBuffer);
        bBuffer.array();
        printlnByteArr(bBuffer.array());
        printlnByteArr(bBuffer.array());
    }

    private static void printlnByteArr(byte[] bytes) {
        for (byte b : bytes) {
            System.out.print(Integer.toHexString(b) + " ");
        }
        System.out.println();
    }
/** output
1 2 3 4 5 0 fffffffb fffffffa fffffff9 fffffff8 fffffff7 
java.nio.HeapByteBuffer[pos=0 lim=11 cap=11]
1 2 3 4 5 0 fffffffb fffffffa fffffff9 fffffff8 fffffff7 
1 2 3 4 5 0 fffffffb fffffffa fffffff9 fffffff8 fffffff7 
*/
```

一个复制bytebuffer的方法
```java
    private static ByteBuffer byteBufferClone(ByteBuffer buffer) {
        //assert buffer != null;

        if (buffer.remaining() == 0)
            return ByteBuffer.wrap(new byte[]{0});

        ByteBuffer clone = ByteBuffer.allocate(buffer.remaining());

        if (buffer.hasArray()) {
            System.arraycopy(buffer.array(), buffer.arrayOffset() + buffer.position(), clone.array(), 0, buffer.remaining());
        } else {
            clone.put(buffer.duplicate());
            clone.flip();
        }

        return clone;
    }
```
