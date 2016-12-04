---
title: Python3.5 PyQt5 安装
date: 2016-12-28 18:55:20
category: PyQt
---

在Windows和Ubuntu下安装PyQt5  
需要先安装并配置好Python，Windows下需要配置环境变量。PyQt需要对应上Python版本。

## Windows环境
### 用pip3安装PyQt5
先确认Python相关环境变量已经配置好，比如：
```
D:\python36;D:\python36\Scripts;D:\python36\libs;
```
然后运行pip3，[参考 PyQt5 Download](https://riverbankcomputing.com/software/pyqt/download5)
```
pip3 install PyQt5
```
从网上下载相关文件并安装，等待过程比较长。

### PyQt5-5.6-gpl exe 安装方式
Win7  Python3.5.1

PyQt5-5.6-gpl-Py3.5-Qt5.6.0-x64-2.exe  （最新版本已经不再提供exe版本）

先安装Python3.5.1到 `E:\Python351`  
再去官网下载PyQt5，翻墙后下载速度更快。双击安装，PyQt5会自动找到Python35的目录。  
本例中PyQt5安装到 `E:\Python351\Lib\site-packages\PyQt5`

现在就可以使用PyQt5了。

`>>> from PyQt5.QtWidgets import *`

在命令行显示一个label试一下

```python
>>> import sys
>>> from PyQt5 import QtWidgets
>>> app = QtWidgets.QApplication(sys.argv)
>>> label = QtWidgets.QLabel('Label')
>>> label.resize(150,100)
>>> label.show()
```

得到如下的框框：

![label1](https://raw.githubusercontent.com/RustFisher/RustNotes/master/PyQt_note/res/label_1.png)

## Ubuntu 16.04
Python3.5  
直接安装
```
sudo apt-get install python3-dev
sudo apt-get install python3-pyqt5
sudo apt-get install qt5-default qttools5-dev-tools
designer # 启动designer
```

安装pyuic5
```
sudo apt-get install pyqt5-dev-tools
```
