---
title: PyQt 适配不同屏幕分辨率
date: 2017-09-26 17:43:20
category: PyQt
---

在宽高为`1366*768`下设计开发的界面，到了`2860*1620`屏幕下会显示不正常。  
因为像素密度不同，`2860*1620`屏幕显示出来的控件很小。

## 适配方法 - 根据当前屏幕调整控件大小和位置
初始化时获取到当前屏幕的宽高像素值。
与原像素值相比求出比例`self.ratio_wid`，`self.ratio_height`。

找出所有的QWidget `self.findChildren(QWidget)`，遍历来改变大小和位置。

```python
from PyQt4.QtGui import QMainWindow, QApplication, QWidget

class ReMainWindow(QMainWindow):

    def __init__(self, parent=None):
        # ...........
        self.app = QApplication.instance()  # Calculate the ratio. Design screen is [1366, 768]
        screen_resolution = self.app.desktop().screenGeometry()
        self.hw_ratio = 768 / 1366  # height / width
        self.ratio_wid = screen_resolution.width() / 1366
        if self.ratio_wid < 1:
            self.ratio_wid = 1
        self.ratio_height = screen_resolution.height() / 768
        if self.ratio_height < 1:
            self.ratio_height = 1

    def _init_ui_size(self):
        """ Travel all the widgets and resize according to the ratio """
        self._resize_with_ratio(self)
        for q_widget in self.findChildren(QWidget):
            # print q_widget.objectName()
            self._resize_with_ratio(q_widget)
            self._move_with_ratio(q_widget)

            # Don't deal with the text browser
            # for q_widget in self.findChildren(QAbstractScrollArea):
            #     print q_widget.objectName()
            #     self._resize_with_ratio(q_widget)
            #     self._move_with_ratio(q_widget)

    def _resize_with_ratio(self, input_ui):
        input_ui.resize(input_ui.width() * self.ratio_wid, input_ui.height() * self.ratio_height)

    def _move_with_ratio(self, input_ui):
        input_ui.move(input_ui.x() * self.ratio_wid, input_ui.y() * self.ratio_height)

```
实践发现，不需要对QTextBrowser所属的`QAbstractScrollArea`处理。
