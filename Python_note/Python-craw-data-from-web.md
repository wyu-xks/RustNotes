---
title: Python 爬取信息
date: 2017-05-01 22:23:20
category: Python
---


需求：从网络上搜索数据，然后存成json文件  
主要使用 `BeautifulSoup`

打印出目标URL的所有链接

```py
from urllib.request import urlopen
from bs4 import BeautifulSoup


def getItemLinks(url):  # 获取当前页面的所有目标链接
    html = urlopen(url)
    bsObj = BeautifulSoup(html, "html.parser")
    linksList = []  # store links
    for link in bsObj.findAll("a", {}):
        if 'href' in link.attrs:
            hrefAttr = link.attrs['href']
            if "subject" in hrefAttr:
                if hrefAttr not in linksList:
                    linksList.append(hrefAttr)
    return linksList
```
findAll返回的是`bs4.element.ResultSet`


