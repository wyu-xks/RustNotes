---
title: Android Bitmap 相关操作
date: 2015-10-27 15:09:32
category: Android_note
tag: [Android_UI]
---

常见的几个操作：缩放，裁剪，旋转，偏移

效果图：

![b1](https://raw.githubusercontent.com/RustFisher/imagesRaw/master/demo_images/bitmap1.jpg)  ![b2](https://raw.githubusercontent.com/RustFisher/imagesRaw/master/demo_images/bitmap2.jpg)  ![b3](https://raw.githubusercontent.com/RustFisher/imagesRaw/master/demo_images/bitmap3.jpg)  ![b4](https://raw.githubusercontent.com/RustFisher/imagesRaw/master/demo_images/bitmap4.jpg)  ![b5](https://raw.githubusercontent.com/RustFisher/imagesRaw/master/demo_images/bitmap5.jpg)


很多操作需要 Matrix 来支持；Matrix 通过矩阵来处理位图，计算出各个像素点的位置，从而把bitmap显示出来。  
matrix里有一个3x3的矩阵，用于图像处理：  
```
MSCALE_X MSKEW_X  MTRANS_X
MSKEW_Y  MSCALE_Y MTRANS_Y
MPERSP_0 MPERSP_1 MPERSP_2
```
根据变量名能猜出具体的用途：
```
缩放X 偏移X 平移X
偏移Y 缩放Y 平移Y
透视0 透视1 透视2
```
matrix的操作有set，pre和post；set能够直接设置矩阵中的数值；pre类似于矩阵左乘；post类似与矩阵中的右乘

原bitmap经过计算后，会重新生成一张bitmap

代码片段：
```java
    /**
     * 根据给定的宽和高进行拉伸
     *
     * @param origin    原图
     * @param newWidth  新图的宽
     * @param newHeight 新图的高
     * @return new Bitmap
     */
    private Bitmap scaleBitmap(Bitmap origin, int newWidth, int newHeight) {
        if (origin == null) {
            return null;
        }
        int height = origin.getHeight();
        int width = origin.getWidth();
        float scaleWidth = ((float) newWidth) / width;
        float scaleHeight = ((float) newHeight) / height;
        Matrix matrix = new Matrix();
        matrix.postScale(scaleWidth, scaleHeight);// 使用后乘
        Bitmap newBM = Bitmap.createBitmap(origin, 0, 0, width, height, matrix, false);
        if (!origin.isRecycled()) {
            origin.recycle();
        }
        return newBM;
    }

    /**
     * 按比例缩放图片
     *
     * @param origin 原图
     * @param ratio  比例
     * @return 新的bitmap
     */
    private Bitmap scaleBitmap(Bitmap origin, float ratio) {
        if (origin == null) {
            return null;
        }
        int width = origin.getWidth();
        int height = origin.getHeight();
        Matrix matrix = new Matrix();
        matrix.preScale(ratio, ratio);
        Bitmap newBM = Bitmap.createBitmap(origin, 0, 0, width, height, matrix, false);
        if (newBM.equals(origin)) {
            return newBM;
        }
        origin.recycle();
        return newBM;
    }

    /**
     * 裁剪
     *
     * @param bitmap 原图
     * @return 裁剪后的图像
     */
    private Bitmap cropBitmap(Bitmap bitmap) {
        int w = bitmap.getWidth(); // 得到图片的宽，高
        int h = bitmap.getHeight();
        int cropWidth = w >= h ? h : w;// 裁切后所取的正方形区域边长
        cropWidth /= 2;
        int cropHeight = (int) (cropWidth / 1.2);
        return Bitmap.createBitmap(bitmap, w / 3, 0, cropWidth, cropHeight, null, false);
    }

    /**
     * 选择变换
     *
     * @param origin 原图
     * @param alpha  旋转角度，可正可负
     * @return 旋转后的图片
     */
    private Bitmap rotateBitmap(Bitmap origin, float alpha) {
        if (origin == null) {
            return null;
        }
        int width = origin.getWidth();
        int height = origin.getHeight();
        Matrix matrix = new Matrix();
        matrix.setRotate(alpha);
        // 围绕原地进行旋转
        Bitmap newBM = Bitmap.createBitmap(origin, 0, 0, width, height, matrix, false);
        if (newBM.equals(origin)) {
            return newBM;
        }
        origin.recycle();
        return newBM;
    }

    /**
     * 偏移效果
     * @param origin 原图
     * @return 偏移后的bitmap
     */
    private Bitmap skewBitmap(Bitmap origin) {
        if (origin == null) {
            return null;
        }
        int width = origin.getWidth();
        int height = origin.getHeight();
        Matrix matrix = new Matrix();
        matrix.postSkew(-0.6f, -0.3f);
        Bitmap newBM = Bitmap.createBitmap(origin, 0, 0, width, height, matrix, false);
        if (newBM.equals(origin)) {
            return newBM;
        }
        origin.recycle();
        return newBM;
    }

```

按钮的操作定义：
```java
    @Override
    public void onClick(View v) {
        Bitmap originBM = BitmapFactory.decodeResource(getResources(),
                R.drawable.littleboygreen_x128);
        switch (v.getId()) {
            case R.id.btn1: {// 按尺寸缩放
                effectTextView.setText(R.string.scale);
                Bitmap nBM = scaleBitmap(originBM, 100, 72);
                effectView.setImageBitmap(nBM);
                break;
            }
            case R.id.btn2: {// 按比例缩放，每次点击缩放比例都会不同
                effectTextView.setText(R.string.scale_ratio);
                if (ratio < 3) {
                    ratio += 0.05f;
                } else {
                    ratio = 0.1f;
                }
                Bitmap nBM = scaleBitmap(originBM, ratio);
                effectView.setImageBitmap(nBM);
                break;
            }
            case R.id.btn3: {// 裁剪
                effectTextView.setText("剪个头");
                Bitmap cropBitmap = cropBitmap(originBM);
                effectView.setImageBitmap(cropBitmap);
                break;
            }
            case R.id.btn4: {// 顺时针旋转效果；每次点击更新旋转角度
                if (alpha < 345) {
                    alpha += 15;
                } else {
                    alpha = 0;
                }
                effectTextView.setText("旋转");
                Bitmap rotateBitmap = rotateBitmap(originBM, alpha);
                effectView.setImageBitmap(rotateBitmap);
                break;
            }
            case R.id.btn5: {// 逆时针旋转效果；每次点击更新旋转角度
                if (beta > 15) {
                    beta -= 15;
                } else {
                    beta = 360;
                }
                effectTextView.setText("旋转");
                Bitmap rotateBitmap = rotateBitmap(originBM, beta);
                effectView.setImageBitmap(rotateBitmap);
                break;
            }
            case R.id.btn6: {// 偏移效果；偏移量在方法中
                Bitmap skewBM = skewBitmap(originBM);
                effectView.setImageBitmap(skewBM);
                break;
            }
        }
    }
```
## 遇到的问题

```java
        Matrix matrix = new Matrix();
        matrix.preScale(ratio, ratio);// 当 ratio=1，下面的 newBM 将会等价于 origin
        Bitmap newBM = Bitmap.createBitmap(origin, 0, 0, width, height, matrix, false);
        if (!origin.isRecycled()) {
            origin.recycle();
        }
```
log如下，当ratio=1时，新bitmap和旧的bitmap同一地址
```log
11-27 05:27:16.086 16723-16723/? D/rust: originBitmap = android.graphics.Bitmap@1e8849e
11-27 05:27:16.086 16723-16723/? D/rust: newBitmap = android.graphics.Bitmap@1e8849e
```
