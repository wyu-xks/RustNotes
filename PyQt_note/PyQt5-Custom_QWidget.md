---
title: PyQt 创建自定义QWidget
date: 2016-12-28 20:25:10
category: PyQt
---

## PyQt5.QtWidgets 示例
Win7  PyCharm  Python3.5.1  PyQt5

主要文件：
```
|-- main.py
|-- res
|   `-- fish.jpg
`-- ui
    `-- app_widget.py
```

`main.py`
```python
import sys

from PyQt5.QtWidgets import QApplication

from ui.app_widget import AppQWidget

if __name__ == '__main__':
    app = QApplication(sys.argv)
    w = AppQWidget()
    w.show()

    sys.exit(app.exec_())

```

`app_main_window.py`自定义了一个居中显示的窗口，关闭时弹确认框

```python
from PyQt5.QtCore import QCoreApplication
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import QWidget, QPushButton, QDesktopWidget, QMessageBox


class AppQWidget(QWidget):
    """
    A custom QWidget by Rust Fisher
    """

    def __init__(self):
        super().__init__()
        self.init_ui()

    def init_ui(self):
        # self.setGeometry(300, 300, 400, 200)  # 相当于move和resize
        self.resize(300, 200)
        self.move_to_center()
        self.setWindowTitle('Demo1')
        self.setWindowIcon(QIcon('res/fish.jpg'))

        btn1 = QPushButton('Quit', self)
        btn1.setToolTip('Click to quit')
        btn1.resize(btn1.sizeHint())
        btn1.move(200, 150)
        btn1.clicked.connect(QCoreApplication.instance().quit)  # cannot locate function connect

    def closeEvent(self, event):
        reply = QMessageBox.question(self, 'Message',
                                     'Are you sure to quit now?',
                                     QMessageBox.Yes | QMessageBox.No,
                                     QMessageBox.No)
        if reply == QMessageBox.Yes:
            event.accept()
        else:
            event.ignore()

    def move_to_center(self):
        qr = self.frameGeometry()
        cp = QDesktopWidget().availableGeometry().center()  # got center info here
        qr.moveCenter(cp)
        self.move(qr.topLeft())  # 应用窗口的左上方的点到qr矩形的左上方的点，因此居中显示在我们的屏幕上

```

## Tips
### 多控件可以存在list中
存在一起，需要对整体操作时直接遍历列表

```python
        # 同组的控件可以存在同一个list中
        self.cb_list = [
            self.ma.i2cCB,
            self.ma.mipiCB,
            self.ma.eepromCB,
            self.ma.tem_sensorCB,
            self.ma.lensCB,
            self.ma.vcmCB,
            self.ma.mirrorCB,
            self.ma.mirrorCaliCB, ]

        self.test_count_et_list = [
            self.ma.i2cCountEt,
            self.ma.mipiCountEt,
            self.ma.eepromCountEt,
            self.ma.tem_sensorCountEt,
            self.ma.lensCountEt,
            self.ma.vcmCountEt,
            self.ma.mirrorCountEt,
            self.ma.mirrorCaliCountEt,
        ]

    # 需要操作某组控件时  直接遍历列表
    def _click_test_item_cb(self):
        """ Update [choose all checkbox] by all test item state """
        choose_all = True
        for cb in self.cb_list:
            choose_all = choose_all & cb.isChecked()
        self.ma.selecteAllCB.setChecked(choose_all)

```

## `QApplication`与`QWidget`
`QApplication`是一个单例，在`QWidget`中可以通过`QApplication.instance()`获取到对象

实际上在实例化QApplication前就使用`QtGui.QWidget()`是会报错的
```python
>>> QtGui.QWidget()
QWidget: Must construct a QApplication before a QPaintDevice
```
参考 [How QApplication() and QWidget() objects are connected in PySide/PyQt?](https://stackoverflow.com/questions/17601896/how-qapplication-and-qwidget-objects-are-connected-in-pyside-pyqt)

在我们自定义的`QMainWindow`中，也可以直接获取到`QApplication`的实例。
```python
class RustMainWindow(QMainWindow):
    """ This is the main class """

    def _trigger_english(self):
        print "Change to English", QApplication.instance()

# Change to English <PyQt4.QtGui.QApplication object at 0x02ABE3A0>
```

### 注意widget持有外部对象引用的问题
如果在程序启动的地方将引用交给widget，退出时会造成应用无法关闭的问题（类似内存泄漏）。
```python
if __name__ == '__main__':
    app = QApplication(sys.argv)
    # 这里把app交给了MainWindow，MainWindow关闭时是无法正常退出应用的
    main_d = RustMainWindow(app)  # 不建议这么做
    main_d.show()
    sys.exit(app.exec_())
```
