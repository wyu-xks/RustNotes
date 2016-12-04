---
title: Python3.x 读写csv文件中的数字
date: 2016-12-27 18:55:20
category: Python
---

Win7  Python3.6

## 读写csv文件

读文件时先产生str的列表，把最后的换行符删掉；然后一个个str转换成int
```python
## 读写csv文件
csv_file = 'datas.csv'

csv = open(csv_file,'w')
for i in range(1,20):
    csv.write(str(i) + ',')
    if i % 10 == 0:
        csv.write('\n')
csv.close()

result = []
with open(csv_file,'r') as f:
    for line in f:
        linelist = line.split(',')
        linelist.pop()# delete: \n
        for index, item in enumerate(linelist):
            result.append(int(item))
print('\nResult is \n' , result)
```

输出：
```
Result is
 [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]
```

### 检查目录是否存在
若目标目录不存在，则新建一个目录
```py
import os
json_dir = "../dir_json/2017-04/"
if not os.path.exists(json_dir):
    print("json dir not found")
    os.makedirs(json_dir)
    print("Create dir  " + json_dir)
```

### 写文件时指定格式
参考下面的代码，打开文件时指定utf8，转换成json时指定`ensure_ascii=False`  
```py
import json
json_file = open(json_dir + id + '.json', 'w', encoding='utf8')
json_file.write(json.dumps(data_dict, ensure_ascii=False))
```
避免写成的json文件乱码

### 函数 enumerate(iterable, start=0)
返回一个enumerate对象。iterable必须是一个句子，迭代器或者支持迭代的对象。

enumerate示例1：
```
>>> data = [1,2,3]
>>> for i, item in enumerate(data):
	print(i,item)


0 1
1 2
2 3
```
示例2：
```
>>> line = 'one'
>>> for i, item in enumerate(line,4):
	print(i,item)


4 o
5 n
6 e
```
参考： https://docs.python.org/3/library/functions.html?highlight=enumerate#enumerate

### class int(x=0)
class int(x, base=10)  
返回一个Integer对象。对于浮点数，会截取成整数。
```
>>> print(int('-100'),int('0'),int('3'))
-100 0 3
>>> int(7788)
7788
>>> int(7.98)
7
>>> int('2.33')
Traceback (most recent call last):
  File "<pyshell#27>", line 1, in <module>
    int('2.33')
ValueError: invalid literal for int() with base 10: '2.33'
```

## 读取binary文件
逐个byte读取，注意用`b''`来判断是否读到文件尾部
```python
    @staticmethod
    def convert_bin_to_csv(bin_file_path, csv_file_path):
        if not os.path.exists(bin_file_path):
            print("Binary file is not exist! " + bin_file_path)
            return
        with open(bin_file_path, "rb") as bin_f:
            cur_byte = bin_f.read(1)
            while cur_byte != b'':
                # Do stuff with byte.
                print(int.from_bytes(cur_byte, byteorder='big', signed=True))
                cur_byte = bin_f.read(1)
```

读取到的byte可以转换为int，[参考文档](https://docs.python.org/3/library/stdtypes.html#int.from_bytes)

这里 `cur_byte` 类似于 `b'\x08'`
```python
print(int.from_bytes(cur_byte, byteorder='big', signed=True))
```

### 从bin中读取数据并存入CSV文件中
先从bin中读取byte，规定好几个字节凑成1个数字。  
按每行一个数字的格式写入CSV文件。

```python
    @staticmethod
    def convert_bin_to_csv(bin_file_path, csv_file_path, byte_count=1, byte_order='big', digit_signed=True):
        if not os.path.exists(bin_file_path):
            print("Binary file is not exist! " + bin_file_path)
            return
        with open(csv_file_path, "w") as csv_f:
            with open(bin_file_path, "rb") as bin_f:
                cur_byte = bin_f.read(byte_count)
                while cur_byte != b'':
                    csv_f.write(str(int.from_bytes(cur_byte, byteorder=byte_order, signed=digit_signed)) + ",\n")
                    cur_byte = bin_f.read(byte_count)

```

bin存储的数据格式一定要商量好。
