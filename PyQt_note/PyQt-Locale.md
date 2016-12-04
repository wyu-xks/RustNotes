---
title: PyQt 语言国际化
date: 2017-09-20 14:39:20
category: PyQt
---


## PyQt4 语言国际化
使用`pylupdate4`将界面的py文件转成ts文件。

进入py文件所在目录，执行转换命令。
```python
/d/python27/Lib/site-packages/PyQt4/pylupdate4 ui_main.py -ts zh_CN.ts
```

得到`zh_CN.ts`文件。这个文件本质上是xml文件。
当界面的py文件修改时，运行`pylupdate4`生成ts不会破坏原ts的翻译。

用Qt语言家（Linguist）打开`zh_CN.ts`文件。可以对相应的字符串进行翻译。  
点击“发布”可获得`zh_CN.qm`文件。这就是qt的语言资源文件，是一个二进制文件。

创建app时，先加载语言资源文件`zh_CN.qm`
```python
if __name__ == '__main__':
    configs.init_configs()  # 确定语言配置
    app = QApplication(sys.argv)
    trans = QTranslator()  # Setup locale, we need .qm files
    if configs.g_locale_type == configs.LOCALE_ZH_CH:
        trans.load("res/locale/zh_CN")  # No need suffix .qm
        app.installTranslator(trans)

    main_d = FAMainWindow()
    main_d.show()
    sys.exit(app.exec_())

```

## App运行中切换语言
在程序运行时，我们可以选择当前显示的语言。不需要重新启动程序即可完成切换。

### 准备语言资源文件
以英文和简体中文为例，想要切换语言，需要这2种语言包
```
$ /d/python27/Lib/site-packages/PyQt4/pylupdate4 ui_main.py -ts zh_CN.ts
$ /d/python27/Lib/site-packages/PyQt4/pylupdate4 ui_main.py -ts en.ts
```
借助Qt语言家发布得到`en.qm`和`zh_CN.qm`这2个文件，放在`res/locale`目录里

### 在UI上设置触发切换语言
界面上需要按钮或菜单栏的action；需要持有`QTranslator`；

```python
        self.trans = QTranslator()  # 初始化时获取 QTranslator
        self._init_trans()
        # 添加了action来触发切换动作
        self.connect(self.ma.actionEnglish, SIGNAL("triggered()"), self._trigger_english)
        self.ma.action_ZhCN.triggered.connect(self._trigger_zh_cn)

    def _init_trans(self):
        ctx.read_locale_config()  # 自定义的方法，用来读取json文件中的配置
        if ctx.g_locale_type == ctx.LOCALE_ZH_CH:
            self._trigger_zh_cn()
        elif ctx.g_locale_type == ctx.LOCALE_EN:
            self._trigger_english()

    def _trigger_english(self):
        print "[MainWindow] Change to English"
        self.trans.load("res/locale/en")
        _app = QApplication.instance()  # 获取app实例
        _app.installTranslator(self.trans)
        self.ma.retranslateUi(self)
        ctx.change_to_en()  # 将新的配置更新入json文件中

    def _trigger_zh_cn(self):
        print "[MainWindow] Change to zh_CN"
        self.trans.load("res/locale/zh_CN")
        _app = QApplication.instance()
        _app.installTranslator(self.trans)
        self.ma.retranslateUi(self)
        ctx.change_to_zh_cn()
```
