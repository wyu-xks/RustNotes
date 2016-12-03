---
title: Interface vs. abstract class
date: 2015-04-24 22:11:39
category: Java_note
tag: [Java]
---

Choosing interfaces and abstract classes is not an either/or proposition. If you need to change your
 design, make it an interface. However, you may have abstract classes that provide some default
behavior. Abstract classes are excellent candidates inside of application frameworks.
择接口和抽象类是不是一个非此即彼的命题。如果你需要修改你的设计，使用接口。然而，你可以使用抽象类来提供一些
默认的方法。在应用框架中，抽象类是一个很好的选择。

Abstract classes let you define some behaviors; they force your subclasses to provide others.
For example, if you have an application framework, an abstract class may provide default services
such as event and message handling. Those services allow your application to plug in to your
application framework. However, there is some application-specific functionality that only your
application can perform. Such functionality might include startup and shutdown tasks, which are
often application-dependent. So instead of trying to define that behavior itself, the abstract base
 class can declare abstract shutdown and startup methods. The base class knows that it needs those
methods, but an abstract class lets your class admit that it doesn't know how to perform those
actions; it only knows that it must initiate the actions. When it is time to start up,
the abstract class can call the startup method. When the base class calls this method, Java
 calls the method defined by the child class.
抽象类让你定义一些操作；并且强迫子类去提供另外的方法。比如，你有一个应用框架，一个抽象类可以提供像是处理
消息和事件的默认服务。这些服务允许你的应用连接到应用框架。然而，一些应用独有的功能只能在你的应用中使用。
独有的功能比如应用依赖的启动和关闭任务。抽象类可以声明抽象的关闭和启动方法，而不用再自己定义。基础类知道它
需要这些方法，但你的子类不知道如何去实现那些方法，只知道必须继承这些动作。需要启动时，抽象类能调用启动方法。
当基类调用这个方法，Java调用子类复写的方法。

Many developers forget that a class that defines an abstract method can call that method as well.
Abstract classes are an excellent way to create planned inheritance hierarchies.
They're also a good choice for nonleaf classes in class hierarchies.
很多开发者忘记了定义了抽象方法的类也能够调用这些方法。抽象类是一个很好的方法来创建计划的继承层次结构。
它们对于类继承中的非叶层次是一个好的选择。

From: http://www.javaworld.com/article/2077421/learn-java/abstract-classes-vs-interfaces.html
