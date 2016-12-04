---
title: Spring 初步
date: 2017-03-17 21:11:21
category: WebsiteBackstage
tag: [SpringFramework]
toc: true
---

参考：
* *Professional Java for Web Application*
* *Spring in action* 4th edition, by Craig Walls

## Spring Framework 简介
是一个Java应用程序容器，提供了许多有用的特性。

Spring Framework提供了一组数据访问工具。  
Spring Framework提供了一个松耦合的消息系统，使用的是发布-订阅模式。  
Spring Framework提供了一个模型-视图-控制器（MVC）模式框架。

### 概念介绍
#### 简单老式Java对象（Plain Old Java object， POJO）

#### 翻转控制（IoC）
IOC是一个软件设计模式：组装器（这里是Spring Framework）将在运行时而不是编译时绑定对象。

#### 依赖注入（Dependency Injection， DI）
效果：松耦合  
依赖注入的方式之一，即构造器注入（constructor injection）。  
例如将某类接口通过构造器传入对象中。  

如果一个对象只通过接口（而不是具体实现或初始化过程）来表明依赖关系，那么这种依赖就能够在对象
本身毫不知情的情况下，用不同的具体实现进行替换。（接口编程？）

对依赖进行替换的一个最常用方法就是在测试的时候使用mock实现。

作者推荐参考书：Dhanji R. Prasanna 《Dependency Injection》

#### 面向切面编程（Aspect-Oriented Programming， AOP）
面向切面编程是面向对象编程的补充。使用切面定义自己的横切关注点。  
横切关注点是影响程序多个组件的关注点（例如安全关注），通常与组件无关。  
AOP允许你把遍布应用各处的功能分离出来形成可重用的组件。  
一个POJO被声明为切面后，其他对象不需要显示地调用它。

#### 装配（wiring）
创建应用组件之间协作的行为通常称为装配。  
Spring有多种装配bean的方式，采用XML是很常见的一种装配方式。  
也可以使用基于Java的配置。使用注解`@Configuration`，`@bean`

#### Spring表达式语言（Spring Expression Language）
使用XML装配bean时使用

#### 应用上下文（Application Context）
Spring Framework容器以一个或多个应用上下文的形式存在。一个Spring应用程序至少需要一个应用上下文。

Spring通过应用上下文（ Application Context）装载bean的定义并把它们组装起来。   
Spring应用上下文全权负责对象的创建和组装。 Spring自带了多种应用上下文的实现，它们之间主要的区别仅
仅在于如何加载配置。

#### 样板式的代码（boilerplate code）
Spring旨在通过模板封装来消除样板式代码。 

## bean介绍
在基于Spring的应用中，你的应用对象生存于Spring容器（container）中。Spring容器负责创建对象，
装配它们，配置它们并管理它们的整个生命周期，从生存到死亡（在这里，可能就是new到finalize）。

容器是Spring框架的核心。 Spring容器使用DI管理构成应用的组件，它会创建相互协作的组件之间的关联。

Spring自带了多个容器实现，可归为2中不同类型。
* bean工厂（由org.springframework.beans.factory.eanFactory接口定义）提供基本的DI支持
* 应用上下文（由org.springframework.context.ApplicationContext接口定义）基于BeanFactory构建

我们主要使用应用上下文。

### 应用上下文
* AnnotationConfigApplicationContext：从一个或多个基于Java的配置类中加载Spring应用上下文。
* AnnotationConfigWebApplicationContext：从一个或多个基于Java的配置类中加载Spring Web应用上下文。
* ClassPathXmlApplicationContext：从类路径下的一个或多个XML配置文件中加载上下文定义，把应用上下文的定义文件作为类资源。
* FileSystemXmlapplicationcontext：从文件系统下的一个或多个XML配置文件中加载上下文定义。
* XmlWebApplicationContext：从Web应用下的一个或多个XML配置文件中加载上下文定义。
