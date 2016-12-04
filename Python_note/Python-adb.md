---
title: Python 调用adb命令
date: 2017-07-05 21:53:42
category: Python
---

使用Python通过subprocess调用adb命令。  
subprocess包主要功能是执行外部命令（相对Python而言）。和shell类似。
换言之除了adb命令外，利用subprocess可以执行其他的命令，比如ls，cd等等。  
subprocess 可参考： https://docs.python.org/2/library/subprocess.html

在电脑上装好adb工具，配置好adb的环境变量，先确保shell中可以调用adb命令。

### 代码示例
* Python2.7

类 `Adb`，封装了一些adb的方法

```python
import os
import subprocess


class Adb(object):
    """ Provides some adb methods """

    @staticmethod
    def adb_devices():
        """
        Do adb devices
        :return The first connected device ID
        """
        cmd = "adb devices"
        c_line = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()[0]
        if c_line.find("List of devices attached") < 0:  # adb is not working
            return None
        return c_line.split("\t")[0].split("\r\n")[-1]  # This line may have different format

    @staticmethod
    def pull_sd_dcim(device, target_dir='E:/files'):
        """ Pull DCIM files from device """
        print "Pulling files"
        des_path = os.path.join(target_dir, device)
        if not os.path.exists(des_path):
            os.makedirs(des_path)
        print des_path
        cmd = "adb pull /sdcard/DCIM/ " + des_path
        result = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
        print result
        print "Finish!"
        return des_path

    @staticmethod
    def some_adb_cmd():
        p = subprocess.Popen('adb shell cd sdcard&&ls&&cd ../sys&&ls',
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return_code = p.poll()
        while return_code is None:
            line = p.stdout.readline()
            return_code = p.poll()
            line = line.strip()
            if line:
                print line
        print "Done"

```
`some_adb_cmd`方法执行一连串的命令。各个命令之间用`&&`连接。
接着是一个死循环，将执行结果打印出来。

### subprocess 说明
`creationflags=CREATE_NEW_CONSOLE`在执行指令时弹出一个新的cmd窗口

可以执行指定的bat脚本

```python
from _subprocess import CREATE_NEW_CONSOLE
from subprocess import Popen

    def _click_new_cmd_window_btn(self):
        self.log.info("click_new_cmd_window_btn")
        Popen('cmd', creationflags=CREATE_NEW_CONSOLE)

    def _click_exe_bat_btn1(self):
        self.log.info("run bat")
        Popen('C:\MYDIR\_debug.bat', creationflags=CREATE_NEW_CONSOLE)
```
