---
title: Android 读写 CSV 文件
date: 2016-11-09 21:10:06
category: Android_note
tag: [Android_Storage]
toc: true
---

CSV: Comma-Separated Values 逗号分隔的文本文件

读写csv文件和读写普通文件类似；写的时候给数据之间添加上逗号。

设定存储路径和文件名：
```java
private static final String FILE_FOLDER =
        Environment.getExternalStorageDirectory().getAbsolutePath()
        + File.separator + "AboutView" + File.separator + "data";
private static final String FILE_CSV = "about_data.csv";
```

获取应用内的存储路径
```java
package com.rustfisher.anmediacodec;

    File appDir = getFilesDir();
    if (appDir.exists()) {
        Log.d(TAG, "appDir.exists(): " + appDir.exists());
        Log.d(TAG, "appDir.isDirectory(): " + appDir.isDirectory());
        Log.d(TAG, "getFilesDir().getAbsolutePath(): " + getFilesDir().getAbsolutePath());
        for (File c : appDir.listFiles()) {
            if (c.isDirectory()) {
                Log.d(TAG, c.getAbsolutePath() + File.separator);
            } else {
                Log.d(TAG, c.getAbsolutePath());
            }
        }
    }

// appDir.exists(): true
// appDir.isDirectory(): true
// getFilesDir().getAbsolutePath(): /data/data/com.rustfisher.anmediacodec/files
// /data/data/com.rustfisher.anmediacodec/files/a.log
// /data/data/com.rustfisher.anmediacodec/files/log_folder/
```

## 写CSV文件
使用`FileOutputStream`来向文件尾部添加数据  
`FileOutputStream.write(byte[] data)`向文件流写入字节数据。

```java
class WriteData2CSVThread extends Thread {

        short[] data;
        String fileName;
        String folder;
        StringBuilder sb;

        public WriteData2CSVThread(short[] data, String folder, String fileName) {
            this.data = data;
            this.folder = folder;
            this.fileName = fileName;
        }

        private void createFolder() {
            File fileDir = new File(folder);
            boolean hasDir = fileDir.exists();
            if (!hasDir) {
                fileDir.mkdirs();// 这里创建的是目录
            }
        }

        @Override
        public void run() {
            super.run();
            createFolder();
            File eFile = new File(folder + File.separator + fileName);
            if (!eFile.exists()) {
                try {
                    boolean newFile = eFile.createNewFile();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            try {
                FileOutputStream os = new FileOutputStream(eFile, true);
                sb = new StringBuilder();
                for (int i = 0; i < data.length; i++) {
                    sb.append(data[i]).append(",");
                }
                sb.append("\n");
                os.write(sb.toString().getBytes());
                os.flush();
                os.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

```

## 读CSV文件
使用`BufferedReader`读取每一行内容；读出来的数据带有逗号分隔符

```java
class ReadCSVThread extends Thread {

        String fileName;
        String folder;

        public ReadCSVThread(String folder, String fileName) {
            this.folder = folder;
            this.fileName = fileName;
        }

        @Override
        public void run() {
            super.run();
            File inFile = new File(folder + File.separator + fileName);
            final StringBuilder cSb = new StringBuilder();
            String inString;
            try {
                BufferedReader reader =
                    new BufferedReader(new FileReader(inFile));
                while ((inString = reader.readLine()) != null) {
                    cSb.append(inString).append("\n");
                }
                reader.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mCSVTv.setText(cSb.toString());// 显示
                }
            });
        }

    }
```
