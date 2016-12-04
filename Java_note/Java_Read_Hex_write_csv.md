---
title: Java 读取二进制文件
date: 2017-02-16 22:11:39
category: Java_note
tag: [Java]
---

win7, IntelliJ IDEA

### 读Hex写CSV

data目录下有little-endian bin文件，2个字节代表一个数字。  
bin存储的数据格式可自己定义。相同的方法可以直接应用到Android中。

```
`-- networkProj
    |-- data
    |-- networkProj.iml
    |-- out
    `-- src
```

实现方法

```java
private static void convertFiles() {
    File folder = new File("data"); // data folder
    log("--------- Read little-endian data from bin file ---------");
    if (!folder.exists()) {
        log("folder is not exist!");
        return;
    }
    File outputFolder = new File(folder.getAbsolutePath() + File.separator + "output");
    if (!outputFolder.exists()) {
        boolean newOutput = outputFolder.mkdir();
        log("New output folder  " + newOutput);
    }
    File[] files = folder.listFiles();
    if (files != null) {
        log("folder is  " + folder.getAbsolutePath());
        for (File f : files) {
            log("\t" + f.getName());
        }
    } else {
        log("Nothing in this folder");
        return;
    }

    for (File currentFile : files) {
        if (!currentFile.isFile()) {
            return;
        }
        String fileName = currentFile.getName();
        fileName = fileName.substring(0, fileName.length() - 4); // delete suffix
        File csvFile = new File(outputFolder.getAbsolutePath() + File.separator + fileName + ".csv");
        if (csvFile.exists()) {
            boolean deRes = csvFile.delete();
            log("Delete old csv: " + deRes);
        }
        byte[] readBytes = new byte[512];
        try {
            boolean newCsv = csvFile.createNewFile();
            log(csvFile.getAbsolutePath() + " " + newCsv);
            FileOutputStream csvFos = new FileOutputStream(csvFile);
            InputStream in = new FileInputStream(currentFile);
            while (in.read(readBytes) != -1) {
                int[] csvData = convertBytesToInts(readBytes);
                for (int d : csvData) {
                    csvFos.write(String.valueOf(d).getBytes());
                    csvFos.write("\n".getBytes());
                }
            }
            csvFos.flush();
            csvFos.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

// little-endian; 2 bytes -> 1 int
private static int[] convertBytesToInts(byte[] inputData) {
    int[] rawData = new int[inputData.length / 2];
    int rawIndex = 0;
    for (int i = 0; i < inputData.length; i += 2) {
        int raw = (0xff & inputData[i + 1]) * 256 + (0xff & inputData[i]);
        if (raw >= 32768) {
            raw -= 65536;
        }
        rawData[rawIndex] = raw;
        rawIndex++;
    }
    return rawData;
}

private static void log(String l) {
    System.out.println(l);
}
```

控制台输出

```
--------- Read little-endian data from bin file ---------
New output folder  true
folder is  G:\javaProj\networkProj\data
	data20170215_180621.bin
	output
G:\javaProj\networkProj\data\output\data20170215_180621.csv true
```


