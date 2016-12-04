---
title: Java 读写xls文件
date: 2017-04-18 22:18:02
category: Java_note
tag: [Java]
toc: true
---

* win7_x64
* IDEA

# Java读写xls文件，使用库`jxl.jar`
读写xls文件，这里是在知道表格格式的前提下进行操作的。  
目前无法操作xlsx文件

## 准备工作
将库`jxl.jar`添加到工程依赖中  

## Java代码示例
### 示例：从几个文件中读取数据并汇总到一个文件中

表格中的数据规定为：首行为标题，以下是数据和名称；例如
```
单位名	金额
单位1	948.34
单位2	4324
单位5	324
```

准备好表格文件，放在指定目录下

示例过程大致为：在指定目录找到所有xls文件；遍历所有文件，读取
出所有的单位名称；将单位名称排序；再遍历一次所有文件，将每个
文件中单位对应的金额读出并存储；最后写到输出表格中。

```java
final String wsFileDir = "H:/OtherWorkDocs/ws"; // 原始数据存放的目录
final String resFilePath = "H:/OtherWorkDocs/output/jan_feb_mar_sum.xls";
RWExcel rwExcel = new RWExcel(); // 操作xls的实例
// 获取所有的名称并排序
TreeSet<String> nameSet = rwExcel.getNameSet(wsFileDir);
// 将名称与下标存入map中
HashMap<String, Integer> nameRowHashMap = rwExcel.getNameRowHashMap(nameSet);

File wsDir = new File(wsFileDir); // 源文件目录
File[] sourceFiles = wsDir.listFiles();

// 存储单位名称与金额对应的数据
List<HashMap<String, Float>> dataList = new ArrayList<>(10);
if (sourceFiles != null) {
    for (File sF : sourceFiles) {
        // 装载数据
        dataList.add(rwExcel.getSourceData(sF.getAbsolutePath()));
    }
}
// 原始数据已经全部读出来，和名称一次性全部写入
rwExcel.writeAllToResFile(resFilePath, nameRowHashMap, dataList);

// 补充标题栏的标题
if (null != sourceFiles) {
    int col = 1; // 起始列的序号
    for (File f : sourceFiles) {
        String fileName = f.getName();
        String name = fileName.substring(0, fileName.length() - 4);
        rwExcel.updateContent(resFilePath, name, 0, col);
        col++;
    }
}
```

#### Java代码
新建一个类`RWExcel`来操作xls文件。
```java
public class RWExcel {

    /**
     * 存储名称
     */
    private TreeSet<String> nameTreeSet = new TreeSet<>();

    /**
     * 名称以及排列的下标号
     */
    private HashMap<String, Integer> nameRowMap = new HashMap<>();

    public TreeSet<String> getNameSet(String wsPath) {
        try {
            File wsDir = new File(wsPath);
            if (wsDir.exists() && wsDir.isDirectory()) {
                println("工作目录存在");
                File[] files = wsDir.listFiles();
                if (files != null && files.length > 0) {
                    for (File cFile : files) {
                        getNamesFromFile(cFile, this.nameTreeSet);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        this.nameTreeSet.comparator();
        return this.nameTreeSet;
    }

    /**
     * 将名称Set排序后存入HashMap
     * 下标从1开始
     */
    public HashMap<String, Integer> getNameRowHashMap(TreeSet<String> nameSet) {
        nameSet.comparator();
        int index = 1;
        for (String name : nameSet) {
            this.nameRowMap.put(name, index);
            index++;
        }
        return this.nameRowMap;
    }

    /**
     * 所有数据存入表格
     */
    public void writeAllToResFile(String resFilePath, Map<String, Integer> nameMap, List<HashMap<String, Float>> dataList) {
        File resFile = new File(resFilePath);
        if (!resFile.exists()) {
            try {
                resFile.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        if (resFile.exists()) {
            try {
                // 先写名称
                WritableWorkbook wwb = Workbook.createWorkbook(resFile);
                WritableSheet ws = wwb.createSheet("sum", 0);
                Label label = new Label(0, 0, "单位名称");
                ws.addCell(label);
                for (Map.Entry<String, Integer> entry : nameMap.entrySet()) {
                    Label nameLabel = new Label(0, entry.getValue(), entry.getKey());
                    ws.addCell(nameLabel);
                    for (int j = 0; j < dataList.size(); j++) {
                        Number zeroCell = new Number(j + 1, entry.getValue(), 0);
                        ws.addCell(zeroCell);
                    }
                }

                for (int dataColumn = 0; dataColumn < dataList.size(); dataColumn++) {
                    HashMap<String, Float> dataMap = dataList.get(dataColumn);
                    // 遍历这个map 将所有的数据对应填入
                    for (Map.Entry<String, Float> dataEntry : dataMap.entrySet()) {
                        int row = nameRowMap.get(dataEntry.getKey());
                        Number numberCell = new Number(dataColumn + 1, row, dataEntry.getValue());
                        ws.addCell(numberCell);
                    }
                }
                wwb.write();
                wwb.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void getNamesFromFile(File inputFile, TreeSet<String> hashSet) throws IOException, BiffException {
        Workbook workbook;
        InputStream is = new FileInputStream(inputFile);
        workbook = Workbook.getWorkbook(is);
        Sheet sheet0 = workbook.getSheet(0);
        int columnSum = sheet0.getColumns(); // 总列数
        int rsRows = sheet0.getRows();       // 总行数

        // 从1下标开始
        for (int i = 1; i < rsRows; i++) {
            Cell cell = sheet0.getCell(0, i);
            if (!isEmpty(cell.getContents())) {
                hashSet.add(cell.getContents());
            }
        }
        println("此文件行数减一 = " + (rsRows - 1) + " , 当前获取到的所有单位数    " + hashSet.size());
    }

    /**
     * 从原始数据中读取并匹配的存入结果文件中
     */
    private HashMap<String, Float> getSourceData(String source) {
        File sFile = new File(source);
        if (!sFile.exists()) {
            System.out.println("原始文件不存在  复制失败!");
            return null;
        }
        // 读取源文件中的所有数据 <单位名称, 数值>
        HashMap<String, Float> sourceHashMap = new HashMap<>();
        try {
            Workbook sourceWs = Workbook.getWorkbook(sFile);
            Sheet sSheet0 = sourceWs.getSheet(0);
            int sTotalRows = sSheet0.getRows();       // 总行数
            for (int i = 1; i < sTotalRows; i++) {
                Cell cellKey = sSheet0.getCell(0, i);
                Cell cellValue = sSheet0.getCell(1, i);
                if (!isEmpty(cellKey.getContents()) && !isEmpty(cellValue.getContents())) {
                    sourceHashMap.put(cellKey.getContents(), Float.valueOf(cellValue.getContents()));
                }
            }
            println(source + " 读取到的数据数量 = " + sourceHashMap.size());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return sourceHashMap;
    }

    public void updateContent(String filePath, String input, int row, int column) {
        File file = new File(filePath);
        if (!file.exists()) {
            System.out.println(filePath + " does not exist!");
            return;
        }
        try {
            Workbook sourceWb = Workbook.getWorkbook(file);
            WritableWorkbook wwb = Workbook.createWorkbook(file, sourceWb);
            WritableSheet wSheet0 = wwb.getSheet(0);
            Label label = new Label(column, row, input);
            wSheet0.addCell(label);
            wwb.write();
            wwb.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public RWExcel() {

    }

    private static boolean isEmpty(String str) {
        if (null == str) {
            return true;
        }
        return str.isEmpty();
    }

    private static void println(String in) {
        System.out.println(in);
    }

}
```

#### 示例运行结果
得到以下结果（示例）
```
单位名称	1月总金额	2月总金额	3月总金额
单位1	0	59.29999924	948.3400269
单位10	0	0	494.2000122
单位11	0	0	11.19999981
单位12	0	0	1.25
单位15	49.36000061	0	0
单位2	0	0	4324
单位24	0	34	0
单位5	0	23123	324
单位6	0	161.2599945	0
```
