---
title: Android AudioRecord和AudioTrack实现音频PCM数据的采集和播放，并读写音频wav文件
date: 2018-02-24 18:52:12
category: Android_note
toc: true
---

* win7
* Android Studio 3.0.1

本文目的：使用 AudioRecord 和 AudioTrack 完成音频PCM数据的采集和播放，并读写音频wav文件

### 准备工作
Android提供了AudioRecord和MediaRecord。MediaRecord可选择录音的格式。
AudioRecord得到PCM编码格式的数据。AudioRecord能够设置模拟信号转化为数字信号的相关参数，包括采样率和量化深度，同时也包括通道数目等。

#### PCM
PCM是在由模拟信号向数字信号转化的一种常用的编码格式，称为脉冲编码调制，PCM将模拟信号按照一定的间距划分为多段，然后通过二进制去量化每一个间距的强度。
PCM表示的是音频文件中随着时间的流逝的一段音频的振幅。Android在WAV文件中支持PCM的音频数据。

#### WAV
WAV，MP3等比较常见的音频格式，不同的编码格式对应不通过的原始音频。为了方便传输，通常会压缩原始音频。
为了辨别出音频格式，每种格式有特定的头文件（header）。 
WAV以RIFF为标准。RIFF是一种资源交换档案标准。RIFF将文件存储在每一个标记块中。
基本构成单位是trunk，每个trunk由标记位，数据大小，数据存储，三个部分构成。 

#### PCM打包成WAV
PCM是原始音频数据，WAV是windows中常见的音频格式，只是在pcm数据中添加了一个文件头。

|起始地址| 占用空间  | 本地址数字的含义 |
|:------|:----------|:-------|
| 00H | 4byte | RIFF，资源交换文件标志。 |
| 04H | 4byte | 从下一个地址开始到文件尾的总字节数。高位字节在后面，这里就是001437ECH，换成十进制是1325036byte，算上这之前的8byte就正好1325044byte了。 |
| 08H | 4byte | WAVE，代表wav文件格式。 |
| 0CH | 4byte | FMT ，波形格式标志 |
| 10H | 4byte | 00000010H，16PCM，我的理解是用16bit的数据表示一个量化结果。 |
| 14H | 2byte | 为1时表示线性PCM编码，大于1时表示有压缩的编码。这里是0001H。 |
| 16H | 2byte | 1为单声道，2为双声道，这里是0001H。 |
| 18H | 4byte | 采样频率，这里是00002B11H，也就是11025Hz。 |
| 1CH | 4byte | Byte率=`采样频率*音频通道数*每次采样得到的样本位数/8`，00005622H，也就是`22050Byte/s=11025*1*16/2` |
| 20H | 2byte | 块对齐=通道数*每次采样得到的样本位数/8，0002H，也就是 `2 == 1*16/8` |
| 22H | 2byte | 样本数据位数，0010H即16，一个量化样本占2byte。 |
| 24H | 4byte | data，一个标志而已。 |
| 28H | 4byte | Wav文件实际音频数据所占的大小，这里是001437C8H即1325000，再加上2CH就正好是1325044，整个文件的大小。 |
| 2CH | 不定  |  量化数据|

#### AudioRecord
AudioRecord可实现从音频输入设备记录声音的功能。得到PCM格式的音频。
读取音频的方法有`read(byte[], int, int)`， `read(short[], int, int)` 或 `read(ByteBuffer, int)`。
可根据存储方式和需求选择使用这项方法。

需要权限`<uses-permission android:name="android.permission.RECORD_AUDIO" />`

##### AudioRecord 构造函数
`public AudioRecord(int audioSource, int sampleRateInHz, int channelConfig, int audioFormat, int bufferSizeInBytes)`
* audioSource 音源设备，常用麦克风`MediaRecorder.AudioSource.MIC`
* samplerateInHz 采样频率，44100Hz是目前所有设备都支持的频率
* channelConfig 音频通道，单声道还是立体声
* audioFormat 该参数为量化深度，即为每次采样的位数
* bufferSizeInBytes 可通过`getMinBufferSize()`方法确定，每次从硬件读取数据所需要的缓冲区的大小。

##### 获取wav文件
若要获得wav文件，需要在PCM基础上增加一个header。可以将PCM文件转换成wav，这里提供一种PCM与wav几乎同时生成的思路。

PCM与wav同时创建，给wav文件一个默认的header。录制线程启动后，同时写PCM与wav。
录制完成时，重新生成header，利用`RandomAccessFile`修改wav文件的header。

#### AudioTrack
使用`AudioTrack`播放音频。初始化AudioTrack时，要根据录制时的参数进行设定。

### 代码示例
工具类`WindEar`实现音频PCM数据的采集和播放，与读写音频wav文件的功能。

* `AudioRecordThread` 使用`AudioRecord`录制PCM文件，可选择同时生成wav文件
* `AudioTrackPlayThread` 使用AudioTrack播放PCM或wav音频文件的线程
* `WindState` 表示当前状态，例如是否在播放，录制等等

PCM文件的读写采用`FileOutputStream`和`FileInputStream`

`generateWavFileHeader`方法可以生成wav文件的header

```java
/**
 * 音频录制器
 * 使用 AudioRecord 和 AudioTrack API 完成音频 PCM 数据的采集和播放，并实现读写音频 wav 文件
 * 检查权限，检查麦克风的工作放在Activity中进行
 * Created by Rust on 2018/2/24.
 */
public class WindEar {
    private static final String TAG = "rustApp";
    private static final String TMP_FOLDER_NAME = "AnWindEar";
    private static final int RECORD_AUDIO_BUFFER_TIMES = 1;
    private static final int PLAY_AUDIO_BUFFER_TIMES = 1;
    private static final int AUDIO_FREQUENCY = 44100;

    private static final int RECORD_CHANNEL_CONFIG = AudioFormat.CHANNEL_IN_STEREO;
    private static final int PLAY_CHANNEL_CONFIG = AudioFormat.CHANNEL_OUT_STEREO;
    private static final int AUDIO_ENCODING = AudioFormat.ENCODING_PCM_16BIT;

    private AudioRecordThread aRecordThread;           // 录制线程
    private volatile WindState state = WindState.IDLE; // 当前状态
    private File tmpPCMFile = null;
    private File tmpWavFile = null;
    private OnState onStateListener;
    private Handler mainHandler = new Handler(Looper.getMainLooper());

    /**
     * PCM缓存目录
     */
    private static String cachePCMFolder;

    /**
     * wav缓存目录
     */
    private static String wavFolderPath;

    private static WindEar instance = new WindEar();

    private WindEar() {

    }

    public static WindEar getInstance() {
        if (null == instance) {
            instance = new WindEar();
        }
        return instance;
    }

    public void setOnStateListener(OnState onStateListener) {
        this.onStateListener = onStateListener;
    }

    /**
     * 初始化目录
     */
    public static void init(Context context) {
        // 存储在App内或SD卡上
//        cachePCMFolder = context.getFilesDir().getAbsolutePath() + File.separator + TMP_FOLDER_NAME;
        cachePCMFolder = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator
                + TMP_FOLDER_NAME;

        File folder = new File(cachePCMFolder);
        if (!folder.exists()) {
            boolean f = folder.mkdirs();
            Log.d(TAG, String.format(Locale.CHINA, "PCM目录:%s -> %b", cachePCMFolder, f));
        } else {
            for (File f : folder.listFiles()) {
                boolean d = f.delete();
                Log.d(TAG, String.format(Locale.CHINA, "删除PCM文件:%s %b", f.getName(), d));
            }
            Log.d(TAG, String.format(Locale.CHINA, "PCM目录:%s", cachePCMFolder));
        }

        wavFolderPath = Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator
                + TMP_FOLDER_NAME;
//        wavFolderPath = context.getFilesDir().getAbsolutePath() + File.separator + TMP_FOLDER_NAME;
        File wavDir = new File(wavFolderPath);
        if (!wavDir.exists()) {
            boolean w = wavDir.mkdirs();
            Log.d(TAG, String.format(Locale.CHINA, "wav目录:%s -> %b", wavFolderPath, w));
        } else {
            Log.d(TAG, String.format(Locale.CHINA, "wav目录:%s", wavFolderPath));
        }
    }

    /**
     * 开始录制音频
     */
    public synchronized void startRecord(boolean createWav) {
        if (!state.equals(WindState.IDLE)) {
            Log.w(TAG, "无法开始录制，当前状态为 " + state);
            return;
        }
        try {
            tmpPCMFile = File.createTempFile("recording", ".pcm", new File(cachePCMFolder));
            if (createWav) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyMMdd_HHmmss", Locale.CHINA);
                tmpWavFile = new File(wavFolderPath + File.separator + "r" + sdf.format(new Date()) + ".wav");
            }
            Log.d(TAG, "tmp file " + tmpPCMFile.getName());
        } catch (IOException e) {
            e.printStackTrace();
        }
        if (null != aRecordThread) {
            aRecordThread.interrupt();
            aRecordThread = null;
        }
        aRecordThread = new AudioRecordThread(createWav);
        aRecordThread.start();
    }

    public synchronized void stopRecord() {
        if (!state.equals(WindState.RECORDING)) {
            return;
        }
        state = WindState.STOP_RECORD;
        notifyState(state);
    }

    /**
     * 播放录制好的PCM文件
     */
    public synchronized void startPlayPCM() {
        if (!isIdle()) {
            return;
        }
        new AudioTrackPlayThread(tmpPCMFile).start();
    }

    /**
     * 播放录制好的wav文件
     */
    public synchronized void startPlayWav() {
        if (!isIdle()) {
            return;
        }
        new AudioTrackPlayThread(tmpWavFile).start();
    }

    public synchronized void stopPlay() {
        if (!state.equals(WindState.PLAYING)) {
            return;
        }
        state = WindState.STOP_PLAY;
    }

    public synchronized boolean isIdle() {
        return WindState.IDLE.equals(state);
    }

    /**
     * 音频录制线程
     * 使用FileOutputStream来写文件
     */
    private class AudioRecordThread extends Thread {
        AudioRecord aRecord;
        int bufferSize = 10240;
        boolean createWav = false;

        AudioRecordThread(boolean createWav) {
            this.createWav = createWav;
            bufferSize = AudioRecord.getMinBufferSize(AUDIO_FREQUENCY,
                    RECORD_CHANNEL_CONFIG, AUDIO_ENCODING) * RECORD_AUDIO_BUFFER_TIMES;
            Log.d(TAG, "record buffer size = " + bufferSize);
            aRecord = new AudioRecord(MediaRecorder.AudioSource.MIC, AUDIO_FREQUENCY,
                    RECORD_CHANNEL_CONFIG, AUDIO_ENCODING, bufferSize);
        }

        @Override
        public void run() {
            state = WindState.RECORDING;
            notifyState(state);
            Log.d(TAG, "录制开始");
            try {
                // 这里选择FileOutputStream而不是DataOutputStream
                FileOutputStream pcmFos = new FileOutputStream(tmpPCMFile);

                FileOutputStream wavFos = new FileOutputStream(tmpWavFile);
                if (createWav) {
                    writeWavFileHeader(wavFos, bufferSize, AUDIO_FREQUENCY, aRecord.getChannelCount());
                }
                aRecord.startRecording();
                byte[] byteBuffer = new byte[bufferSize];
                while (state.equals(WindState.RECORDING) && !isInterrupted()) {
                    int end = aRecord.read(byteBuffer, 0, byteBuffer.length);
                    pcmFos.write(byteBuffer, 0, end);
                    pcmFos.flush();
                    if (createWav) {
                        wavFos.write(byteBuffer, 0, end);
                        wavFos.flush();
                    }
                }
                aRecord.stop(); // 录制结束
                pcmFos.close();
                wavFos.close();
                if (createWav) {
                    // 修改header
                    RandomAccessFile wavRaf = new RandomAccessFile(tmpWavFile, "rw");
                    byte[] header = generateWavFileHeader(tmpPCMFile.length(), AUDIO_FREQUENCY, aRecord.getChannelCount());
                    Log.d(TAG, "header: " + getHexString(header));
                    wavRaf.seek(0);
                    wavRaf.write(header);
                    wavRaf.close();
                    Log.d(TAG, "tmpWavFile.length: " + tmpWavFile.length());
                }
                Log.i(TAG, "audio tmp PCM file len: " + tmpPCMFile.length());
            } catch (Exception e) {
                Log.e(TAG, "AudioRecordThread:", e);
                notifyState(WindState.ERROR);
            }
            notifyState(state);
            state = WindState.IDLE;
            notifyState(state);
            Log.d(TAG, "录制结束");
        }

    }

    private static String getHexString(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(Integer.toHexString(b)).append(",");
        }
        return sb.toString();
    }

    /**
     * AudioTrack播放音频线程
     * 使用FileInputStream读取文件
     */
    private class AudioTrackPlayThread extends Thread {
        AudioTrack track;
        int bufferSize = 10240;
        File audioFile = null;

        AudioTrackPlayThread(File aFile) {
            setPriority(Thread.MAX_PRIORITY);
            audioFile = aFile;
            int bufferSize = AudioTrack.getMinBufferSize(AUDIO_FREQUENCY,
                    PLAY_CHANNEL_CONFIG, AUDIO_ENCODING) * PLAY_AUDIO_BUFFER_TIMES;
            track = new AudioTrack(AudioManager.STREAM_MUSIC,
                    AUDIO_FREQUENCY,
                    PLAY_CHANNEL_CONFIG, AUDIO_ENCODING, bufferSize,
                    AudioTrack.MODE_STREAM);
        }

        @Override
        public void run() {
            super.run();
            state = WindState.PLAYING;
            notifyState(state);
            try {
                FileInputStream fis = new FileInputStream(audioFile);
                track.play();
                byte[] aByteBuffer = new byte[bufferSize];
                while (state.equals(WindState.PLAYING) &&
                        fis.read(aByteBuffer) >= 0) {
                    track.write(aByteBuffer, 0, aByteBuffer.length);
                }
                track.stop();
                track.release();
            } catch (Exception e) {
                Log.e(TAG, "AudioTrackPlayThread:", e);
                notifyState(WindState.ERROR);
            }
            state = WindState.STOP_PLAY;
            notifyState(state);
            state = WindState.IDLE;
            notifyState(state);
        }

    }

    private synchronized void notifyState(final WindState currentState) {
        if (null != onStateListener) {
            mainHandler.post(new Runnable() {
                @Override
                public void run() {
                    onStateListener.onStateChanged(currentState);
                }
            });
        }
    }

    public interface OnState {
        void onStateChanged(WindState currentState);
    }

    /**
     * 表示当前状态
     */
    public enum WindState {
        ERROR,
        IDLE,
        RECORDING,
        STOP_RECORD,
        PLAYING,
        STOP_PLAY
    }

    /**
     * @param out            wav音频文件流
     * @param totalAudioLen  不包括header的音频数据总长度
     * @param longSampleRate 采样率,也就是录制时使用的频率
     * @param channels       audioRecord的频道数量
     * @throws IOException 写文件错误
     */
    private void writeWavFileHeader(FileOutputStream out, long totalAudioLen, long longSampleRate,
                                    int channels) throws IOException {
        byte[] header = generateWavFileHeader(totalAudioLen, longSampleRate, channels);
        out.write(header, 0, header.length);
    }

    /**
     * 任何一种文件在头部添加相应的头文件才能够确定的表示这种文件的格式，
     * wave是RIFF文件结构，每一部分为一个chunk，其中有RIFF WAVE chunk，
     * FMT Chunk，Fact chunk,Data chunk,其中Fact chunk是可以选择的
     *
     * @param pcmAudioByteCount 不包括header的音频数据总长度
     * @param longSampleRate    采样率,也就是录制时使用的频率
     * @param channels          audioRecord的频道数量
     */
    private byte[] generateWavFileHeader(long pcmAudioByteCount, long longSampleRate, int channels) {
        long totalDataLen = pcmAudioByteCount + 36; // 不包含前8个字节的WAV文件总长度
        long byteRate = longSampleRate * 2 * channels;
        byte[] header = new byte[44];
        header[0] = 'R'; // RIFF
        header[1] = 'I';
        header[2] = 'F';
        header[3] = 'F';

        header[4] = (byte) (totalDataLen & 0xff);//数据大小
        header[5] = (byte) ((totalDataLen >> 8) & 0xff);
        header[6] = (byte) ((totalDataLen >> 16) & 0xff);
        header[7] = (byte) ((totalDataLen >> 24) & 0xff);

        header[8] = 'W';//WAVE
        header[9] = 'A';
        header[10] = 'V';
        header[11] = 'E';
        //FMT Chunk
        header[12] = 'f'; // 'fmt '
        header[13] = 'm';
        header[14] = 't';
        header[15] = ' ';//过渡字节
        //数据大小
        header[16] = 16; // 4 bytes: size of 'fmt ' chunk
        header[17] = 0;
        header[18] = 0;
        header[19] = 0;
        //编码方式 10H为PCM编码格式
        header[20] = 1; // format = 1
        header[21] = 0;
        //通道数
        header[22] = (byte) channels;
        header[23] = 0;
        //采样率，每个通道的播放速度
        header[24] = (byte) (longSampleRate & 0xff);
        header[25] = (byte) ((longSampleRate >> 8) & 0xff);
        header[26] = (byte) ((longSampleRate >> 16) & 0xff);
        header[27] = (byte) ((longSampleRate >> 24) & 0xff);
        //音频数据传送速率,采样率*通道数*采样深度/8
        header[28] = (byte) (byteRate & 0xff);
        header[29] = (byte) ((byteRate >> 8) & 0xff);
        header[30] = (byte) ((byteRate >> 16) & 0xff);
        header[31] = (byte) ((byteRate >> 24) & 0xff);
        // 确定系统一次要处理多少个这样字节的数据，确定缓冲区，通道数*采样位数
        header[32] = (byte) (2 * channels);
        header[33] = 0;
        //每个样本的数据位数
        header[34] = 16;
        header[35] = 0;
        //Data chunk
        header[36] = 'd';//data
        header[37] = 'a';
        header[38] = 't';
        header[39] = 'a';
        header[40] = (byte) (pcmAudioByteCount & 0xff);
        header[41] = (byte) ((pcmAudioByteCount >> 8) & 0xff);
        header[42] = (byte) ((pcmAudioByteCount >> 16) & 0xff);
        header[43] = (byte) ((pcmAudioByteCount >> 24) & 0xff);
        return header;
    }
}

```

### 参考资料
* [AudioRecord - developer.android.com](https://developer.android.com/reference/android/media/AudioRecord.html)
* [AudioTrack - developer.android.com](https://developer.android.com/reference/android/media/AudioTrack.html)
