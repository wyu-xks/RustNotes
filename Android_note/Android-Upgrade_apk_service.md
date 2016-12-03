---
title: Android app自动更新功能
date: 2016-10-13 19:21:01
category: Android_note
tag: [Android]
---

Android 下载更新版本并自动安装

从后台服务器获取到最新版本号和apk下载地址后，与当前app版本比对，决定
是否下载新的apk。若要升级，开启`UpgradeApkService`这个服务。

服务里调用了系统的下载类`DownloadManager`。设置下载地址，指定下载路径，
清理掉下载路径里的文件，然后把更新的apk加入下载队列中。
注册下载完成广播，下载完成后自动安装apk。

这里用`File`来指定下载文件的路径。下载位置和安装位置必须保持一致。

下载来的apk必须和现有apk的签名一致，而且更新的apk版本号必须大于现有版本号。
否则会安装失败。出现类似`Failure [INSTALL_FAILED_ALREADY_EXISTS]`的错误

下载过程会在下拉栏中显示。有的手机（ROM）会提供暂停下载的功能。

```java
public class UpgradeApkService extends Service {

    private Application mApp = Application.getInstance();

    private static final String APK_NAME = "NewVersion.apk";

    /**
     * 安卓系统下载类
     */
    DownloadManager manager;

    /**
     * 接收下载完的广播
     */
    DownloadCompleteReceiver receiver;

    /**
     * 初始化下载器
     */
    private void initDownManager() {

        manager = (DownloadManager) getSystemService(DOWNLOAD_SERVICE);

        receiver = new DownloadCompleteReceiver();

        // 设置下载地址
        DownloadManager.Request down = new DownloadManager.Request(
                Uri.parse(mApp.getRemoteApkUrl()));

        // 设置允许使用的网络类型，这里是移动网络和wifi都可以
        down.setAllowedNetworkTypes(DownloadManager.Request.NETWORK_MOBILE | DownloadManager.Request.NETWORK_WIFI);

        // 下载时，通知栏显示
        down.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE);

        // 显示下载界面
        down.setVisibleInDownloadsUi(true);

        // 设置下载后文件存放的位置 -- 存放位置和安装位置必须保持一致
        File apkFile = new File(Environment.getExternalStorageDirectory(), APK_NAME);
        if (apkFile.exists()) {
            apkFile.delete();
        }
        down.setDestinationUri(Uri.fromFile(apkFile));

        // 将下载请求放入队列
        manager.enqueue(down);
        mApp.setDownloadingApk(true);

        //注册下载广播
        registerReceiver(receiver, new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE));
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // 调用下载
        initDownManager();
        return START_NOT_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {

        // 注销下载广播
        if (receiver != null) {
            unregisterReceiver(receiver);
        }
        mApp.setDownloadingApk(false);
        super.onDestroy();
    }

    // 接受下载完成后的intent
    class DownloadCompleteReceiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {

            // 判断是否下载完成的广播
            if (intent.getAction().equals(DownloadManager.ACTION_DOWNLOAD_COMPLETE)) {
                mApp.setDownloadingApk(false);
                Intent installIntent = new Intent(Intent.ACTION_VIEW);
                installIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                installIntent.setDataAndType(Uri.fromFile(new File(Environment.getExternalStorageDirectory(), APK_NAME)),
                        "application/vnd.android.package-archive");
                startActivity(installIntent);

                // 停止服务并关闭广播
                UpgradeApkService.this.stopSelf();

            }
        }

    }
}
```
