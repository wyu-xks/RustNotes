---
title: Android 读写二进制文件
date: 2016-11-01 21:10:06
category: Android_note
tag: [Android_Storage]
toc: true
---

以流的形式来读写文件

## 写文件

主要代码：

```java
DataOutputStream os = new DataOutputStream(new FileOutputStream(file, true));
```
这里的true表示在文件尾追加数据。  
写二进制文件时，文件路径和文件名分开传递。如果路径不存在，则用`mkdirs()`创建；若
文件不存在，用`createNewFile()`来创建新文件。

`DataOutputStream`的写数据方法各有不同(以Galaxy Note4为例)  
* `writeByte` 写入1个字节

* `writeInt` 写入4个字节 big-endian

* `writeFloat` 写入4个字节 使用 Float 类中的 floatToIntBits 方法将 float 参数转换
为一个 int 值，然后将该 int 值以 4-byte 值形式写入基础输出流中，先写入高字节。
如果没有抛出异常，则计数器 written 增加 4。

* `writeDouble` 使用 Double 类中的 doubleToLongBits 方法将 double 参数转换为一个 long 值，然后将该 long 值以 8-byte 值形式写入基础输出流中，先写入高字节。如果没有抛出异常，则计数器 written 增加 8。

其他方法可以参见`DataOutputStream`的API文档

```java
class SaveHexFileThread extends Thread {
    private int mmValue1;
    private int mmValue2;
    private int mmValue3;
    private String mmDir;
    private String mmName;
    private HEX_TYPE type;

    // 文件路径和文件名分开传送
    public SaveHexFileThread(HEX_TYPE type, int v1, int v2, int v3,
                             String dir, String name) {
        this.mmValue1 = v1;
        this.mmValue2 = v2;
        this.mmValue3 = v3;
        mmDir = dir;
        mmName = name;
        this.type = type;
    }

    public void saveData() {
        try {
            File file = new File(mmDir + File.separator + mmName);
            if (!file.exists()) {
                boolean newFile = file.createNewFile();
                Log.d(TAG, "创建新文件 " + file.getName() + " " + newFile);
            }
            DataOutputStream os = new DataOutputStream(new FileOutputStream(file, true));
            switch (type) {
                case BYTE:
                    os.writeByte(mmValue1);
                    os.writeByte(mmValue2);
                    os.writeByte(mmValue3);
                    break;
                case INT:
                    os.writeInt(mmValue1);
                    os.writeInt(mmValue2);
                    os.writeInt(mmValue3);
                    break;
                case FLOAT:
                    os.writeFloat(mmValue1);
                    os.writeFloat(mmValue2);
                    os.writeFloat(mmValue3);
                    break;
                case DOUBLE:
                    os.writeDouble(mmValue1);
                    os.writeDouble(mmValue2);
                    os.writeDouble(mmValue3);
                    break;
            }
            os.close();
        } catch (IOException ioe) {
            Log.e(TAG, "write data error ", ioe);
        }
    }

    private void createFiles() {
        File fileDir = new File(mmDir);
        boolean hasDir = fileDir.exists();
        if (!hasDir) {
            fileDir.mkdirs();// 这里创建的是目录
        }
    }

    @Override
    public void run() {
        super.run();
        createFiles();
        saveData();
        new ReadAllHexThread(mmDir).start();
    }
}

```

## 读取文件
以什么形式写的文件，就以什么形式读取。以免弄错数据。  
使用`DataInputStream`来读取数据，拼接后显示出来。  
关键代码：
```java
File file = new File(mmDir + File.separator + fileName);
try {
    if (file.exists()) {
        DataInputStream is = new DataInputStream(new FileInputStream(file));
        int readRes = is.read(dataBuffer);
        StringBuilder contentBuilder = new StringBuilder(type.toString());
        contentBuilder.append(": \n");
        for (int i = 0; i < readRes; i++) {
            contentBuilder.append(Integer.toHexString(dataBuffer[i] & 0xff));
            contentBuilder.append(", ");
        }
        final String finalContent = contentBuilder.toString();
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                // update UI
            }
        });
    } else {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                // update UI
            }
        });
    }
} catch (Exception e) {
    e.printStackTrace();
}
```

## 示例图片
![demo](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Android_note/pics/read_write_hex.jpg)  

可以把二进制文件复制到电脑上，用软件（例如Hex Editor Neo）来查看里面的数据。
