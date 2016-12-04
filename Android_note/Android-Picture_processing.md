---
title: Android 图片处理
date: 2018-03-12 22:19:57
category: Android_note
tag: [Android_UI]
toc: true
---

Android中的图片处理。
例如我们需要读取一张JPEG文件，缩放后保存到原路径。

先读取JPEG文件得到bitmap，使用Matrix对bitmap进行缩放后，再写入文件中。

### 缩放JPEG文件
读取JPEG文件得到bitmap，进行缩放操作；最后将缩放完毕的bitmap写入原路径。
这些操作可以在子线程中完成。
```java
    /**
     * 读取路径中的图片，然后将其转化为缩放后的bitmap
     */
    public static void scalePicSize(String path) {
        final float PIC_SCALE_RATIO = 1.5F; // 缩放倍数
        Bitmap bitmap = BitmapFactory.decodeFile(path);
        Matrix matrix = new Matrix();
        matrix.postScale(PIC_SCALE_RATIO, PIC_SCALE_RATIO); // 长和宽放大缩小的比例
        Bitmap resizeBmp = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
        saveAsJPGE(resizeBmp, path);
    }

    /**
     * 保存图片为JPEG
     */
    private static void saveAsJPGE(Bitmap bitmap, String path) {
        File file = new File(path);
        try {
            FileOutputStream out = new FileOutputStream(file);
            if (bitmap.compress(Bitmap.CompressFormat.JPEG, 100, out)) {
                out.flush();
                out.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
```