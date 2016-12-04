---
title: PyQt QFileDialog 文件选择弹窗 
date: 2017-11-23 17:53:15
category: PyQt
---

弹出文件选择框。可以自定义选择框的标题，默认位置，目标文件后缀

选择框弹出后，会阻塞UI线程。

## PyQt5文件选择框的例子
这里只选择一个bat文件。如果默认目录不存在，则查找当前目录
```python
    def _click_tu_choose_file_path_btn1(self):
        default_path = 'C:\MY'
        if not os.path.exists(default_path):
            default_path = os.getcwd()
        dlg = QFileDialog(None, "choose_bat_file", default_path, 'All Files(*.bat)')
        dlg.setFileMode(QFileDialog.AnyFile)
        if dlg.exec_():
            selected_name = dlg.selectedFiles()[0]
            if selected_name:
                self.ma.tu_filePathTv1.setText(self.tr(selected_name))

```
