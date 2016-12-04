---
title: Python3.x JSON操作
date: 2017-05-05 21:09:20
category: Python
---

关于JSON的一些操作

## Dictionary 转为JSON
将dict转为JSON，这里利用包`json`  

```python
import json

aItem = {}
aItem["id"] = "2203"
aItem["title"] = "title"
aItem["subTitle"] = "sub title"

bItem = {}
bItem["id"] = "2842"
bItem["title"] = "b标题"
bItem["subTitle"] = "b副标题"
bItem["content"] = "内容"
bItem["list"] = ["a", "a 2", "b", "bb"]

aJson = json.dumps(aItem)
bJson = json.dumps(bItem, ensure_ascii=False)
print(aItem)
print(aJson)
print(bJson)
```
涉及到中文字符的时候，需要指定`ensure_ascii=False`

输出：
```
{'id': '2203', 'title': 'title', 'subTitle': 'sub title'}
{"id": "2203", "title": "title", "subTitle": "sub title"}
{"id": "2842", "title": "b标题", "subTitle": "b副标题", "content": "内容", "list": ["a", "a 2", "b", "bb"]}
```

## list 转为JSON
接上面的代码

```python
jsonList = []
jsonList.append(aItem)
jsonList.append(bItem)
jsonArr = json.dumps(jsonList, ensure_ascii=False)
print(jsonArr)
```

输出：
```
[{"id": "2203", "title": "title", "subTitle": "sub title"}, {"id": "2842", "title": "b标题", "subTitle": "b副标题", "content": "内容"}]
```

这一个JSON字符串可以在Android Studio中利用插件GsonFormat转换得到相应对象。

## 读取json文本文件
获取到json文件的路径，打开文件，塞给`json.load()`
```python
    config_fp = os.path.join(_get_current_folder(), "res", "configs.json")
    with open(config_fp) as json_file:
        config_json = json.load(json_file)
        print config_json
```
