---
title: Android Fragment intro
date: 2015-09-25 15:09:16
category: Android_note
tag: [Android_UI]
---

什么是Fragment，为什么要用Fragment？

Fragment，直译为碎片。是Android UI的一种。

Fragment加载灵活，替换方便。定制你的UI，在不同尺寸的屏幕上创建合适的UI，提高用户体验。

页面布局可以使用多个Fragment，不同的控件和内容可以分布在不同的Fragment上。

每个Fragment有自己的生命周期。

﻿使用Fragment，可以少用一些Activity。一个Activity可以管辖多个Fragment。

例如Android5.1的Settings界面用Fragment来布局。

Settings主界面分为4大块内容，由4个Fragment来填充。每一块有自己的标题和按钮。

点开Display --> Daydream，可以看到上方有一个开关。这也是用Fragment来实现的。

这样一个开关布局同样用在了Language & input --> Spell checker 和 Developer options 中。
