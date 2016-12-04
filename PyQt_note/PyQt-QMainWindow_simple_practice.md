---
title: PyQt QMainWindow 简单使用
date: 2016-12-28 21:05:25
category: PyQt
---

QMainWindow继承自QWidget  
QMainWindow相当于程序的主界面，内置了menu和toolBar。
使用 Qt Designer 可以很方便地添加menu选项。

对于较大型的界面，用Qt Designer比较方便。`.ui`文件就像Android中使用xml一样。
画出的ui文件可以用PyQt中的PyUIC转换成py文件。转换后的py文件中有一个class。
新建一个继承自QMainWindow的类，来调用生成的这个类。

主窗口关闭时，会调用`closeEvent(self, *args, **kwargs)`，可复写这个方法，加上一些关闭时的操作。
比如终止子线程，关闭数据库接口，释放资源等等操作。

## PyQt5 手写 QMainWindow 示例
Win7  PyCharm  Python3.5.1  PyQt5

手写一个main window，主要使用了菜单栏、文本编辑框、工具栏和状态栏
```
|-- main.py
|-- res
|   `-- sword.png
`-- ui
    `-- app_main_window.py
```

`main.py`主文件
```python
import sys

from PyQt5.QtWidgets import QApplication
from ui.app_main_window import AppMainWindow

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = AppMainWindow()
    window.show()
    sys.exit(app.exec_())
```

`app_main_window.py`窗口实现文件
```python
from PyQt5.QtCore import QCoreApplication
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import QAction
from PyQt5.QtWidgets import QMainWindow
from PyQt5.QtWidgets import QTextEdit


class AppMainWindow(QMainWindow):
    """
    菜单栏、文本编辑框、工具栏和状态栏
    """

    def __init__(self):
        super().__init__()
        self.init_ui()

    def init_ui(self):
        # 菜单栏
        self.statusBar().showMessage('Main window is ready')
        self.setGeometry(500, 500, 450, 220)
        self.setMinimumSize(150, 120)
        self.setWindowTitle('MainWindow')

        # 文本编辑框
        text_edit = QTextEdit()
        self.setCentralWidget(text_edit)  # 填充剩下的位置

        # 定义退出动作
        exit_action = QAction(QIcon('res/sword.png'), 'Exit', self)
        exit_action.setShortcut('Ctrl+Q')
        exit_action.setStatusTip('Exit App')  # 鼠标指向选项时在窗口状态栏出现的提示
        # exit_action.triggered.connect(QCoreApplication.instance().quit)
        exit_action.triggered.connect(self.close)  # 关闭app

        # 定义菜单栏，添加一个选项
        menu_bar = self.menuBar()
        file_menu = menu_bar.addMenu('&File')
        file_menu.addAction(exit_action)

        # 定义工具栏，添加一个退出动作
        toolbar = self.addToolBar('&Exit')
        toolbar.addAction(exit_action)

```

有的时候PyCharm给的代码提示不完全。网上说PyCharm配合vim插件来使用能带来很好的体验。  
生成的界面中，工具栏可以自由的拖动，可以放在上下左右4个地方。

同样的代码，可以很方便地移植到PyQt4中。

## 使用designer画出来的界面
Ubuntu

使用designer绘制好界面后，讲ui文件转换成py代码。
```python
import sys
from PyQt5.QtWidgets import QMainWindow, QApplication
from ui_main_window import Ui_UAppMainWindow


class RustMainWindow(QMainWindow):
    """主界面类"""

    def __init__(self):
        super(RustMainWindow, self).__init__()
        self.ma = Ui_UAppMainWindow()  # designer画的界面
        self.ma.setupUi(self)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    main_window = RustMainWindow()
    main_window.show()
    sys.exit(app.exec_())

```

复写`__init__`初始化方法时需要调用父类方法


## PyQt4手写窗口代码
和上面那个功能类似。

```python
import sys
from PyQt4.QtGui import QMainWindow, QTextEdit, QAction, QIcon, QApplication


class AppMainWindow(QMainWindow):
    def __init__(self):
        super(AppMainWindow, self).__init__()
        self.init_ui()

    def init_ui(self):
        self.statusBar().showMessage('Main window is ready')
        self.setGeometry(500, 500, 450, 220)
        self.setMinimumSize(150, 120)
        self.setWindowTitle('MainWindow')

        text_edit = QTextEdit()
        self.setCentralWidget(text_edit)

        exit_action = QAction(QIcon('res/ic_s1.png'), 'Exit', self)
        exit_action.setShortcut('Ctrl+Q')
        exit_action.setStatusTip('Exit App')
        exit_action.triggered.connect(self.close)

        menu_bar = self.menuBar()
        file_menu = menu_bar.addMenu('&File')
        file_menu.addAction(exit_action)

        toolbar = self.addToolBar('&Exit')
        toolbar.addAction(exit_action)


if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = AppMainWindow()
    window.show()
    sys.exit(app.exec_())

```
可以看出，PyQt4 和 5 的代码基本上是通用的。复写`__init__`的方法不同。
