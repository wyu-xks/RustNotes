---
title: maven 安装与配置
date: 2017-02-27 22:40:01
category: WebsiteBackstage
tag: [maven]
toc: true
---

environment: win7_x64, Intellij IDEA 2016.2.2, Cygwin

## 下载安装maven

下载maven http://maven.apache.org/download.cgi

放在`E:\mysql-5.7.17-winx64\bin`

环境变量：
```
M2_HOME
E:\apache-maven-3.3.9
```

把bin添加到path `%M2_HOME%\bin`

在`conf\setting.xml`，自定义配置仓库地址。
```
  <localRepository>E:\mavenLocalRepo</localRepository>
```

命令行中检查配置
```
$ mvn -v
Apache Maven 3.3.9 (bb52d8502b132ec0a5a3f4c09453c07478323dc5; 2015-11-11T00:41:47+08:00)
Maven home: E:\apache-maven-3.3.9
Java version: 1.8.0_77, vendor: Oracle Corporation
Java home: C:\Program Files\Java\jdk1.8.0_77\jre
Default locale: zh_CN, platform encoding: GBK
OS name: "windows 7", version: "6.1", arch: "amd64", family: "dos"
```

## 配置maven
在`conf\setting.xml`中添加mirror

maven官网的下载速度太慢了，我们可以在mirrors标签里添加一个镜像站
```
<mirror>
    <id>alimaven</id>
    <name>aliyun maven</name>
    <url>http://maven.aliyun.com/nexus/content/groups/public/</url>
    <mirrorOf>central</mirrorOf>
</mirror>
```

### 给IDEA配置maven
```
Settings->Build,Execution,Deployment->Build Tools->Maven

User settings file: E:\apache-maven-3.3.9\conf\settings.xml  // 勾上Override
Local repository:   E:\mavenLocalRepo                        // 勾上Override
```

启动一个新Project时，选上maven，根据提示进行设置
```
$ tree JavaBackendProj/ -a
JavaBackendProj/
|-- .idea
|   |-- compiler.xml
|   |-- copyright
|   |   `-- profiles_settings.xml
|   |-- markdown-navigator
|   |   `-- profiles_settings.xml
|   |-- misc.xml
|   |-- modules.xml
|   `-- workspace.xml
|-- JavaBackendProj.iml
|-- pom.xml
`-- src
    |-- main
    |   |-- java
    |   `-- resources
    `-- test
        `-- java
```


个人感觉maven比不上Gradle。
