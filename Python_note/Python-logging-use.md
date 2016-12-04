---
title: Python logging 基本用法
date: 2017-11-21 18:47:20
category: Python
---

创建文件`logger.py`

```python
import logging

LOG_FILE = 'app_history.log'

logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s - %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
                    # datefmt='%Y_%m_%d_%H:%M:%S',
                    filename=LOG_FILE,
                    filemode='a')

console = logging.StreamHandler()
console.setLevel(logging.INFO)
formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
console.setFormatter(formatter)
logging.getLogger(LOG_FILE).addHandler(console)

```

调用
```python
logger.logging.info("%-13s connected: %r" % (ip_address, connected))
```

`%(asctime)s` 表示这个位置上是字符串形式的当前时间  
`datefmt='%Y_%m_%d_%H:%M:%S'` 指定了时间格式；我们也可以不指定时间格式


查看写出的log文件
```
2017-11-23 13:39:35,295 - xxx.py[line:122] INFO [MainWindow] --------- App Starts ---------
```
