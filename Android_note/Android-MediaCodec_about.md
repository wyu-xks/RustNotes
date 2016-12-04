---
title: Android 编解码 MediaCodec, Image
date: 2017-12-20 20:59:14
category: Android_note
---


## Android MediaCodec 使用方式
使用MediaCodec进行编解码。输入H.264格式的数据，输出帧数据并发送给监听器。  

#### H.264的配置
创建并配置codec。配置codec时，若手动创建MediaFormat对象的话，一定要记得**设置"csd-0"和"csd-1"这两个参数**。  
"csd-0"和"csd-1"这两个参数一定要和接收到的帧对应上。  

#### 输入数据
给codec输入数据时，如果对输入数据进行排队，需要检查排队队列的情况。  
例如一帧数据暂用1M内存，1秒30帧，排队队列有可能会暂用30M的内存。当内存暂用过高，我们需要采取一定的措施来减小内存占用。  
codec硬解码时会受到手机硬件的影响。若手机性能不佳，编解码的速度有可能慢于原始数据输入。不得已的情况我们可以将排队中的旧数据抛弃，输入新数据。  

#### 解码器性能
对视频实时性要求高的场景，codec没有可用的输入缓冲区，`mCodec.dequeueInputBuffer`返回-1。  
为了实时性，这里会强制释放掉输入输出缓冲区`mCodec.flush()`。  

#### 问题1 - MediaCodec输入数据和输出数据数量之间有没有特定的关系
对于MediaCodec，输入数据和输出数据数量之间有没有特定的关系？假设输入10帧的数据，可以得到多少次输出？

实测发现，不能百分百保证输入输出次数是相等的。例如vivo x6 plus，输入30帧，能得到28帧结果。或者300次输入，得到298次输出。

#### 异常1 - dequeueInputBuffer(0)一直返回-1
某些手机长时间编解码后，可能会出现尝试获取codec输入缓冲区时下标一直返回-1。
例如vivo x6 plus，运行约20分钟后，`mCodec.dequeueInputBuffer(0)`一直返回-1。

处理方法：如果一直返回-1，同步方式下尝试调用`codec.flush()`方法，异步方式下尝试`codec.flush()`后再调用`codec.start()`方法。

有一些手机解码速度太慢，有可能会经常返回-1。不要频繁调用`codec.flush()`，以免显示不正常。

### 代码示例 - 同步方式进行编解码
这一个例子使用同步方式进行编解码
```java
/**
 * 解码器
 */
public class CodecDecoder {
    private static final String TAG = "CodecDecoder";

    private static final String MIME_TYPE = "video/avc";
    private static final String CSD0 = "csd-0";
    private static final String CSD1 = "csd-1";

    private static final int TIME_INTERNAL = 1;
    private static final int DECODER_TIME_INTERNAL = 1;

    private MediaCodec mCodec;
    private long mCount = 0; // 媒体解码器MediaCodec用的

    // 送入编解码器前的缓冲队列
    // 需要实时监控这个队列所暂用的内存情况  在这里堵塞的话很容易引起OOM
    private Queue<byte[]> data = null;

    private DecoderThread decoderThread;
    private CodecListener listener; // 自定义的监听器  当解码得到帧数据时通过它发送出去

    public CodecDecoder() {
        data = new ConcurrentLinkedQueue<>();
    }

    public boolean isCodecCreated() {
        return mCodec!=null;
    }

    public boolean createCodec(CodecListener listener, byte[] spsBuffer, byte[] ppsBuffer, int width, int height) {
        this.listener = listener;
        try {
            mCodec = MediaCodec.createDecoderByType(Constants.MIME_TYPE);
            MediaFormat mediaFormat = createVideoFormat(spsBuffer, ppsBuffer, width, height);
            mCodec.configure(mediaFormat, null, null, 0);
            mCodec.start();

            Log.d(TAG, "decoderThread mediaFormat in:" + mediaFormat);

            decoderThread = new DecoderThread();
            decoderThread.start();

            return true;
        }
        catch (Exception e) {
            e.printStackTrace();
            Log.e(TAG, "MediaCodec create error:" + e.getMessage());

            return false;
        }
    }

    private MediaFormat createVideoFormat(byte[] spsBuffer, byte[] ppsBuffer, int width, int height) {
        MediaFormat mediaFormat;
        mediaFormat = MediaFormat.createVideoFormat(MIME_TYPE, width, height);
        mediaFormat.setByteBuffer(CSD0, ByteBuffer.wrap(spsBuffer));
        mediaFormat.setByteBuffer(CSD1, ByteBuffer.wrap(ppsBuffer));
        mediaFormat.setInteger(MediaFormat.KEY_COLOR_FORMAT,
                MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible);

        return mediaFormat;
    }

    private long lastInQueueTime = 0;

    // 输入H.264帧数据  这里会监控排队情况
    public void addData(byte[] dataBuffer) {
        final long timeDiff = System.currentTimeMillis() - lastInQueueTime;
        if (timeDiff > 1) {
            lastInQueueTime = System.currentTimeMillis();
            int queueSize = data.size(); // ConcurrentLinkedQueue查询长度时会遍历一次 在数据量巨大的情况下尽量少用这个方法
            if (queueSize > 30) {
                data.clear();
                LogInFile.getLogger().e("frame queue 帧数据队列超出上限，自动清除数据 " + queueSize);
            }
            data.add(dataBuffer.clone());
            Log.e(TAG, "frame queue 添加一帧数据");
        } else {
            LogInFile.getLogger().e("frame queue 添加速度太快,跳过此帧. timeDiff=" + timeDiff);
        }
    }

    public void destroyCodec() {
        if (mCodec != null) {
            try {
                mCount = 0;

                if(data!=null) {
                    data.clear();
                    data = null;
                }

                if(decoderThread!=null) {
                    decoderThread.stopThread();
                    decoderThread = null;
                }

                mCodec.release();
                mCodec = null;
            }
            catch (Exception e) {
                e.printStackTrace();
                Log.d(TAG, "destroyCodec exception:" + e.toString());
            }
        }
    }

    private class DecoderThread extends Thread {
        private final int INPUT_BUFFER_FULL_COUNT_MAX = 50;
        private boolean isRunning;
        private int inputBufferFullCount = 0; // 输入缓冲区满了多少次

        public void stopThread() {
            isRunning = false;
        }

        @Override
        public void run() {
            setName("CodecDecoder_DecoderThread-" + getId());
            isRunning = true;
            while (isRunning) {
                try {
                    if (data != null && !data.isEmpty()) {
                        int inputBufferIndex = mCodec.dequeueInputBuffer(0);
                        if (inputBufferIndex >= 0) {
                            byte[] buf = data.poll();
                            ByteBuffer inputBuffer = mCodec.getInputBuffer(inputBufferIndex);
                            if (null != inputBuffer) {
                                inputBuffer.clear();
                                inputBuffer.put(buf, 0, buf.length);
                                mCodec.queueInputBuffer(inputBufferIndex, 0,
                                        buf.length, mCount * TIME_INTERNAL, 0);
                                mCount++;
                            }
                            inputBufferFullCount = 0; // 还有缓冲区可以用的时候重置计数
                        } else {
                            inputBufferFullCount++;
                            LogInFile.getLogger().e(TAG, "decoderThread inputBuffer full.  inputBufferFullCount=" + inputBufferFullCount);
                            if (inputBufferFullCount > INPUT_BUFFER_FULL_COUNT_MAX) {
                                mCount = 0;
                                mCodec.flush(); // 在这里清除所有缓冲区
                                LogInFile.getLogger().e(TAG, "mCodec.flush()...");
                            }
                        }
                    }

                    // Get output buffer index
                    MediaCodec.BufferInfo bufferInfo = new MediaCodec.BufferInfo();
                    int outputBufferIndex = mCodec.dequeueOutputBuffer(bufferInfo, 0);
                    while (outputBufferIndex >= 0) {
                        final int index = outputBufferIndex;
                        Log.d(TAG, "releaseOutputBuffer " + Thread.currentThread().toString());
                        final ByteBuffer outputBuffer = byteBufferClone(mCodec.getOutputBuffer(index));
                        Image image = mCodec.getOutputImage(index);
                        if (null != image) {
                            // 获取NV21格式的数据
                            final byte[] nv21 = ImageUtil.getDataFromImage(image, FaceDetectUtil.COLOR_FormatNV21);
                            final int imageWid = image.getWidth();
                            final int imageHei = image.getHeight();
                            // 这里选择创建新的线程去发送数据 - 这是可优化的地方
                            new Thread(new Runnable() {
                                @Override
                                public void run() {
                                    listener.onDataDecoded(outputBuffer,
                                            mCodec.getOutputFormat().getInteger(MediaFormat.KEY_COLOR_FORMAT),
                                            nv21, imageWid, imageHei);
                                }
                            }).start();
                        } else {
                            listener.onDataDecoded(outputBuffer,
                                    mCodec.getOutputFormat().getInteger(MediaFormat.KEY_COLOR_FORMAT),
                                    new byte[]{0}, 0, 0);
                        }

                        try {
                            mCodec.releaseOutputBuffer(index, false);
                        } catch (IllegalStateException ex) {
                            android.util.Log.e(TAG, "releaseOutputBuffer ERROR", ex);
                        }
                        outputBufferIndex = mCodec.dequeueOutputBuffer(bufferInfo, 0);
                    }
                }
                catch (Exception e) {
                    e.printStackTrace();
                    Log.e(TAG, "decoderThread exception:" + e.getMessage());
                }

                try {
                    Thread.sleep(DECODER_TIME_INTERNAL);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    // deep clone byteBuffer
    private static ByteBuffer byteBufferClone(ByteBuffer buffer) {
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
}

```

### 代码示例 - 工具函数
一些工具函数。比如从image中取出NV21格式的数据。
```java
    private byte[] getDataFromImage(Image image) {
        return getDataFromImage(image, COLOR_FormatNV21);
    }

    /**
     * 将Image根据colorFormat类型的byte数据
     */
    private byte[] getDataFromImage(Image image, int colorFormat) {
        if (colorFormat != COLOR_FormatI420 && colorFormat != COLOR_FormatNV21) {
            throw new IllegalArgumentException("only support COLOR_FormatI420 " + "and COLOR_FormatNV21");
        }
        if (!isImageFormatSupported(image)) {
            throw new RuntimeException("can't convert Image to byte array, format " + image.getFormat());
        }
        Rect crop = image.getCropRect();
        int format = image.getFormat();
        int width = crop.width();
        int height = crop.height();
        Image.Plane[] planes = image.getPlanes();
        byte[] data = new byte[width * height * ImageFormat.getBitsPerPixel(format) / 8];
        byte[] rowData = new byte[planes[0].getRowStride()];
        int channelOffset = 0;
        int outputStride = 1;
        for (int i = 0; i < planes.length; i++) {
            switch (i) {
                case 0:
                    channelOffset = 0;
                    outputStride = 1;
                    break;
                case 1:
                    if (colorFormat == COLOR_FormatI420) {
                        channelOffset = width * height;
                        outputStride = 1;
                    } else if (colorFormat == COLOR_FormatNV21) {
                        channelOffset = width * height + 1;
                        outputStride = 2;
                    }
                    break;
                case 2:
                    if (colorFormat == COLOR_FormatI420) {
                        channelOffset = (int) (width * height * 1.25);
                        outputStride = 1;
                    } else if (colorFormat == COLOR_FormatNV21) {
                        channelOffset = width * height;
                        outputStride = 2;
                    }
                    break;
            }
            ByteBuffer buffer = planes[i].getBuffer();
            int rowStride = planes[i].getRowStride();
            int pixelStride = planes[i].getPixelStride();

            int shift = (i == 0) ? 0 : 1;
            int w = width >> shift;
            int h = height >> shift;
            buffer.position(rowStride * (crop.top >> shift) + pixelStride * (crop.left >> shift));
            for (int row = 0; row < h; row++) {
                int length;
                if (pixelStride == 1 && outputStride == 1) {
                    length = w;
                    buffer.get(data, channelOffset, length);
                    channelOffset += length;
                } else {
                    length = (w - 1) * pixelStride + 1;
                    buffer.get(rowData, 0, length);
                    for (int col = 0; col < w; col++) {
                        data[channelOffset] = rowData[col * pixelStride];
                        channelOffset += outputStride;
                    }
                }
                if (row < h - 1) {
                    buffer.position(buffer.position() + rowStride - length);
                }
            }
        }
        return data;
    }

    /**
     * 是否是支持的数据类型
     */
    private static boolean isImageFormatSupported(Image image) {
        int format = image.getFormat();
        switch (format) {
            case ImageFormat.YUV_420_888:
            case ImageFormat.NV21:
            case ImageFormat.YV12:
                return true;
        }
        return false;
    }
```
"csd-0"和"csd-1"是什么，对于H264视频的话，它对应的是sps和pps，对于AAC音频的话，对应的是ADTS，做音视频开发的人应该都知道，它一般存在于编码器生成的IDR帧之中。

得到的mediaFormat
```
mediaFormat in:{height=720, width=1280, csd-1=java.nio.ByteArrayBuffer[position=0,limit=7,capacity=7], mime=video/avc, csd-0=java.nio.ByteArrayBuffer[position=0,limit=13,capacity=13], color-format=2135033992}
```

### 存储图片的方法
Image类在Android API21及以后功能十分强大。

```java
    private static void dumpFile(String fileName, byte[] data) {
        FileOutputStream outStream;
        try {
            outStream = new FileOutputStream(fileName);
        } catch (IOException ioe) {
            throw new RuntimeException("Unable to create output file " + fileName, ioe);
        }
        try {
            outStream.write(data);
            outStream.close();
        } catch (IOException ioe) {
            throw new RuntimeException("failed writing data to file " + fileName, ioe);
        }
    }

    private void compressToJpeg(String fileName, Image image) {
        FileOutputStream outStream;
        try {
            outStream = new FileOutputStream(fileName);
        } catch (IOException ioe) {
            throw new RuntimeException("Unable to create output file " + fileName, ioe);
        }
        Rect rect = image.getCropRect();
        YuvImage yuvImage = new YuvImage(getDataFromImage(image, COLOR_FormatNV21), ImageFormat.NV21, rect.width(), rect.height(), null);
        yuvImage.compressToJpeg(rect, 100, outStream);
    }
```

### NV21转bitmap的方法
直接存入文件
```java
// in try catch
FileOutputStream fos = new FileOutputStream(Environment.getExternalStorageDirectory() + "/imagename.jpg");
YuvImage yuvImage = new YuvImage(nv21bytearray, ImageFormat.NV21, width, height, null);
yuvImage.compressToJpeg(new Rect(0, 0, width, height), 100, fos);
fos.close();
```

获得Bitmap对象的方法，这个方法耗时耗内存  
NV21 -> yuvImage -> jpeg -> bitmap
```java
// in try catch
YuvImage yuvImage = new YuvImage(nv21bytearray, ImageFormat.NV21, width, height, null);
ByteArrayOutputStream os = new ByteArrayOutputStream();
yuvImage.compressToJpeg(new Rect(0, 0, width, height), 100, os);
byte[] jpegByteArray = os.toByteArray();
Bitmap bitmap = BitmapFactory.decodeByteArray(jpegByteArray, 0, jpegByteArray.length);
os.close();
```

参考 https://stackoverflow.com/questions/32276522/convert-nv21-byte-array-into-bitmap-readable-format

## 参考资料

* [Android: MediaCodec视频文件硬件解码,高效率得到YUV格式帧,快速保存JPEG图片(不使用OpenGL)(附Demo)](https://www.polarxiong.com/archives/Android-MediaCodec%E8%A7%86%E9%A2%91%E6%96%87%E4%BB%B6%E7%A1%AC%E4%BB%B6%E8%A7%A3%E7%A0%81-%E9%AB%98%E6%95%88%E7%8E%87%E5%BE%97%E5%88%B0YUV%E6%A0%BC%E5%BC%8F%E5%B8%A7-%E5%BF%AB%E9%80%9F%E4%BF%9D%E5%AD%98JPEG%E5%9B%BE%E7%89%87-%E4%B8%8D%E4%BD%BF%E7%94%A8OpenGL.html)
* [Android: Image类浅析(结合YUV_420_888)](https://www.polarxiong.com/archives/Android-Image%E7%B1%BB%E6%B5%85%E6%9E%90-%E7%BB%93%E5%90%88YUV_420_888.html)
* [Android MediaCodec stuff](http://bigflake.com/mediacodec/)
* [雷霄骅(leixiaohua1020)的专栏](http://blog.csdn.net/leixiaohua1020/)
* [[总结]FFMPEG视音频编解码零基础学习方法 - 雷霄骅](http://blog.csdn.net/leixiaohua1020/article/details/15811977)
* [Bilibili/ijkplayer - Github](https://github.com/Bilibili/ijkplayer)
