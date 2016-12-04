---
title: Java String intern 方法解析
date: 2017-08-28 20:12:39
category: Java_note
tag: [Java]
---

Java中的String是一种比较特殊的类型，它不属于基本类型。

在计算机科学中，string interning是一种每个string值只存一份的方法。这种方法能让字符串处理工作
以时间换空间。对于节省运行内存来说有好处。这也是FlyWeight模式的体现[（享元模式）](http://rustfisher.github.io/2017/04/01/DesignPattern/Flyweight-Pattern/)

Java中`string.intern()`方法调用会先去字符串常量池中查找相应的字符串，如果字符串不存在，就会在
字符串常量池中创建该字符串然后再返回。

直接使用双引号声明出来的String对象会直接存储在常量池中。

## String intern 和引用之间的关系
* jdk1.8.0_141
* IntelliJ IDEA

测试代码
```java
    private static void iTest0() {
        String str1 = "testContent"; // 直接使用双引号声明出来的String对象会直接存储在常量池中
        String str2 = "testContent"; // 先从常量池找
        String str3 = str2.intern(); // 先去字符串常量池中查找相应的字符串

        System.out.println("str1 == str2 -> " + (str1 == str2));
        System.out.println("str1 == str3 -> " + (str1 == str3));
        System.out.println("str2 == str3 -> " + (str2 == str3));
    }
    /*
    str1 == str2 -> true
    str1 == str3 -> true
    str2 == str3 -> true
    */
```

当使用了`new String()`时，情况有些不同
```java
    private static void newStringAndIntern() {
        String s1 = new String("hello"); // 里面的[hello]已经放进常量池了
        String s2 = "hello";
        String s3 = s1.intern(); // 从常量池中获取string
        String s4 = "hello";

        System.out.println("s1 == s2 -> " + (s1 == s2)); // false because reference is different
        System.out.println("s1 == s3 -> " + (s1 == s3)); // false because reference is different
        System.out.println("s1 == s4 -> " + (s1 == s4)); // false because reference is different
        System.out.println("s2 == s3 -> " + (s2 == s3)); // true because reference is same
        System.out.println("s2 == s4 -> " + (s2 == s4)); // true because reference is same
        System.out.println("s3 == s4 -> " + (s3 == s4)); // true because reference is same
    }
```

创建新的string引用的情况
```java
    private static void appendAndIntern() {
        String str1 = "a";
        String str2 = "b";
        String str3 = "ab";
        String str4 = str1 + str2; // 一个新对象  不在常量池中
        String str5 = new String("ab");
        System.out.println(str3 == str4); // false, because reference is different
        System.out.println(str5 == str3); // false, because reference is different
        System.out.println(str5.intern() == str3); // true, 找到了String Pool中的 "ab"
        System.out.println(str5.intern() == str4); // false, 因为str4是一个新的对象
    }
```

## 使用String.intern()
为了节省内存，可以考虑使用intern方法。

但必须注意的是，当常量池中存放了太多的String后，运行速度会变慢。

参阅：
* [深入解析String#intern - 美团](https://tech.meituan.com/in_depth_understanding_string_intern.html)
