---
title: Android5.1 壁纸设置流程浅析
date: 2015-12-18 20:10:30
category: Android_note
tag: [Android_frameworks,RTFSC]
---


机器使用launcher3，在桌面上长按，底部显示设置壁纸的入口。
进入设置壁纸界面，观察log可知，此界面属于Trebuchet。也是launcher3
点击设置壁纸按钮，发现整个标题栏都有响应。在以下文件中可以找到相关定义：
```java
/*--- ↓ --- WallpaperPickerActivity.java *********/

        // Action bar
        // Show the custom action bar view
        final ActionBar actionBar = getActionBar();
        actionBar.setCustomView(R.layout.actionbar_set_wallpaper);
        actionBar.getCustomView().setOnClickListener(
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mSelectedTile != null) {
                            WallpaperTileInfo info = (WallpaperTileInfo) mSelectedTile.getTag();
                            info.onSave(WallpaperPickerActivity.this);
                        } else {
                            // no tile was selected, so we just finish the activity and go back
                            setResult(Activity.RESULT_OK);
                            finish();
                        }
                    }
                });
        mSetWallpaperButton = findViewById(R.id.set_wallpaper_button);
/*--- ↑ --- (packages/apps/Trebuchet/WallpaperPicker/src/com/android/launcher3/) *********/
```
整个 actionBar都拿来响应点击。info是 WallpaperTileInfo抽象类的对象，有5个子类。
这样系统能根据图片来选择使用哪一个子类。再调用 onSave方法。以FileWallpaperInfo类为例。
它复写了 onSave方法
```java
/*--- ↓ --- WallpaperPickerActivity.java *********/
        @Override
        public void onSave(WallpaperPickerActivity a) {
            a.setWallpaper(Uri.fromFile(mFile), true);
        }
/*--- ↑ --- (packages/apps/Trebuchet/WallpaperPicker/src/com/android/launcher3/) *********/
```
因为WallpaperPickerActivity 继承自 WallpaperCropActivity
setWallpaper方法在 WallpaperCropActivity中找到；传入了Uri和一个boolean值
```java
/*↓ --- WallpaperCropActivity.java *********/
    protected void setWallpaper(Uri uri, final boolean finishActivityWhenDone) {
        int rotation = getRotationFromExif(this, uri);
        BitmapCropTask cropTask = new BitmapCropTask(
                this, uri, null, rotation, 0, 0, true, false, null);
        final Point bounds = cropTask.getImageBounds();
        Runnable onEndCrop = new Runnable() {
            public void run() {
                updateWallpaperDimensions(bounds.x, bounds.y);
                if (finishActivityWhenDone) {
                    setResult(Activity.RESULT_OK);
                    finish();
                }
            }
        };
        cropTask.setOnEndRunnable(onEndCrop);
        cropTask.setNoCrop(true);
        cropTask.execute();
    }
/*↑ --- (packages/apps/trebuchet/wallpaperpicker/src/com/android/launcher3) *********/
```
以上代码可以看出，它启动了一个异步任务 BitmapCropTask extends AsyncTask；把一些列参数都传入了cropTask
启动一个线程onEndCrop，等待任务结束
进入BitmapCropTask看，系统做了什么工作
这是setWallpaper使用的构造方法
```java
/*↓ --- WallpaperCropActivity.java *********/
public BitmapCropTask(Context c, Uri inUri,
        RectF cropBounds, int rotation, int outWidth, int outHeight,
        boolean setWallpaper, boolean saveCroppedBitmap, Runnable onEndRunnable) {
    mContext = c;
    mInUri = inUri;
    init(cropBounds, rotation,
            outWidth, outHeight, setWallpaper, saveCroppedBitmap, onEndRunnable);
}
// ......
private void init(RectF cropBounds, int rotation, int outWidth, int outHeight,
        boolean setWallpaper, boolean saveCroppedBitmap, Runnable onEndRunnable) {
    Log.d("rust","init after bitmapcroptask");
    mCropBounds = cropBounds;
    mRotation = rotation;	//	传入各项参数
    mOutWidth = outWidth;
    mOutHeight = outHeight;
    mSetWallpaper = setWallpaper;
    mSaveCroppedBitmap = saveCroppedBitmap;
    mOnEndRunnable = onEndRunnable;
}
// ...... 在这里处理任务，启动 cropBitmap()
@Override
protected Boolean doInBackground(Void... params) {
    return cropBitmap();
}
// ......
public boolean cropBitmap() {
    boolean failure = false;


    WallpaperManager wallpaperManager = null;
    if (mSetWallpaper) {
        wallpaperManager = WallpaperManager.getInstance(mContext.getApplicationContext());
    }


    if (mSetWallpaper && mNoCrop) {
        try {
            InputStream is = regenerateInputStream();  // 获得InputStream
            if (is != null) {
                wallpaperManager.setStream(is);	// 把is写进去，从这里进入到wallpaperManager
                Utils.closeSilently(is);
            }
        } catch (IOException e) {
            Log.w(LOGTAG, "cannot write stream to wallpaper", e);
            failure = true;
        }
        return !failure;
    } else { // 顺利的话不会进入这里
// ......
// Helper to setup input stream
private InputStream regenerateInputStream() {
    if (mInUri == null && mInResId == 0 && mInFilePath == null && mInImageBytes == null) {
        Log.w(LOGTAG, "cannot read original file, no input URI, resource ID, or " +
                "image byte array given");
    } else {
        try {
            String filepath = mInFilePath;
            if(mInUri != null){
                filepath = DrmHelper.getFilePath(mContext, mInUri);
            }
            if(DrmHelper.isDrmFile(filepath)){
                byte[] bytes = DrmHelper.getDrmImageBytes(filepath);
                return new ByteArrayInputStream(bytes);	//	返回一个ByteArray
            }
/*↑ --- (packages/apps/trebuchet/wallpaperpicker/src/com/android/launcher3) *********/
```
调用了`wallpaperManager.setStream(is)`;进入`WallpaperManager.java`看看
```java
/*↓ --- WallpaperManager.java *********/
public void setStream(InputStream data) throws IOException {  //luncher3 里直接调用了这个方法
    if (sGlobals.mService == null) {                          //WallpaperCropActivity 调用
        Log.w(TAG, "WallpaperService not running");
        return;
    }
    try {
        ParcelFileDescriptor fd = sGlobals.mService.setWallpaper(null);  // 利用service得到fd
        if (fd == null) {	// 这里要去WallpaperManagerService里找到对应方法
            return;
        }
        FileOutputStream fos = null;
        try {
            fos = new ParcelFileDescriptor.AutoCloseOutputStream(fd);
            setWallpaper(data, fos);	// 写入壁纸数据
        } finally {
            if (fos != null) {
                fos.close();
            }
        }
    } catch (RemoteException e) {
        // Ignore
    }
}
// ...... 在这里写入壁纸，写入过程结束
private void setWallpaper(InputStream data, FileOutputStream fos)  
        throws IOException {
    byte[] buffer = new byte[32768];
    int amt;
    while ((amt=data.read(buffer)) > 0) {
        fos.write(buffer, 0, amt);
    }
}
/*↑ --- (framework/base/core/java/android/app) *********/
```
Globals extends IWallpaperManagerCallback.Stub
包含成员变量 IWallpaperManager mService，通过
	Globals(Looper looper) {
        IBinder b = ServiceManager.getService(Context.WALLPAPER_SERVICE);
        mService = IWallpaperManager.Stub.asInterface(b);
    }
调用`WallpaperManagerService.java`里的setWallpaper方法
进入WallpaperManagerService看看，是如何返回ParcelFileDescriptor值的
```java
/*↓ --- WallpaperManagerService.java *********/
public ParcelFileDescriptor setWallpaper(String name) {    
    //  供 WallpaperManager 调用
    checkPermission(android.Manifest.permission.SET_WALLPAPER);
    synchronized (mLock) {
        if (DEBUG) Slog.v(TAG, "setWallpaper");
        int userId = UserHandle.getCallingUserId();
        WallpaperData wallpaper = mWallpaperMap.get(userId);
        if (wallpaper == null) {
            throw new IllegalStateException("Wallpaper not yet initialized for user " + userId);
        }
        final long ident = Binder.clearCallingIdentity();
        try {
            ParcelFileDescriptor pfd = updateWallpaperBitmapLocked(name, wallpaper);
            if (pfd != null) {// 启动下面的方法
                wallpaper.imageWallpaperPending = true;
            }
            return pfd;	// 返回ParcelFileDescriptor值给WallpaperManager
        } finally {
            Binder.restoreCallingIdentity(ident);
        }
    }
}

ParcelFileDescriptor updateWallpaperBitmapLocked(String name, WallpaperData wallpaper) {
    if (name == null) name = "";
    try {
        File dir = getWallpaperDir(wallpaper.userId);  // 找到壁纸路径
        if (!dir.exists()) {
            dir.mkdir();
            FileUtils.setPermissions(
                    dir.getPath(),
                    FileUtils.S_IRWXU|FileUtils.S_IRWXG|FileUtils.S_IXOTH,
                    -1, -1);
        }
        File file = new File(dir, WALLPAPER); //创建一个新的文件
        ParcelFileDescriptor fd = ParcelFileDescriptor.open(file,
                MODE_CREATE|MODE_READ_WRITE|MODE_TRUNCATE);
        if (!SELinux.restorecon(file)) {
            return null;
        }
        wallpaper.name = name;
        return fd;	// 返回ParcelFileDescriptor值
    } catch (FileNotFoundException e) {
        Slog.w(TAG, "Error setting wallpaper", e);
    }
    return null;
}

private static File getWallpaperDir(int userId) {  // 取得壁纸文件路径
    return Environment.getUserSystemDirectory(userId);
}
/*↑ --- (framework/base/services/core/java/com/android/server/wallpaper/) *********/
```
至此一个简单的流程就结束了

我们可反过来看

壁纸文件是存在`Environment.getUserSystemDirectory(userId)`这个路径下

`WallpaperManagerService`取到这个文件后，将其打开为ParcelFileDescriptor形式，
交给WallpaperManager

`WallpaperManager把launcher`传来的数据写入这个文件中

## 小结一下：

* 选定壁纸，点击按钮，launcher把壁纸信息给WallpaperManager；
* `WallpaperManagerService`把存放壁纸的文件打开，交给WallpaperManager
* `WallpaperManager把壁纸信息写入`；一次设置壁纸的动作就完成了
