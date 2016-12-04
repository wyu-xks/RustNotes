---
title: 原型模式 Prototype Pattern
date: 2017-03-20 21:41:02
category: Design_pattern
tag: [design_pattern]
toc: true
---


使用Java。此模式主要靠clone方法实现。

## 原型模式的定义
Specify the kinds of objects to create using a prototypical instance, 
and create new objects by copying this prototype.

核心方式就是复制（clone）

## 优点
* 性能优良。比直接new一个对象要好。
* 逃避构造函数的约束（也可能是缺点）。直接在内存中clone，不会执行构造函数。

## 使用场景
* 资源优化场景。类初始化需要消耗非常多的资源时，比如数据、硬件等
* 性能和安全有要求。new一个对象需要繁琐的数据准备或访问权限时，可使用此模式
* 一个对象多个修改者的场景

## 注意事项
### 构造函数不会执行
Object类的clone方法的原理是从内存中（堆内存）以二进制流的方式进行拷贝，
重新分配一个内存块。

### 浅拷贝和深拷贝
Object提供的clone方法只拷贝本对象，对象内部的数组、引用对象等都不拷贝，还是指向
原生对象的内部元素地址。称之为“浅拷贝”。  
深拷贝是指将类的私有变量也进行了独立的拷贝。

浅拷贝和深拷贝建议不要混合使用。

原型模式先产生出一个包含大量共有信息的类，然后可以拷贝出副本，修正细节信息，建立了一个完整
的个性对象。

> 参考： 《设计模式之禅》  秦小波
