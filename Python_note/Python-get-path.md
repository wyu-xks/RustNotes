---
title: Python 获取当前路径的方法
date: 2017-07-31 22:15:36
category: Python
---

#### Python2.7 中获取路径的各种方法

`sys.path`  
模块搜索路径的字符串列表。由环境变量PYTHONPATH初始化得到。  
sys.path[0]是调用Python解释器的当前脚本所在的目录。

`sys.argv`  
一个传给Python脚本的指令参数列表。  
sys.argv[0]是脚本的名字（由系统决定是否是全名）  
假设显示调用python指令，如`python demo.py`，会得到绝对路径；  
若直接执行脚本，如`./demo.py`，会得到相对路径。

`os.getcwd()`  
获取当前工作路径。在这里是绝对路径。  
https://docs.python.org/2/library/os.html#os.getcwd

`__file__`  
获得模块所在的路径，可能得到相对路径。  
如果显示执行Python，会得到绝对路径。  
若按相对路径来直接执行脚本`./pyws/path_demo.py`，会得到相对路径。  
为了获取绝对路径，可调用`os.path.abspath()`

#### os.path 中的一些方法
`os.path.split(path)`  
将路径名称分成头和尾一对。尾部永远不会带有斜杠。如果输入的路径以斜杠结尾，那么得到的空的尾部。
如果输入路径没有斜杠，那么头部位为空。如果输入路径为空，那么得到的头和尾都是空。  
https://docs.python.org/2/library/os.path.html#os.path.split

`os.path.realpath(path)`  
返回特定文件名的绝对路径。  
https://docs.python.org/2/library/os.path.html#os.path.realpath

#### 代码示例
环境 Win7, Python2.7  
以`/e/pyws/path_demo.py`为例
```python
#!/usr/bin/env python
import os
import sys

if __name__ == '__main__':
    print "sys.path[0] =", sys.path[0]
    print "sys.argv[0] =", sys.argv[0]
    print "__file__ =", __file__
    print "os.path.abspath(__file__) =", os.path.abspath(__file__)
    print "os.path.realpath(__file__) = ", os.path.realpath(__file__)
    print "os.path.dirname(os.path.realpath(__file__)) =", os.path.dirname(os.path.realpath(__file__))
    print "os.path.split(os.path.realpath(__file__)) =", os.path.split(os.path.realpath(__file__))
    print "os.getcwd() =", os.getcwd()
```

在`/d`中运行，输出为
```
$ python /e/pyws/path_demo.py
sys.path[0] = E:\pyws
sys.argv[0] = E:/pyws/path_demo.py
__file__ = E:/pyws/path_demo.py
os.path.abspath(__file__) = E:\pyws\path_demo.py
os.path.realpath(__file__) =  E:\pyws\path_demo.py
os.path.dirname(os.path.realpath(__file__)) = E:\pyws
os.path.split(os.path.realpath(__file__)) = ('E:\\pyws', 'path_demo.py')
os.getcwd() = D:\
```

在e盘中用命令行直接执行脚本
```
$ ./pyws/path_demo.py
sys.path[0] = E:\pyws
sys.argv[0] = ./pyws/path_demo.py
__file__ = ./pyws/path_demo.py
os.path.abspath(__file__) = E:\pyws\path_demo.py
os.path.realpath(__file__) =  E:\pyws\path_demo.py
os.path.dirname(os.path.realpath(__file__)) = E:\pyws
os.path.split(os.path.realpath(__file__)) = ('E:\\pyws', 'path_demo.py')
os.getcwd() = E:\
```
