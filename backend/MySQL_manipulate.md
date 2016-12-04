---
title: MySQL使用 - win7_x64
date: 2017-02-25 18:20:01
category: Database
tag: [MySQL]
toc: true
---

环境： win7_x64， Navicat for MySQL


前面已经将MySQL服务跑起来了。

现在我们以root身份进行MySQL操作  
进入MySQL
```
C:\Users\Administrator>mysql -uroot -p
```

### 新建数据库

```
mysql> create database samp_db1 character set gbk;
Query OK, 1 row affected (0.00 sec)
```
数据库字符编码指定为 gbk

### 选择要操作的数据库
已经登录后可以直接选择数据库

```
mysql> use samp_db1;
Database changed
```

#### 创建数据表
以建立person_t数据表为例
```
mysql> create table person_t (
    -> id int unsigned not null auto_increment primary key,
    -> name char(14) not null,
    -> sex char(4) not null,
    -> age tinyint unsigned not null,
    -> tell char(13) null default "-"
    -> );
Query OK, 0 rows affected (0.22 sec)
```
打开Navicat for MySQL，可以看到我们新建的表

输入这么长的文本很容易出错，我们可以直接先写好SQL语句，再导进来

新建文件`create_student_table.sql`，输入SQL语句

```
create table student (
id int unsigned not null auto_increment primary key,
name char(14) not null,
sex char(4) not null,
age tinyint unsigned not null,
tell char(13) null default "-"
);
```

直接执行SQL文件，操作samp_db1数据库
```
C:\Users\Administrator>mysql -D samp_db1 -u root -p < H:\create_student_table.sq
l
Enter password: ****
```

#### 操作数据库
选定要操作的数据库`use samp_db1;`

##### 增 - 插入数据
insert [into] 表名 [(列名1, 列名2, 列名3, ...)] values (值1, 值2, 值3, ...);

```
mysql> insert into student values(null,"张三","男",23,"13666665555");
mysql> insert into student (name,sex,age) values("李四","女",20);
```

##### 查 - 查询表中的数据
select 列名称 from 表名称 [查询条件];

多插入了一些数据后

```
mysql> select name, age from student;
+-------+-----+
| name  | age |
+-------+-----+
| 张三  |  23 |
| 李四  |  20 |
| Tom   |  13 |
| Jerry |  12 |
| 王五  |  32 |
+-------+-----+
5 rows in set (0.00 sec)
```

###### 使用通配符*来查询

```
mysql> select * from student;
+----+-------+-----+-----+-------------+
| id | name  | sex | age | tell        |
+----+-------+-----+-----+-------------+
|  1 | 张三  | 男  |  23 | 13666665555 |
|  2 | 李四  | 女  |  20 | -           |
|  3 | Tom   | 男  |  13 | 13111115555 |
|  4 | Jerry | 男  |  12 | 2333333     |
|  5 | 王五  | 男  |  32 | 666666666   |
+----+-------+-----+-----+-------------+
5 rows in set (0.00 sec)
```

###### 特定条件查询
where 关键词用于指定查询条件, 用法形式为: select 列名称 from 表名称 where 条件;

```
// 查询所有性别为女的记录
mysql> select * from student where sex="女";
+----+------+-----+-----+------+
| id | name | sex | age | tell |
+----+------+-----+-----+------+
|  2 | 李四 | 女  |  20 | -    |
+----+------+-----+-----+------+
1 row in set (0.04 sec)

// age大于20的记录
mysql> select * from student where age>20;
+----+------+-----+-----+-------------+
| id | name | sex | age | tell        |
+----+------+-----+-----+-------------+
|  1 | 张三 | 男  |  23 | 13666665555 |
|  5 | 王五 | 男  |  32 | 666666666   |
+----+------+-----+-----+-------------+
2 rows in set (0.00 sec)

// age小于等于20的记录
mysql> select * from student where age<=20;
+----+-------+-----+-----+-------------+
| id | name  | sex | age | tell        |
+----+-------+-----+-----+-------------+
|  2 | 李四  | 女  |  20 | -           |
|  3 | Tom   | 男  |  13 | 13111115555 |
|  4 | Jerry | 男  |  12 | 2333333     |
+----+-------+-----+-----+-------------+
3 rows in set (0.00 sec)

// age小于等于20并且id大于等于3的记录
mysql> select * from student where age<=20 and id >=3;
+----+-------+-----+-----+-------------+
| id | name  | sex | age | tell        |
+----+-------+-----+-----+-------------+
|  3 | Tom   | 男  |  13 | 13111115555 |
|  4 | Jerry | 男  |  12 | 2333333     |
+----+-------+-----+-----+-------------+
2 rows in set (0.03 sec)

// 按名字特征查询
mysql> select * from student where name like "%三%";
+----+------+-----+-----+-------------+
| id | name | sex | age | tell        |
+----+------+-----+-----+-------------+
|  1 | 张三 | 男  |  23 | 13666665555 |
+----+------+-----+-----+-------------+
1 row in set (0.00 sec)

mysql> select * from student where name like "%o%";
+----+------+-----+-----+-------------+
| id | name | sex | age | tell        |
+----+------+-----+-----+-------------+
|  3 | Tom  | 男  |  13 | 13111115555 |
+----+------+-----+-----+-------------+
1 row in set (0.00 sec)

// tell 以5结尾的记录
mysql> select * from student where tell like "%5";
+----+------+-----+-----+-------------+
| id | name | sex | age | tell        |
+----+------+-----+-----+-------------+
|  1 | 张三 | 男  |  23 | 13666665555 |
|  3 | Tom  | 男  |  13 | 13111115555 |
+----+------+-----+-----+-------------+
2 rows in set (0.00 sec)

mysql> select * from student where tell like "131%";
+----+------+-----+-----+-------------+
| id | name | sex | age | tell        |
+----+------+-----+-----+-------------+
|  3 | Tom  | 男  |  13 | 13111115555 |
+----+------+-----+-----+-------------+
1 row in set (0.00 sec)
```

按条件查询非常的灵活，运用得当会节省运行时间

##### 改 - 修改表中的数据
基本的使用形式为:

update 表名称 set 列名称=新值 where 更新条件;

我们终于拿到了李四的联系方式，将数据库中的tell更新

```
mysql> update student set tell="13900001111" where name="李四";
Query OK, 1 row affected (0.05 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from student where name="李四";
+----+------+-----+-----+-------------+
| id | name | sex | age | tell        |
+----+------+-----+-----+-------------+
|  2 | 李四 | 女  |  20 | 13900001111 |
+----+------+-----+-----+-------------+
1 row in set (0.00 sec)
```

过了一年，大家都长了一岁，修改表中的age值

```
mysql> update student set age=age+1;
Query OK, 5 rows affected (0.05 sec)
Rows matched: 5  Changed: 5  Warnings: 0

mysql> select * from student;
+----+-------+-----+-----+-------------+
| id | name  | sex | age | tell        |
+----+-------+-----+-----+-------------+
|  1 | 张三  | 男  |  24 | 13666665555 |
|  2 | 李四  | 女  |  21 | 13900001111 |
|  3 | Tom   | 男  |  14 | 13111115555 |
|  4 | Jerry | 男  |  13 | 2333333     |
|  5 | 王五  | 男  |  33 | 666666666   |
+----+-------+-----+-----+-------------+
5 rows in set (0.00 sec)
```

修改多个信息，Jerry有了中文名“赵六”，换了tell

```
mysql> update student set name="赵六",tell="10001-1001" where name="Jerry";
Query OK, 1 row affected (0.05 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> select * from student;
+----+------+-----+-----+-------------+
| id | name | sex | age | tell        |
+----+------+-----+-----+-------------+
|  1 | 张三 | 男  |  24 | 13666665555 |
|  2 | 李四 | 女  |  21 | 13900001111 |
|  3 | Tom  | 男  |  14 | 13111115555 |
|  4 | 赵六 | 男  |  13 | 10001-1001  |
|  5 | 王五 | 男  |  33 | 666666666   |
+----+------+-----+-----+-------------+
5 rows in set (0.00 sec)
```

##### 删 - 删除表中的数据
基本用法为:

delete from 表名称 where 删除条件;

年龄太小不能入学

```
mysql> delete from student where age < 18;
Query OK, 2 rows affected (0.04 sec)

mysql> select * from student;
+----+------+-----+-----+-------------+
| id | name | sex | age | tell        |
+----+------+-----+-----+-------------+
|  1 | 张三 | 男  |  24 | 13666665555 |
|  2 | 李四 | 女  |  21 | 13900001111 |
|  5 | 王五 | 男  |  33 | 666666666   |
+----+------+-----+-----+-------------+
3 rows in set (0.00 sec)
```

#### 修改现有的表
alter table 语句用于修改现有表

##### 添加列
alter table 表名 add 列名 列数据类型 [after 插入位置];

在表的最后添加address列  
`mysql> alter table student add address char(70);`   

在名为 age 的列后插入列 birthday  
`mysql> alter table student add birthday date after age;`

此时的表
```
mysql> select * from student;
+----+------+-----+-----+----------+-------------+---------+
| id | name | sex | age | birthday | tell        | address |
+----+------+-----+-----+----------+-------------+---------+
|  1 | 张三 | 男  |  24 | NULL     | 13666665555 | NULL    |
|  2 | 李四 | 女  |  21 | NULL     | 13900001111 | NULL    |
|  5 | 王五 | 男  |  33 | NULL     | 666666666   | NULL    |
+----+------+-----+-----+----------+-------------+---------+
```

##### 修改列
基本形式: alter table 表名 change 列名称 列新名称 新数据类型;

将tell列名修改为mobile  
`alter table student change tell mobile char(13) default "-";`

修改name列的类型为`char(11) not null`

```
mysql> alter table student change name name char(11) not null;
Query OK, 3 rows affected (0.54 sec)
Records: 3  Duplicates: 0  Warnings: 0
```

##### 删除列
alter table 表名 drop 列名称;

删除address列 `alter table student drop address;`

##### 重命名表
alter table 表名 rename 新表名;

重命名表student -> bigstu  `alter table student rename bigstu;`

##### 删除整张表
drop table 表名;  
删掉前面我们创建的`person_t`
```
mysql> drop table person_t;
Query OK, 0 rows affected (0.12 sec)
```

##### 删除整个数据库
drop database 数据库名;

新建一个数据库samp_4_delete，再删除它
```
mysql> create database samp_4_delete;
Query OK, 1 row affected (0.00 sec)

mysql> drop database samp_4_delete;
Query OK, 0 rows affected (0.01 sec)
```

