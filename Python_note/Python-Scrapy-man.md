---
title: Python scrapy 使用记录
date: 2017-06-01 22:13:20
category: Python
---

相关文档： https://doc.scrapy.org/en/latest/

安装配置好pip，安装scrapy

```py
pip install scrapy
```

win7环境  
IDE PyCharm

遇到错误： `No module named 'win32api'`
```py
pip install pypiwin32
```

PyCharm自带命令行中使用scrapy shell，适合于调试
```py
scrapy shell http://quotes.toscrape.com/tag/humor/

# 使用本地网页
scrapy shell ./web_source/a118335.html
```

scrapy新建项目  例如新建一个[tutorial项目](https://doc.scrapy.org/en/latest/intro/tutorial.html)
```py
scrapy startproject tutorial
```

### 分析本地网页
使用shell分析本地某个网页
```py
# 使用本地网页
scrapy shell ./web_source/a118335.html
res = response 

# 获取h1作为title
title = res.css('h1.nameSingle')

title.css('a::text').extract_first()
# '進撃の巨人 Season 2'

title.css('a::attr(href)').extract_first()

title.css('a::attr(title)').extract_first()
# '进击的巨人 第二季'

title.css('small::text').extract_first()
# 'TV'

# 获取信息表
info = res.css('div.infobox')

# 获取封面图片地址
info.css('a::attr(href)').extract_first()

info.css('li')[0].css('span::text').extract_first()
# '中文名: '

info.css('li')[0].css('li::text').extract_first()
# '进击的巨人 第二季'

```

在scrapy中使用
```py
import scrapy


class AnimeSpider(scrapy.Spider):
    name = "bang"

    start_urls = [
        'file://H/fisher_p/crawl-anime/web_source/a118335.html',
    ]

    def parse(self, response):
        res = response

        # 获取h1作为title  抓取基本信息
        title = res.css('h1.nameSingle')
        name_jp = title.css('a::text').extract_first()
        a_link = title.css('a::attr(href)').extract_first()
        bang_id = str(a_link).split('/')[-1]
        name_zh = title.css('a::attr(title)').extract_first()
        sub_title = title.css('small::text').extract_first()
        print(name_jp + " , " + name_zh + " , " + bang_id + " , " + sub_title)

        # 获取信息表
        info = res.css('div.infobox')

        pic_link = info.css('a::attr(href)').extract_first()  # 获取封面图片地址
        print("pic link: " + pic_link)
        for li in info.css('li'):
            info_title = li.css('span.tip::text').extract_first()
            info_content_href = li.css('a').extract_first()
            if info_content_href is None:
                info_contents = li.css('li::text').extract_first()
            else:
                # 若是链接  将其中的信息提取拼接成一个字符串
                people_bang_id = str(li.css('a::attr(href)').extract_first()).split("/")[-1]
                info_contents = li.css('a::text').extract_first() + "|" + people_bang_id
            print(info_title + " " + str(info_contents))

```

执行爬虫
```
scrapy crawl bang --nolog
```

### scrapy 下载图片并重命名
让scrapy下载图片，并重命名目标图片  
以某个图片爬虫为例。在scrapy工程中需要的文件有
```
├── proj_name  # 工程
│   ├── __init__.py  # 初始化
│   ├── items.py  # 定义图片类的地方
│   ├── middlewares.py
│   ├── pipelines.py  # 执行保存文件的地方
│   ├── settings.py  # 配置文件  比如图片下载目录
│   └── spiders
│       ├── _pic_spider.py  # 图片爬虫

```

图片下载爬虫。这里我事先已将所有的图片链接存了起来，爬虫自己读取预先存好的链接
```py
#  _pic_spider.py  # 图片爬虫
class CoverPicSpider(scrapy.Spider):
    name = "bpic"
    start_urls = []  # 这里装的是图片的链接

    def parse(self, res):
        bang_id = res.url.split("/")[-1].split("_")[0]
        item = AnimeBangCoverPicItem()  # 自定义的一个类  表示图片
        item['file_name'] = "p_" + bang_id + ".jpg"
        item['image_urls'] = [res.url]  # Must be a list
        yield item

```

配置一个文件名
```py
# items.py
# 定义一个图片类
class AnimeBangCoverPicItem(scrapy.Item):
    image_urls = scrapy.Field()
    images = scrapy.Field()
    file_name = scrapy.Field()
```

在`Pipeline`中重命名图片。重写方法`file_path`，返回我们自定义的文件名
```py
# pipelines.py  # 执行保存文件的地方
from scrapy.exceptions import DropItem
from scrapy.pipelines.images import ImagesPipeline

class AnimeBangCoverPicPipeline(ImagesPipeline):
    def get_media_requests(self, item, info):
        for image_url in item['image_urls']:
            # 传入目标文件名
            yield scrapy.Request(image_url, meta={'item': item, 'file_name': item['file_name']})

    #  重写这个方法来自定义文件名
    def file_path(self, request, response=None, info=None):
        return request.meta['file_name']

    def item_completed(self, results, item, info):
        image_paths = [x['path'] for ok, x in results if ok]
        if not image_paths:
            raise DropItem("Item contains no images")
        return item

```

设置图片存储目录，设置DOWNLOAD_DELAY
```py
# settings.py
ITEM_PIPELINES = {
    'bang.pipelines.AnimeBangCoverPicPipeline': 1,

}
IMAGES_STORE = '../res_data/anime_pic/'
DOWNLOAD_DELAY = 0.25
```

启动爬虫即可开始下载图片


参考资料
> http://scrapy-chs.readthedocs.io/zh_CN/latest/topics/selectors.html#topics-selectors-htmlcode
