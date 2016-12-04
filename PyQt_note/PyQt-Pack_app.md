---
title: PyQt 打包
date: 2017-09-18 12:03:05
category: PyQt
---

## py2exe
### PyQt4 中打包成EXE文件
将某个GUI程序打包成EXE文件。

Python2.7，在PyCharm中直接执行这个文件。

```python
# -*- coding: utf-8 -*-

from distutils.core import setup
import py2exe
import sys

import main_window_re

# this allows to run it with a simple double click.
sys.argv.append('py2exe')

py2exe_options = {
    "includes": ["sip"],
    "dll_excludes": ["MSVCP90.dll", ],
    "compressed": 1,
    "optimize": 2,
    "ascii": 0,
    "bundle_files": 1,
}

setup(
    name='Reliability_test',
    version=main_window_re.VERSION_NAME,
    windows=['main_window_re.py', ],
    zipfile=None,
    options={'py2exe': py2exe_options}
)
```

尝试过3.6和3.5版本，py2exe都不能正常工作。

## pyinstaller
https://github.com/pyinstaller/pyinstaller/wiki/FAQ

由于电脑上安装了多个版本的Python，环境变量制定了Python2。  
这里使用3.5版本的pyinstaller来打包。  
注意`--paths`指定了路径。环境变量中并没有设置这个路径。我们指定去找PyQt5的依赖dll。
```
  -p DIR, --paths DIR   A path to search for imports (like using PYTHONPATH).
                        Multiple paths are allowed, separated by ';', or use
                        this option multiple times
```

路径最好是加上引号，比如这里指定Qt5和PyQt5的路径
```
pyinstaller -p "D:\Qt\Qt5\5.6.3\msvc2015\bin" -p "D:\Python27_qt5\Lib\site-packages\PyQt5" ui_main.py
```

```
$ /d/python35/Scripts/pyinstaller --paths /d/python35/Lib/site-packages/PyQt5/Qt/bin --onefile main_lab.py
106 INFO: PyInstaller: 3.2.1
106 INFO: Python: 3.5.4rc1
106 INFO: Platform: Windows-7-6.1.7601-SP1
108 INFO: wrote E:\ws\eslab\lab\main_lab.spec
109 INFO: UPX is not available.
110 INFO: Extending PYTHONPATH with paths
['E:\\ws\\eslab\\lab',
 'D:\\python35\\Lib\\site-packages\\PyQt5\\Qt\\bin',
 'E:\\ws\\eslab\\lab']
......
```

生成单个窗口EXE文件。
```
$ /d/python35/Scripts/pyinstaller --paths /d/python35/Lib/site-packages/PyQt5/Qt/bin -F -w main_lab.py
```

生成exe文件后，报了一个找不到`lab`模块的错误。
这个模块刚好就是我们主界面所在的模块。
将引用的模块名`lab`删掉。重新生成exe文件。
```python
from lab.file_utils import FileUtils
from lab.mainwindow import Ui_MainWindow
####################################
from file_utils import FileUtils
from mainwindow import Ui_MainWindow
```

### 运行exe找不到模块报错
使用默认方式打包，得到exe与文件目录
```
pyinstaller ui_main.py
```
将dist中的目录复制到另一台电脑，点击运行exe文件；提示找不到模块  
在主ui文件中，添加路径
```python
import sys
import os

sys.path.append(os.getcwd())  # Prepare path
```

找不到模块，一般会报 `ImportError: No module named 'xxx'` 错误  
此时一般是找不到我们自己写的模块。
```python
from my_package.ui_main import Ui_MainWindow  # 显示指定了my_package 打包得到的exe会找不到这个包
from my_widget import DragInWidget  # 不显示指定package  否则打包得到的exe会找不到包而无法运行
```
