---
title: PyQt5 安装商业版
date: 2017-10-25 11:36:05
category: PyQt
toc: true
---


对于Windows7上的Python2，需要如下工具：
- visual studio
- sip
- Qt(SDK)

如果电脑上已经装有了PyQt4，建议再装一份Python。与原来的分开。

## win7安装社区版Visual Studio
使用Visual Studio是为了它的编译工具和相关库。安装时选上Windows SDK。

对于VS2017来说，使用的是这个工具 "D:\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"  
开始-所有程序-Visual Studio 2017-Visual Studio Tools

vs安装路径 `D:\Microsoft Visual Studio`  
环境变量
```
D:\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.11.25503\bin\Hostx64\x64;
D:\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.11.25503\lib;
```

## Python2.7安装sip
win7 64位系统，但Python2.7是32位

下载sip源码包（例如sip-4.19.3），解压到任意位置。进入sip源码包，执行
```
python configure.py
```
这里Python2.7安装在`D:\python27`；于是sip位置在`D:\python27\Lib\site-packages\sip-4.19.3`  
打开vs的命令行，进入sip在Python中的目录，执行
```
nmake
nmake install
```

## win7安装Qt5
到Qt官网下载安装包。为了照顾32位的Python2.7，这里选择Qt 5.6.3 for Windows 32-bit (VS 2015, 869 MB)

添加到环境变量中
```
D:\Qt\Qt5\5.6.3\msvc2015\bin;D:\Qt\Qt5\Tools\QtCreator\bin
```

## win7编译安装商业版PyQt5
Python2.7

```
python configure.py --disable QtNfc
nmake
nmake install
```

参考PyQt5的README
```
COMMERCIAL VERSION

If you have the Commercial version of PyQt5 then you should also have a
license file that you downloaded separately.  The license file must be copied
to the "sip" directory before starting to build PyQt5.
```
我们把买来的license文件复制到sip目录下。

在`E:\ws\doc\PyQtCommercial\PyQt5_commercial-5.9`中，把付费后得到的`pyqt-commercial.sip`复制到sip目录下

使用vs2017的命令行工具！

`python configure.py`出现错误
```
Error: Use the --qmake argument to explicitly specify a working Qt qmake.
```
网上说是因为没有配置好Qt SDK的原因  
可参考 [PyQt setup for Qt 4.7.4](https://stackoverflow.com/questions/7854599/pyqt-setup-for-qt-4-7-4)  
解决错误后，会提示是否接受license。根据提示输入yes。

执行`python configure.py --disable QtNfc`
```
Querying qmake about your Qt installation...
Determining the details of your Qt installation...
This is the commercial version of PyQt 5.9 (licensed under the PyQt Commercial
License) for Python 2.7.13 on win32.
```

### nmake报错 cannot open file “msvcprt.lib”
```
fatal error LNK1104: cannot open file “msvcprt.lib”
```
把lib路径添加到环境变量 `D:\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.11.25503\lib;`

### nmake报错 QtNfc.dll : fatal error LNK1169: one or more multiply defined symbols found

```
release\QtNfc.dll : fatal error LNK1169: 找到一个或多个多重定义的符号
NMAKE : fatal error U1077: “"D:\Microsoft Visual Studio\2017\Community\VC\Tools
\MSVC\14.11.25503\bin\HostX86\x86\link.EXE"”: 返回代码“0x491”
Stop.
NMAKE : fatal error U1077: “"D:\Microsoft Visual Studio\2017\Community\VC\Tools
\MSVC\14.11.25503\bin\HostX86\x86\nmake.exe"”: 返回代码“0x2”
Stop.
NMAKE : fatal error U1077: “cd”: 返回代码“0x2”
Stop.
```
网上有相关的建议，把QtNfc“取消”掉，其实就是不编译QtNfc。

`E:\ws\doc\PyQtCommercial\PyQt5_commercial-5.9>python configure.py --disable QtNfc`

> http://python.6.x6.nabble.com/error-building-QtNfc-td5185657.html

`nmake` 需要一段时间。电脑比较差的话，大概要1个小时。  
`nmake install` 耗时约5分钟

### 试运行PyQt5
导入PyQt5模块试一试
```python
from PyQt5.QtCore import QTranslator
from PyQt5.QtGui import *
from PyQt5.QtWidgets import *
```

对于Python2.7 PyQt5，使用pyinstaller来打包成exe文件
```
pyinstaller ui_main.py
```
得到相应的文件目录

#### 运行exe弹窗报错`Qt platform plugin`
```
this application failed to start because it could not find or load the Qt platform plugin "windows" in ""
Reinstalling the application may fix this problem.
```
报错原因是找不到 `Qt platform plugin`  
在Qt5，在安装目录下可找到 `D:\Qt\Qt5\Tools\QtCreator\bin\plugins\platforms`  
对于Python3，安装了GPL的PyQt5，可以找到 `D:\python35\Lib\site-packages\PyQt5\Qt\plugins\platforms`

处理方法：  
不打包成一个单一的exe文件，使用`pyinstaller ui_main.py`生成文件目录  
在dist中，与exe文件同级的目录`PyQt5/qt/plugins`中，有platforms目录  
把platforms文件夹复制到与exe文件同级的位置即可  

## 参考
[How to install PyQt5 on Windows for Python 2?](https://stackoverflow.com/questions/25589103/how-to-install-pyqt5-on-windows-for-python-2)

[编译安装PyQt5的过程](http://python.6.x6.nabble.com/PyQT-Sip-installation-td1923578.html)

[安装sip的建议](https://riverbankcomputing.com/pipermail/pyqt/2012-July/031691.html)
