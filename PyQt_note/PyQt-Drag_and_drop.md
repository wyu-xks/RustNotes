---
title: PyQt 拖入
date: 2017-09-19 10:45:15
category: PyQt
---

PyQt支持拖入功能。比如拖入文件或者一段文本。

### 拖入文本
定义了一个label继承自`QLabel`，初始化时设置允许拖入。

参见[pyqt5-drag-and-drop](https://pythonspot.com/en/pyqt5-drag-and-drop/)
```python
from PyQt5 import QtCore
from PyQt5.QtWidgets import QMainWindow, QApplication, QListWidget, QAbstractItemView

class CustomLabel(QLabel):
 
    def __init__(self, title, parent):
        super().__init__(title, parent)
        self.setAcceptDrops(True)
 
    def dragEnterEvent(self, e):
        if e.mimeData().hasFormat('text/plain'):
            e.accept()
        else:
            e.ignore()
 
    def dropEvent(self, e):
        self.setText(e.mimeData().text())
```
直接调用这个类，将它添加到界面上去。

### 拖入文件，读取文件路径
这里继承了QLabel。`Ui_MainWindow`是用designer画出来的界面。

```python
from PyQt5 import QtCore
from PyQt5.QtWidgets import QMainWindow, QApplication, QListWidget, QAbstractItemView

class LabMainWindow(QMainWindow):
    def __init__(self):
        super(LabMainWindow, self).__init__()
        self.ma = Ui_MainWindow()
        self.ma.setupUi(self)
        self.drag_in_widget = DragInWidget("Drag in", self)

    def _init_ui(self):
        self.drag_in_widget.move(0, 0)


class DragInWidget(QLabel):
    def __init__(self, title, parent):
        super().__init__(title, parent)
        self.setAcceptDrops(True)

    def dragEnterEvent(self, e):
        if e.mimeData().hasUrls():
            e.accept()
        else:
            e.ignore()

    def dropEvent(self, e):
        for url in e.mimeData().urls():
            path = url.toLocalFile()
            if os.path.isfile(path):
                print(path)

```

### QtWidgets.QFrame监听拖入事件
监听到有效拖动事件后，利用`QtCore.pyqtSignal`把信息传递出去

```python
from PyQt5 import QtCore
from PyQt5.QtWidgets import QMainWindow, QApplication, QListWidget, QAbstractItemView

class DragInWidget(QtWidgets.QFrame):
    """ Drag files to this widget """
    s_content = QtCore.pyqtSignal(str)  # emit file path

    def __init__(self, parent):
        super(DragInWidget, self).__init__(parent)
        self.setAcceptDrops(True)

    def dragEnterEvent(self, e):
        if e.mimeData().hasUrls():
            e.accept()
        else:
            e.ignore()

    def dropEvent(self, e):
        for url in e.mimeData().urls():
            path = url.toLocalFile()
            if os.path.isfile(path):
                self.s_content.emit(path)
                print(path)
```

这个Frame可以覆盖在其他控件上面时，会拦截操作

### QListWidget拖入事件
向`QListWidget`拖入文件，获取文件路径

```python
from PyQt5 import QtCore
from PyQt5.QtWidgets import QMainWindow, QApplication, QListWidget, QAbstractItemView

class DragInWidget(QListWidget):
    """ Drag files to this widget """
    s_content = QtCore.pyqtSignal(str)  # emit file path

    def __init__(self, parent):
        super(DragInWidget, self).__init__(parent)
        self.setAcceptDrops(True)
        self.setDragDropMode(QAbstractItemView.InternalMove)

    def dragEnterEvent(self, e):
        if e.mimeData().hasUrls():
            e.accept()
        else:
            e.ignore()

    def dropEvent(self, e):
        for url in e.mimeData().urls():
            path = url.toLocalFile()
            if os.path.isfile(path):
                self.s_content.emit(path)
                print(path)
```
