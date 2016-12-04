---
title: PyCharm 安装和配置
date: 2016-12-28 20:15:20
category: PyQt
toc: true
---


安装和配置PyCharm  
修改默认配置，修改config和system的路径，避免占据C盘太多的空间  
将PyQt中的工具`PyUIC`安装到PyCharm中，使用更便捷（Windows和Ubuntu平台）

* win7
* Python3.5.1
* PyQt5-5.6

PyCharm版本： JetBrains PyCharm Community Edition 2016.3.1(64)

安装路径： `E:\IntelliJ IDEA Community Edition 2016.1.1`

## PyCharm默认配置
和Android Studio类似，可以自定义IDE的配置

在第一次启动前，找到`bin\idea.properties`，修改一下路径

```
idea.config.path=E:/IntelliJIDEAPath/config

idea.system.path=E:/IntelliJIDEAPath/system
```

启动后，可以发现config和system都在`E:/IntelliJIDEAPath`下  
此举是为了避免C盘挤爆

## PyCharm工程配置
打开Settings
```
Build, Execution, Deployment
    Console
        Python Console
            Python interpreter 选择 Python 3.5.1
```

假设有一个工程`gui_app`，同样要检查一下设置
```
Project: gui_app
    Project interpreter
        选择3.5.1  后面会显示路径
```

## 安装扩展工具
打开Settings > Tools > External Tools

选择新建`+`，或者编辑

### 安装QtDesigner
Name: QtDesigner
```
Tool Settings
    Program: E:\Python351\Lib\site-packages\PyQt5\designer.exe
    ## 选择安装好的PyQt5\designer.exe

    Working directory: $FileDir$
```

### 安装PyUIC
将designer生成的ui文件转为py文件的工具；这是Python自带的工具

Name: PyUIC
```
Tool Settings
    Program: E:\Python351\python.exe
    ## 选择安装好的python.exe

    Parameters: -m PyQt5.uic.pyuic  $FileName$ -o $FileNameWithoutExtension$.py
    Working directory: $FileDir$
```

#### Ubuntu下PyCharm配置
将designer生成的ui文件转为py文件的工具  
需要`sudo apt-get install pyqt5-dev-tools`  
配置工具[Tool Settings]
```
Program: pyuic5
Parameters: -o $FileNameWithoutExtension$.py $FileNameWithoutExtension$.ui
Working directory: $FileDir$
```
