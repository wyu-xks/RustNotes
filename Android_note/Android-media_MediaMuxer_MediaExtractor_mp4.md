---
title: Android 使用 MediaExtractor 和 MediaMuxer 解析和封装 mp4 文件
date: 2018-03-01 21:21:16
category: Android_note
toc: true
---

* win7
* Android Studio 3.0.1

本文目的：使用 MediaExtractor 和 MediaMuxer 解析和封装 mp4 文件

### 简介
MP4或称MPEG-4第14部分（英语：MPEG-4 Part 14）是一种标准的数字多媒体容器格式。

MP4中的音频格式通常为AAC(audio/mp4a-latm)

#### MediaExtractor
[MediaExtractor](https://developer.android.com/reference/android/media/MediaExtractor.html) 可用于分离多媒体容器中视频track和音频track

`setDataSource()` 设置数据源，数据源可以是本地文件地址，也可以是网络地址

`getTrackFormat(int index)` 来获取各个track的`MediaFormat`，通过`MediaFormat`来获取track的详细信息，如：MimeType、分辨率、采样频率、帧率等等

`selectTrack(int index)` 通过下标选择指定的通道

`readSampleData(ByteBuffer buffer, int offset)` 获取当前编码好的数据并存在指定好偏移量的buffer中

#### MediaMuxer
[MediaMuxer](https://developer.android.com/reference/android/media/MediaMuxer.html) 可用于混合基本码流。将所有的信道的信息合成一个视频。
目前输出格式支持MP4，Webm，3GP。从Android Nougat开始支持向MP4中混入B-frames。

### 提取并输出MP4文件中的视频部分
从一个MP4文件中提取出视频，得到不含音频的MP4文件。

实现流程，首先是使用`MediaExtractor`提取，然后使用`MediaMuxer`输出MP4文件。
* `MediaExtractor`设置数据源，找到并选择视频轨道的格式和下标
* `MediaMuxer`设置输出格式为`MUXER_OUTPUT_MPEG_4`，添加前面选定的格式，调用`start()`启动
* `MediaExtractor`读取帧数据，不停地将帧数据和相关信息传入`MediaMuxer`
* 最后停止并释放`MediaMuxer`和`MediaExtractor`
最好放在子线程中操作。
```java
    /**
     * 提取视频
     *
     * @param sourceVideoPath 原始视频文件
     * @throws Exception 出错
     */
    public static void extractVideo(String sourceVideoPath, String outVideoPath) throws Exception {
        MediaExtractor sourceMediaExtractor = new MediaExtractor();
        sourceMediaExtractor.setDataSource(sourceVideoPath);
        int numTracks = sourceMediaExtractor.getTrackCount();
        int sourceVideoTrackIndex = -1; // 原始视频文件视频轨道参数
        for (int i = 0; i < numTracks; ++i) {
            MediaFormat format = sourceMediaExtractor.getTrackFormat(i);
            String mime = format.getString(MediaFormat.KEY_MIME);
            Log.d(TAG, "MediaFormat: " + mime);
            if (mime.startsWith("video/")) {
                sourceMediaExtractor.selectTrack(i);
                sourceVideoTrackIndex = i;
                Log.d(TAG, "selectTrack index=" + i + "; format: " + mime);
                break;
            }
        }

        MediaMuxer outputMediaMuxer = new MediaMuxer(outVideoPath,
                MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);
        outputMediaMuxer.addTrack(sourceMediaExtractor.getTrackFormat(sourceVideoTrackIndex));
        outputMediaMuxer.start();

        ByteBuffer inputBuffer = ByteBuffer.allocate(1024 * 1024 * 2); // 分配的内存要尽量大一些
        MediaCodec.BufferInfo info = new MediaCodec.BufferInfo();
        int sampleSize;
        while ((sampleSize = sourceMediaExtractor.readSampleData(inputBuffer, 0)) >= 0) {
            long presentationTimeUs = sourceMediaExtractor.getSampleTime();
            info.offset = 0;
            info.size = sampleSize;
            info.flags = MediaCodec.BUFFER_FLAG_SYNC_FRAME;
            info.presentationTimeUs = presentationTimeUs;
            outputMediaMuxer.writeSampleData(sourceVideoTrackIndex, inputBuffer, info);
            sourceMediaExtractor.advance();
        }

        outputMediaMuxer.stop();
        outputMediaMuxer.release();    // 停止并释放 MediaMuxer
        sourceMediaExtractor.release();
        sourceMediaExtractor = null;   // 释放 MediaExtractor
    }
```
如果上面的`ByteBuffer`分配的空间太小，`readSampleData(inputBuffer, 0)`可能会出现`IllegalArgumentException`异常。

### 提取MP4文件中的音频部分，获取音频文件
#### 基于`Java MP4 Parser`提取出AAC文件的方法
`Java MP4 Parser` - https://github.com/sannies/mp4parser  
Java实现读、写和创建MP4容器。但是和编解码音视频有区别。这里主要是提取与再合成。

下载`isoparser-1.1.22.jar`并添加进工程中；尝试过gradle直接导入，但不成功

找到视频文件中所有的音轨，将它们提取出来写入新的文件中
```java
    public void extractAudioFromMP4(String outAudioPath, String sourceMP4Path) throws IOException {
        Movie movie = MovieCreator.build(sourceMP4Path);
        List<Track> audioTracks = new ArrayList<>();
        for (Track t : movie.getTracks()) {
            if (t.getHandler().equals("soun")) {
                audioTracks.add(t);
            }
        }
        Movie result = new Movie();
        if (audioTracks.size() > 0) {
            result.addTrack(new AppendTrack(audioTracks.toArray(new Track[audioTracks.size()])));
        }
        Container out = new DefaultMp4Builder().build(result);
        FileChannel fc = new RandomAccessFile(outAudioPath, "rw").getChannel();
        out.writeContainer(fc);
        fc.close();
    }
```
在红米手机上测试成功。从MP4文件（时长约2分20秒）中提取出的AAC文件可在手机上直接播放。

### 将AAC音轨换到另一个MP4文件
MediaExtractor可以直接从提取AAC文件或MP4文件中提取ACC音轨，MediaMuxer来写入新的MP4文件。

提供音频的文件可以是MP4文件，也可以是AAC文件；另一个提供视频，混合输出新的MP4文件。

生成的视频的长度由提供视频的文件决定。
```java
    /**
     * @param outputVideoFilePath 输出视频文件路径
     * @param videoProviderPath   提供视频的MP4文件 时长以此为准
     * @param audioProviderPath   提供音频的文件
     * @throws Exception 运行异常  例如读写文件异常
     */
    public static void replaceAudioForMP4File(String outputVideoFilePath, String videoProviderPath,
                                              String audioProviderPath)
            throws Exception {
        MediaMuxer mediaMuxer = new MediaMuxer(outputVideoFilePath,
                MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4);

        // 视频 MediaExtractor
        MediaExtractor mVideoExtractor = new MediaExtractor();
        mVideoExtractor.setDataSource(videoProviderPath);
        int videoTrackIndex = -1;
        for (int i = 0; i < mVideoExtractor.getTrackCount(); i++) {
            MediaFormat format = mVideoExtractor.getTrackFormat(i);
            if (format.getString(MediaFormat.KEY_MIME).startsWith("video/")) {
                mVideoExtractor.selectTrack(i);
                videoTrackIndex = mediaMuxer.addTrack(format);
                Log.d(TAG, "Video: format:" + format);
                break;
            }
        }

        // 音频 MediaExtractor
        MediaExtractor audioExtractor = new MediaExtractor();
        audioExtractor.setDataSource(audioProviderPath);
        int audioTrackIndex = -1;
        for (int i = 0; i < audioExtractor.getTrackCount(); i++) {
            MediaFormat format = audioExtractor.getTrackFormat(i);
            if (format.getString(MediaFormat.KEY_MIME).startsWith("audio/")) {
                audioExtractor.selectTrack(i);
                audioTrackIndex = mediaMuxer.addTrack(format);
                Log.d(TAG, "Audio: format:" + format);
                break;
            }
        }
        mediaMuxer.start(); // 添加完所有轨道后start

        long videoEndPreTimeUs = 0;
        // 封装视频track
        if (-1 != videoTrackIndex) {
            MediaCodec.BufferInfo info = new MediaCodec.BufferInfo();
            info.presentationTimeUs = 0;
            ByteBuffer buffer = ByteBuffer.allocate(1024 * 1024);
            int sampleSize;
            while ((sampleSize = mVideoExtractor.readSampleData(buffer, 0)) >= 0) {
                info.offset = 0;
                info.size = sampleSize;
                info.flags = MediaCodec.BUFFER_FLAG_SYNC_FRAME;
                info.presentationTimeUs = mVideoExtractor.getSampleTime();
                videoEndPreTimeUs = info.presentationTimeUs;
                mediaMuxer.writeSampleData(videoTrackIndex, buffer, info);
                mVideoExtractor.advance();
            }
        }
        Log.d(TAG, "视频 videoEndPreTimeUs " + videoEndPreTimeUs);

        // 封装音频track
        if (-1 != audioTrackIndex) {
            MediaCodec.BufferInfo info = new MediaCodec.BufferInfo();
            info.presentationTimeUs = 0;
            ByteBuffer buffer = ByteBuffer.allocate(1024 * 1024);
            int sampleSize;
            while ((sampleSize = audioExtractor.readSampleData(buffer, 0)) >= 0 &&
                    audioExtractor.getSampleTime() <= videoEndPreTimeUs) {
                info.offset = 0;
                info.size = sampleSize;
                info.flags = MediaCodec.BUFFER_FLAG_SYNC_FRAME;
                info.presentationTimeUs = audioExtractor.getSampleTime();
                mediaMuxer.writeSampleData(audioTrackIndex, buffer, info);
                audioExtractor.advance();
            }
        }
        mVideoExtractor.release(); // 释放MediaExtractor
        audioExtractor.release();
        mediaMuxer.stop();
        mediaMuxer.release();     // 释放MediaMuxer
    }
```

```
Video: format:{csd-1=java.nio.ByteArrayBuffer[position=0,limit=9,capacity=9], mime=video/avc, frame-rate=30, height=1080, width=1920, max-input-size=1572864, isDMCMMExtractor=1, durationUs=12425577, csd-0=java.nio.ByteArrayBuffer[position=0,limit=20,capacity=20]}
Audio: format:{max-input-size=5532, aac-profile=2, mime=audio/mp4a-latm, durationUs=340101875, csd-0=java.nio.ByteArrayBuffer[position=0,limit=2,capacity=2], channel-count=2, sample-rate=44100}
```

### MP3转换为AAC
#### 使用 AndroidAudioConverter
AndroidAudioConverter - https://github.com/adrielcafe/AndroidAudioConverter

基于FFmpeg的第三方库。支持格式有AAC, MP3, M4A, WMA, WAV 和 FLAC

使用方法：

`app/build.gradle`
```
repositories {
  maven {
    url "https://jitpack.io"
  }
}

dependencies {
  compile 'com.github.adrielcafe:AndroidAudioConverter:0.0.8'
}
```


申请读写外部存储权限
```xml
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```
在`Application`类中加载库
```java
public class MuxerApp extends Application {
    
    @Override
    public void onCreate() {
        super.onCreate();
        AndroidAudioConverter.load(this, new ILoadCallback() {
            @Override
            public void onSuccess() {
                // Great!
            }
            @Override
            public void onFailure(Exception error) {
                // FFmpeg is not supported by device
            }
        });
    }
}
```
使用转换功能
```java
    final String sourceMP3Path = SOURCE_PATH + File.separator + "music1.mp3";
    Log.d(TAG, "转换开始 " + sourceMP3Path);
    File srcFile = new File(sourceMP3Path);
    IConvertCallback callback = new IConvertCallback() {
        @Override
        public void onSuccess(File convertedFile) {
            Log.d(TAG, "onSuccess: " + convertedFile);
        }

        @Override
        public void onFailure(Exception error) {
            Log.e(TAG, "onFailure: ", error);
        }
    };
    AndroidAudioConverter.with(getApplicationContext())
            // Your current audio file
            .setFile(srcFile)

            // Your desired audio format
            .setFormat(AudioFormat.AAC)

            // An callback to know when conversion is finished
            .setCallback(callback)

            // Start conversion
            .convert();
```

在三星Note4上测试，转换13MB的MP3文件用了大约3分18秒。

### 参考
* [MediaExtractor - Android Developer](https://developer.android.com/reference/android/media/MediaExtractor.html)
* [MediaMuxer - Android Developer](https://developer.android.com/reference/android/media/MediaMuxer.html)
* [Java MP4 Parser](https://github.com/sannies/mp4parser)
