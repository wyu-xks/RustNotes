---
title: PyQt 线程类 QThread
date: 2017-07-11 23:15:05
category: PyQt
---

PyQt中的线程类 `QtCore.QThread`，使用时继承QThread类

启动界面的线程暂称为UI线程。界面执行命令时都在自己的UI线程中。
如果在UI线程中执行网络连接和数据库操作等耗时的操作，界面会被卡住，Windows下有可能会出现“无响应”的警告。
阻塞UI线程会降低用户体验和应用稳定性。因此我们可以把耗时操作放在线程中去执行。

QThread代表一个线程，我们可以复写run函数来执行我们要的操作。  
QThread可以使用`QtCore.pyqtSignal`来与界面交互和传输数据。

## PyQt4 QThread 代码示例
* Python2.7

```python
# -*- coding: utf-8 -*-
import sys

from PyQt4 import QtCore
from PyQt4.QtCore import QCoreApplication
from PyQt4.QtGui import QWidget, QPushButton, QApplication, QTextBrowser


class TimeThread(QtCore.QThread):
    signal_time = QtCore.pyqtSignal(str, int)  # 信号

    def __init__(self, parent=None):
        super(TimeThread, self).__init__(parent)
        self.working = True
        self.num = 0

    def start_timer(self):
        self.num = 0
        self.start()

    def run(self):
        while self.working:
            print "Working", self.thread()
            self.signal_time.emit("Running time:", self.num)  # 发送信号
            self.num += 1
            self.sleep(1)


class TimeDialog(QWidget):
    def __init__(self):
        super(TimeDialog, self).__init__()
        self.timer_tv = QTextBrowser(self)
        self.init_ui()
        self.timer_t = TimeThread()
        self.timer_t.signal_time.connect(self.update_timer_tv)

    def init_ui(self):
        self.resize(300, 200)
        self.setWindowTitle('TimeDialog')
        self.timer_tv.setText("Wait")
        self.timer_tv.setGeometry(QtCore.QRect(10, 145, 198, 26))
        self.timer_tv.move(0, 15)

        btn1 = QPushButton('Quit', self)
        btn1.setToolTip('Click to quit')
        btn1.resize(btn1.sizeHint())
        btn1.move(200, 150)
        btn1.clicked.connect(QCoreApplication.instance().quit)

        start_btn = QPushButton('Start', self)
        start_btn.setToolTip("Click to start")
        start_btn.move(50, 150)
        self.connect(start_btn, QtCore.SIGNAL("clicked()"), self.click_start_btn)

    def click_start_btn(self):
        self.timer_t.start_timer()

    def update_timer_tv(self, text, number):
        self.timer_tv.setText(self.tr(text + " " + str(number)))


if __name__ == '__main__':
    app = QApplication(sys.argv)
    time_dialog = TimeDialog()
    time_dialog.show()

    sys.exit(app.exec_())
```

QThread中使用的信号`signal_time = QtCore.pyqtSignal(str, int)` 指定了参数str和int  
发送信号`self.signal_time.emit("Running time:", self.num)`

外部接收信号`self.timer_t.signal_time.connect(self.update_timer_tv)`  
信号连接到方法`update_timer_tv(self, text, number)`，注意信号与方法的参数要一一对应

使用中我们可以定义多种不同的信号`QtCore.pyqtSignal`

启动线程，调用`start()`
