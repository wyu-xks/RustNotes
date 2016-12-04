---
title: H.264相关
date: 2017-12-25 16:12:33
category: multimedia
---

H.264，又称为MPEG-4第10部分，高级视频编码是一种面向块，基于运动补偿的视频编码标准。
到2014年，它已经成为高精度视频录制、压缩和发布的最常用格式之一。

优势：
* 1）网络亲和性，即可适用于各种传输网络
* 2）高的视频压缩比

## 名词解释
### 视频编码层(VCL, Video Coding Layer)
负责有效表示视频数据的内容

### 网络提取层(NAL, Network Abstraction Layer)
负责格式化数据并提供头信息，以保证数据适合各种信道和存储介质上的传输。
以将NAL当成是一个专作封装(packaging)的模块，用来将VCL压缩过的bitstream封装成适当大小的封包单位(NAL-unit)，
并在NAL-unit Header中的NAL-unit Type字段记载此封包的型式，每种型式分别对应到VCL中不同的编解码工具。

### 场和帧
视频的一场或一帧可用来产生一个编码图像。在电视中，为减少大面积闪烁现象，把一帧分成两个隔行的场。

### 宏块
一个编码图像通常划分成若干宏块组成，一个宏块由一个16×16亮度像素和附加的一个8×8 Cb和一个8×8 Cr彩色像素块组成。

### 片（slice）
每个图象中，若干宏块被排列成片的形式。片分为I片、B片、P片和其他一些片。
I片只包含I宏块，P片可包含P和I宏块，而B片可包含B和I宏块。
I宏块利用从当前片中已解码的像素作为参考进行帧内预测。
P宏块利用前面已编码图象作为参考图象进行帧内预测。
B宏块则利用双向的参考图象（前一帧和后一帧）进行帧内预测。

片的目的是为了限制误码的扩散和传输，使编码片相互间是独立的。
某片的预测不能以其它片中的宏块为参考图像，这样某一片中的预测误差才不会传播到其它片中去。

H264结构中，一个视频图像编码后的数据叫做一帧，一帧由一个片（slice）或多个片组成，
一个片由一个或多个宏块（MB）组成，一个宏块由16x16的yuv数据组成。宏块作为H264编码的基本单位。

## H.264码流中SPS PPS
SPS Sequence Paramater Set，又称作序列参数集。
PPS Picture Paramater Set，图像参数集。

在H.264的SPS中，第一个字节表示`profile_idc`,根据`profile_idc`的值可以确定码流符合哪一种档次。

```java
    private static final byte[] SPS = {(byte) 0x00, (byte) 0x00, (byte) 0x01, (byte) 0x67, (byte) 0x4d, (byte) 0x00, (byte) 0x1f, (byte) 0xe5, (byte) 0x40, (byte) 0x28, (byte) 0x02, (byte) 0xd8, (byte) 0x80};
    private static final byte[] PPS = {(byte) 0x00, (byte) 0x00, (byte) 0x01, (byte) 0x68, (byte) 0xee, (byte) 0x31, (byte) 0x12};
```

## 参考
* [H.264码流中SPS PPS详解 - DaveBobo](https://zhuanlan.zhihu.com/p/27896239)
* [H.264先进的视频编译码标准 - CSDN](http://blog.csdn.net/gl1987807/article/details/11945357)
* [RGB、YUV和YCbCr](http://blog.sina.com.cn/s/blog_a85e142101010h8n.html)
* [H264编码总结 - 简书](https://www.jianshu.com/p/0c296b05ef2a)
