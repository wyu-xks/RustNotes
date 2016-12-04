---
title: MySQL安装 - win7_x64
date: 2017-02-25 16:20:01
category: Database
tag: [MySQL]
toc: true
---


机器配置： win7 64

走了许多的弯路，在此记录一些操作。

## win7_x64 下安装配置MySQL

### 下载
下载了绿色免安装版本，目录为`E:\mysql-5.7.17-winx64`

### 配置
新建data目录  `E:\mysql-5.7.17-winx64\data`

把`E:\mysql-5.7.17-winx64\bin`添加到环境变量

#### 配置文件my.ini

新建配置文件`my.ini`放在`E:\mysql-5.7.17-winx64`，内容如下：
```
[mysqld]
basedir=E:/mysql-5.7.17-winx64
datadir=E:/mysql-5.7.17-winx64/data
tmpdir=E:/mysql-5.7.17-winx64/data
port = 3306
```

### 初始化

打开CMD，进入目录`E:\mysql-5.7.17-winx64\bin>`，执行初始化命令，如下

```
E:\mysql-5.7.17-winx64\bin>mysqld --initialize --user=mysql --console
// *******
2017-02-25T07:35:47.155727Z 1 [Note] A temporary password is generated for root@
localhost: s/KKIaag+3iS
```

获得了一个随机密码`s/KKIaag+3iS`

打开另一个CMD，执行`C:\Users\Administrator>mysqld --console`，目的是让MySQL跑起来

回到刚才的CMD，还在`E:\mysql-5.7.17-winx64\bin>`  
登录root `mysql -uroot -p` ，用的是上面生成的密码

```
E:\mysql-5.7.17-winx64\bin>mysql -uroot -p
Enter password: ************
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 3
Server version: 5.7.17

Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

在MySQL的命令行里修改root的密码，记得打分号

```
mysql> set password = password('a123');
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> exit
Bye
```

退出用新密码重新登录。可以发现密码已经修改成功。  
在这整个过程中，另一个CMD一直在运行MySQL。

```
2017-02-25T07:37:41.643275Z 0 [Note] mysqld: ready for connections.
Version: '5.7.17'  socket: ''  port: 3306  MySQL Community Server (GPL)
```

### 启动与停止服务

#### 启动服务

杀掉CMD里面的MySQL进程。安装并开启服务。

```
E:\mysql-5.7.17-winx64\bin>mysqld install MySQL --defaults-file="E:\mysql-5.7.17
-winx64\my.ini"
Service successfully installed.

E:\mysql-5.7.17-winx64\bin>net start mysql
MySQL 服务正在启动 .
MySQL 服务已经启动成功。
```

#### 停止服务

```
C:\Users\Administrator>net stop MySQL
MySQL 服务正在停止.
MySQL 服务已成功停止。
```

#### 查看所有Windows服务
在CMD中使用net命令，可以查看所有服务

```
C:\Users\Administrator>net start
已经启动以下 Windows 服务:

// ****
IPsec Policy Agent
MySQL
Network Connections
// ****
```

#### 删除服务
sc delete 服务名

```
C:\Users\Administrator>sc delete mysql
[SC] DeleteService 成功

C:\Users\Administrator>net start mysql
服务名无效。

请键入 NET HELPMSG 2185 以获得更多的帮助。
```

### 删除服务后，重新初始化并建立服务

前面已经删除服务，此时直接建立服务并启动会报错
```
C:\Users\Administrator>mysqld install MySQL --defaults-file="E:\mysql-5.7.17-win
x64\my.ini"
Service successfully installed.

C:\Users\Administrator>net start mysql
发生系统错误 2。

系统找不到指定的文件。
```

此时要把mysql这个服务删除`sc delete mysql`

然后把data目录内的文件全部删除，回到bin目录重新初始化一次。又获得了一个随机密码。  
再新建服务并启动即可。

```
E:\mysql-5.7.17-winx64\bin>mysqld --initialize --user=mysql --console
// **********
2017-02-25T08:11:51.156501Z 1 [Note] A temporary password is generated for root@
localhost: gp/L/3#ayeo/

E:\mysql-5.7.17-winx64\bin>mysqld install MySQL --defaults-file="E:\mysql-5.7.17
-winx64\my.ini"
Service successfully installed.

E:\mysql-5.7.17-winx64\bin>net start mysql
MySQL 服务正在启动 .
MySQL 服务已经启动成功。
```

MySQL的服务正在运行，此时将随机密码修改成自己的密码a123

```
E:\mysql-5.7.17-winx64\bin>mysql -uroot -p
Enter password: ************
Welcome to the MySQL monitor.  Commands end with ; or \g.
// ******
mysql> set password = password('a123');
Query OK, 0 rows affected, 1 warning (0.00 sec)
```
