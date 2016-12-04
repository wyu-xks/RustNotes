---
title: Python 操作 MySQL
date: 2017-05-25 22:31:21
category: Python
tag: [MySQL]
toc: true
---

Python 操作 MySQL  
配置
* win_64
* Ubuntu14.04
* Python3.x

### pip安装pymysql模块
直接使用pip安装 `pip install pymysql`  
win64上直接在cmd中执行

### 连接本地数据库
使用模块`pymysql`连接数据库  
本地数据库相关配置请参阅： http://rustfisher.github.io/2017/02/25/backend/MySQL_install/

```py
#!/usr/bin/python
# coding=utf-8
import pymysql

# 连接本地数据库
conn = pymysql.connect(host='localhost', port=3306, user='root', passwd='a123', db='samp_db1', charset='utf8')
cursor = conn.cursor()
cursor.execute('select * from bigstu')
for row in cursor.fetchall():
    print(row)

# 查
cursor.execute('select id, name from bigstu where age > 22')
for res in cursor.fetchall():
    print(str(res[0]) + ", " + res[1])

cursor.close()
print('-- end --')
```

输出：
```
(1, '张三', '男', 24, datetime.date(2017, 3, 29), '13666665555')
(6, '小刚', '男', 23, datetime.date(2017, 3, 11), '778899888')
(8, '小霞', '女', 20, datetime.date(2017, 3, 13), '13712345678')
(12, '小智', '男', 21, datetime.date(2017, 3, 7), '13787654321')
1, 张三
6, 小刚
-- end --
```

可以直接执行sql语句。获得的结果是元组。

### 增
#### 插入数据
插入一条数据，接上面的代码

```py
insertSql = "insert into bigstu (name, sex, age,  mobile) values ('%s','%s',%d,'%s') "
xiuji = ('秀吉', '男', 15, '13400001111')
cursor.execute(insertSql % xiuji)
conn.commit() # 别忘了提交
```

#### 添加列
在mobile后面添加一列cash
```py
addCo = "alter table bigstu add cash int after mobile"
cursor.execute(addCo)
```

如果要设置默认值
```py
addCo = "alter table bigstu add cash int default 0 after mobile"
cursor.execute(addCo)
```

### 删
#### 删除数据
删除 name=秀吉 的数据
```py
deleteSql = "delete from bigstu where name = '%s'"
cursor.execute(deleteSql % '秀吉')
```

#### 删除列
删除cash列
```py
dropCo = "alter table bigstu drop cash"
cursor.execute(dropCo)
```

### 改
#### 修改数据
更新符合条件的数据

```py
updateSql = "update bigstu set sex = '%s' where name = '%s'"
updateXiuji = ('秀吉', '秀吉') # 秀吉的性别是秀吉
cursor.execute(updateSql % updateXiuji)
conn.commit()
```

### 事物处理
给某个记录的cash增加
```py
table = "bigstu"
addCash = "update " + table + " set cash = cash + '%d' where name = '%s'"
lucky = (1000, "秀吉")

try:
    cursor.execute(addCash % lucky)
except Exception as e:
    conn.rollback()
    print("加钱失败了")
else:
    conn.commit()
```

直接执行SQL语句，十分方便


## 代码片段
### 给数据库添加列
从json中读取需要添加的列名，获取当前2个表中所有的列名  
整理得出需要插入的列名，然后将列插入到相应的表中

```py
import pymysql
import json
import os
import secureUtils

mapping_keys = json.load(open("key_mapping_db.json", "r"))
db_keys = []  # json中所有的key

for k in mapping_keys.values():
    db_keys.append(k)

conn = pymysql.connect(host='localhost', port=3306, user='root',
                       passwd='*****', db='db_name', charset='utf8')

cursor = conn.cursor()
table_main = "table_main"
main_table_keys = []  # 主表的列名
cursor.execute("show columns from " + table_main)
for row in cursor.fetchall():
    main_table_keys.append(row[0])

staff_table_keys = []
cursor.execute("show columns from table_second")
for row in cursor.fetchall():
    staff_table_keys.append(row[0])

need_to_insert_keys = []
for k in db_keys:
    if k not in staff_table_keys and k not in main_table_keys and k not in need_to_insert_keys:
        need_to_insert_keys.append(k)

print("need to insert " + str(len(need_to_insert_keys)))
print(need_to_insert_keys)
for kn in need_to_insert_keys:
    print("add key to db " + kn)
    cursor.execute("alter table staff_table add " + kn +" text")

conn.close()
```

### 将字段字符改变
这里将main_table_keys中的所有字段改为utf8
```py
# change column character set to utf8
for co in main_table_keys:
    change_sql = "alter table " + table_main + " modify " + co + " text character set utf8"
    print(change_sql)
    cursor.execute(change_sql)
```

