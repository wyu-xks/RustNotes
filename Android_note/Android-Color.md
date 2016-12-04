---
title: Android Color
date: 2017-09-23 12:13:13
category: Android_note
tag: [Android]
---

在Android开发中，可以使用`Color.argb()`来获得color的int值。

这个4字节的数字，从高位到地位分别代表alpha，red，green，blue。

于是我们可以从这个int中取出我们感兴趣的某个值。
`Color`类已经提供了一些方法，例如计算出red值`Color.red(int)`。

方法实例：
```java
    private int[] colorIntToArgb(int color) {
        int[] argb = new int[]{0, 0, 0, 0};
        argb[0] = Color.alpha(color);
        argb[1] = Color.red(color);
        argb[2] = Color.green(color);
        argb[3] = Color.blue(color);
        return argb;
    }

    private int[] colorInt2Argb(int colorInt) {
        int[] argb = new int[]{0, 0, 0, 0};
        argb[0] = (colorInt & 0xff000000) >>> 24;  // alpha
        argb[1] = (colorInt & 0x00ff0000) >> 16;   // red
        argb[2] = (colorInt & 0x0000ff00) >> 8;    // green
        argb[3] = (colorInt & 0x000000ff);         // blue
        return argb;
    }
```

测试代码
```java
    private void colorInfo() {
        int color1 = Color.RED;
        int color2 = Color.GREEN;
        int color3 = Color.CYAN;
        int color4 = Color.DKGRAY;
        Log.d(TAG, "color1: " + color1 + ", " + Integer.toHexString(color1) + ", " +
                Arrays.toString(colorIntToArgb(color1)) + "," + Arrays.toString(colorInt2Argb(color1)));
        Log.d(TAG, "color2: " + color2 + ", " + Integer.toHexString(color2) + ", " +
                Arrays.toString(colorIntToArgb(color2)) + "," + Arrays.toString(colorInt2Argb(color2)));
        Log.d(TAG, "color3: " + color3 + ", " + Integer.toHexString(color3) + ", " +
                Arrays.toString(colorIntToArgb(color3)) + "," + Arrays.toString(colorInt2Argb(color3)));
        Log.d(TAG, "color4: " + color4 + ", " + Integer.toHexString(color4) + ", " +
                Arrays.toString(colorIntToArgb(color4)) + "," + Arrays.toString(colorInt2Argb(color4)));
    }

    /*
color1: -65536, ffff0000, [255, 255, 0, 0],[255, 255, 0, 0]
color2: -16711936, ff00ff00, [255, 0, 255, 0],[255, 0, 255, 0]
color3: -16711681, ff00ffff, [255, 0, 255, 255],[255, 0, 255, 255]
color4: -12303292, ff444444, [255, 68, 68, 68],[255, 68, 68, 68]
    */
```

Android中Color封装（API25）的方法如下
```java
    /**
     * Return the alpha component of a color int. This is the same as saying
     * color >>> 24
     */
    public static int alpha(int color) {
        return color >>> 24;
    }

    /**
     * Return the red component of a color int. This is the same as saying
     * (color >> 16) & 0xFF
     */
    public static int red(int color) {
        return (color >> 16) & 0xFF;
    }

    /**
     * Return the green component of a color int. This is the same as saying
     * (color >> 8) & 0xFF
     */
    public static int green(int color) {
        return (color >> 8) & 0xFF;
    }

    /**
     * Return the blue component of a color int. This is the same as saying
     * color & 0xFF
     */
    public static int blue(int color) {
        return color & 0xFF;
    }

```
