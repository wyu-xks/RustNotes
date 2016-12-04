---
title: Java static 关键字
date: 2016-12-08 22:21:01
category: Java_note
tag: [Java]
toc: true
---

## 修饰类的变量
同一个类创建出来的不同实例对象，它们有各自的成员变量。

static修饰的成员变量对于所有实例对象都一致，它是一个指定的内存区域。每个实例对象访问到
的static变量都一致。每个实例对象都能访问这个static变量。在不创建实例对象时也能操作这个
static变量。这个变量被所有成员共享。

例如可以用来统计这个类被实例化了多少次。

## 修饰类的方法
static修饰的方法能够直接被引用，而不必创建对象。单例模式中获取单例对象时就用这个方式。

## 与final一起修饰常量
static和final一起修饰一个变量。final关键字表示这个变量的值不能再修改。
我们经常用这个方法来定义常量。

```java
public static final int MAX_COUNT = 100;
```

## 代码示例
定义一个`MiniPlane`类

```java
public class MiniPlane {

    private static int planeCount = 0;

    private int id;

    public MiniPlane() {
        id = ++planeCount;// ++ first
    }

    public int getID() {
        return id;
    }

    public static int getPlaneCount() {
        return planeCount;
    }
}
```
使用这个类，输出实例的ID和实例化总次数
```java
MiniPlane plane1 = new MiniPlane();// 创建一些实例
MiniPlane plane2 = new MiniPlane();
MiniPlane plane3 = new MiniPlane();
System.out.println("plane1.getID(): " + plane1.getID());
System.out.println("plane2.getID(): " + plane2.getID());
System.out.println("plane3.getID(): " + plane3.getID());
System.out.println("total plane:" + MiniPlane.getPlaneCount());
```
输出
```
plane1.getID(): 1
plane2.getID(): 2
plane3.getID(): 3
total plane:3
```
