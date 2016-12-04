---
title: Android 自定义Crash handler记录崩溃信息
date: 2017-12-26 20:11:13
category: Android_note
---

App异常崩溃信息存入文件中。  
应用崩溃时，尽可能的收集多的数据，方便后续定位追踪修改。  
如果可以，尽量将崩溃日志上传到服务器。一些集成服务已经提供了相应的功能。

主要使用的方法是`Thread.UncaughtExceptionHandler`  
一般在application中启动`CrashHandler`，个人认为应该放在调用其他模块前尽早启动。

`CrashHandler.java`
```java
import android.os.Build;
import android.os.Environment;
import android.os.Process;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class CrashHandler implements Thread.UncaughtExceptionHandler {
    private static final String TAG = "CrashHandler";
    private static final boolean DEBUG = true;
    // 自定义存储的目录
    private static final String PATH = Environment.getExternalStorageDirectory().getPath() + "/myApp/log/";
    private static final String FILE_NAME = "crash";
    private static final String FILE_NAME_SUFFIX = ".txt";
    private String phoneInfo;
    private static CrashHandler instance = new CrashHandler();
    private Thread.UncaughtExceptionHandler mDefaultCrashHandler;

    private CrashHandler() {
    }

    public static CrashHandler getInstance() {
        return instance;
    }

    public void init() {
        mDefaultCrashHandler = Thread.getDefaultUncaughtExceptionHandler();
        Thread.setDefaultUncaughtExceptionHandler(this);
        phoneInfo = getPhoneInformation();
    }

    /**
     * 这个是最关键的函数，当程序中有未被捕获的异常，系统将会自动调用uncaughtException方法
     * thread为出现未捕获异常的线程，ex为未捕获的异常，有了这个ex，我们就可以得到异常信息
     */
    @Override
    public void uncaughtException(Thread thread, Throwable ex) {
        try {
            //导出异常信息到SD卡中
            dumpExceptionToSDCard(ex);
            //这里可以上传异常信息到服务器，便于开发人员分析日志从而解决bug
            uploadExceptionToServer();
        } catch (IOException e) {
            e.printStackTrace();
        }
        ex.printStackTrace();
        //如果系统提供默认的异常处理器，则交给系统去结束程序，否则就由自己结束自己
        if (mDefaultCrashHandler != null) {
            mDefaultCrashHandler.uncaughtException(thread, ex);
        } else {
            try {
                Thread.sleep(2000); // 延迟2秒杀进程
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            android.os.Process.killProcess(Process.myPid());
        }
    }

    private void dumpExceptionToSDCard(Throwable ex) throws IOException {
        //如果SD卡不存在或无法使用，则无法把异常信息写入SD卡
        if (!Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            if (DEBUG) {
                Log.e(TAG, "sdcard unmounted,skip dump exception");
                return;
            }
        }
        File dir = new File(PATH);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        long current = System.currentTimeMillis();
        String time = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.CHINA).format(new Date(current));
        File file = new File(PATH + FILE_NAME + time + FILE_NAME_SUFFIX);
        try {
            PrintWriter pw = new PrintWriter(new BufferedWriter(new FileWriter(file)));
            pw.println(time);
            pw.println(phoneInfo);
            pw.println();
            ex.printStackTrace(pw);
            pw.close();
            Log.e(TAG, "dump crash info seccess");
        } catch (Exception e) {
            Log.e(TAG, e.getMessage());
            Log.e(TAG, "dump crash info failed");
        }
    }

    private void uploadExceptionToServer() {
        // 将异常信息发送到服务器
    }

    private String getPhoneInformation() {
        StringBuilder sb = new StringBuilder();
        sb.append("App version name:")
                .append(BuildConfig.VERSION_NAME)
                .append(", version code:")
                .append(BuildConfig.VERSION_CODE).append("\n");
        //Android版本号
        sb.append("OS Version: ");
        sb.append(Build.VERSION.RELEASE);
        sb.append("_");
        sb.append(Build.VERSION.SDK_INT).append("\n");
        //手机制造商
        sb.append("Vendor: ");
        sb.append(Build.MANUFACTURER).append("\n");
        //手机型号
        sb.append("Model: ");
        sb.append(Build.MODEL).append("\n");
        //CPU架构
        sb.append("CPU ABI:").append("\n");
        for (String abi : Build.SUPPORTED_ABIS) {
            sb.append(abi).append("\n");
        }
        return sb.toString();
    }
}

```

使用方式，可在Application中调用初始化方法
```java
    @Override
    public void onCreate() {
        super.onCreate();
        // init application...
        CrashHandler.getInstance().init();
    }
```
