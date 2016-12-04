---
title: Java断言
date: 2015-04-26 22:11:39
category: Java_note
tag: [Java]
---


断言是一条需要在程序的某处确认为true的布尔表达式。

编写代码时，我们总是会做出一些假设，断言就是用于在代码中捕捉这些假设  
可以将断言看作是异常处理的一种高级形式  
断言表示为一些布尔表达式，程序员相信在程序中的某个特定点该表达式值为真

若表达式的值为false，程序将会终止并报告一条出错信息。
断言是在调试中使用的，程序运行时不应该依赖断言。
断言在默认情况下是关闭的。

例子：
在Paper类的main函数中有：
```java
        int a = -1;
        assert a > 0 : "Not good!";
        System.out.println("So far, the code is good");
```
执行时加上参数 -ea 启用断言；如果不启用断言，程序将执行下去

```
~/workspace_rust/AlgorithmsFourthEdition/src$ javac Paper.java
~/workspace_rust/AlgorithmsFourthEdition/src$ java Paper
So far, the code is good
~/workspace_rust/AlgorithmsFourthEdition/src$ java -ea Paper
Exception in thread "main" java.lang.AssertionError: Not good!
	at Paper.main(Paper.java:21)
```
