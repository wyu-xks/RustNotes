---
title: 模板方法模式 Template Method Pattern
date: 2017-03-19 17:10:01
category: Design_pattern
tag: [design_pattern, Java]
toc: true
---


## 定义
Define the skeleton of an algorithm in an openration, deferring 
some steps to subclasses.Template Method lets subclasses redifine 
centain steps of an algorithm without changing the algorithm's structure.

基本方法：  
也叫基本操作，由子类实现，并且在模板方法中被调用。

模板方法：  
可以有一个或几个，一般是一个具体的方法，也就是一个框架，实现对基本方法的调度，完成固定的逻辑。

> 为防止恶意的操作，一般模板方法都加上final关键字，不允许被覆写。

## 应用
### 优点
* 封装不变部分，扩展可变部分
* 提取公共部分代码，便于维护
* 行为由父类控制，子类实现

### 使用场景
* 多个子类有公有的方法，并且基本逻辑相同
* 重要、复杂的算法，可以把核心算法设计为模板方法，细节由子类实现
* （重构时）把相同代码提取到父类中，然后通过钩子函数约束其行为

父类中可以设置一些属性，子类可以去覆盖这些属性来改变行为。


> 参考：《设计模式之禅》  秦小波
