---
title: Effective Java note
date: 2015-05-20 22:11:01
category: Java_note
tag: [Java,Read]
toc: true
---


Effective Java 2nd edition - Joshua Bloch

## 1. 考虑用静态工厂方法代替构造器
静态工厂方法（static factory method），返回类的实例的静态方法；不对应于设计模式中的工厂方法模式

静态工厂方法相对于构造器的优势：
- 有名称  易读
- 不必每次调用它们时都创建一个新对象
- 可以返回原返回类型的任何子类型的对象
- 在创建参数画类型实例的时候，代码更加简洁

缺点：
- 类如果不含公有的或者受保护的构造器，就不能被子类化
- 它们与其他的静态方法实际上没区别

## 2. 遇到多个构造器参数时要考虑用构建器
静态工厂和构造器有个共同的局限性：都不能很好地扩展到大量的可选参数

重叠构造器（telescoping constructor）模式  
这种模式很常见，不断地扩展参数。第一个构造器参数很少，接下来几个构造器可选参数越来越多。

弊端：重叠构造器模式虽然可行，但在有许多参数情况下，客户端代码会很难写，且难读。

替代方法：JavaBeans模式  
在这种模式下，调用一个无参构造器来创建对象，然后调用setter方法来设置每个必要的参数，以及可选参数  
以一个cube类为例：

```java
class cube {
    private int length;
    private int wide;
    private int high;
    private int color;
    private String name;
    /* 重叠构造器 */
    public cube(int x, int y, int z) {
        this(x, y, z, 0);
    }

    public cube(int x, int y, int z, int color) {
        this(x, y, z, 0, null);
    }

    public cube(int x, int y, int z, int color, String name) {
        this.length = x;
        this.wide = y;
        this.high = z;
        this.color = color;
        this.name = name;
    }
    //......
}
```
JavaBeans模式的cube2类：

```java
class cube2 {
    private int length = 1;
    private int wide = 1;
    private int high = 1;
    private int color = 1;
    private String name = "";
    /* JavaBeans 模式，用setter方法来设置参数 */
    public cube2() {
    }

    public void setLength(int length) {
        this.length = length;
    }

    public void setWide(int wide) {
        this.wide = wide;
    }

    public void setHigh(int high) {
        this.high = high;
    }

    public void setColor(int color) {
        this.color = color;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```
调用起来就是：
```java
        Cube cube = new Cube(1, 1, 1);
        Cube2 cube2 = new Cube2();
        cube2.setName("CUBE2");
        cube2.setHigh(1);
        cube2.setWide(1);
        cube2.setLength(1);
```
JavaBeans模式的代码读起来比较容易；但是也可能遗漏一些东西。构造过程被分到了几个调用中，在构造过程中javaBean可能处于不一致的状态。需要额外地保证它的线程安全。

替代方法：Builder模式  既要安全，可读性也要好  
不直接生成想要的对象，而是让客户端利用所有必要的参数调用构造器（或者静态工厂）得到一个builder对象。
然后客户端在builder对象上调用类似setter的方法来设置每个相关的可选参数。
最后，客户端调用无参的build方法来生成不可变的对象

以Cube3为例：
```java
class Cube3 {
    private int length = 1;
    private int wide = 1;
    private int high = 1;
    private int color = 1;
    private String name = "";

    public static class Builder {
        /* 必要参数 */
        private int color;
        private String name;

        /* 默认参数，已经设置好 */
        private int length = 1;
        private int wide = 1;
        private int high = 1;

        /* 一定要输入必要参数 */
        public Builder(int color, String name) {
            this.color = color;
            this.name = name;
        }

        public Builder length(int len) {
            length = len;
            return this;
        }

        public Builder wide(int w) {
            wide = w;
            return this;
        }

        public Builder high(int h) {
            high = h;
            return this;
        }

        public Cube3 build() {
            return new Cube3(this);/* 传入builder */
        }
    }

    private Cube3(Builder builder) {
        color = builder.color;
        name = builder.name;
        high = builder.high;
        wide = builder.wide;
        length = builder.length;
    }
}
```
构建Cube3时：
```java
        Cube3 cube3 = new Cube3.Builder(0, "CUBE3")
                .high(2).wide(2).length(2)
                .build();/* 最后一定要调用build方法 */
```
客户端代码易于编写，也易读。builder模式模拟了具名的可选参数。  
builder可以有多个可变参数，利用单独的方法来设置参数  
为了创建对象，必须先创建它的构建器。可能比重叠构造器模式更加冗长，因此在有很多参数的时候才使用，比如4个或者更多。

**如果类的构造器或者静态工厂中具有多个参数，设计这种类时，Builder模式就是不错的选择。**


## 5. 避免创建不必要的对象
一般来说，最好能重用对象而不是在每次需要的时候就创建一个相同功能的对象。

`String s = new String("Don't do this!"); //DON'T DO THIS!`

该语句每次被执行时都会创建一个新的String实例，但是这些创建对象的动作全都是不必要的。
传递给String构造器的参数("Don't do this!")本身就是一个String类型，功能方面等同于构造器创建的所有对象。  
改进后：  
`String s = "do this";`

只用了一个String类型，而不是每次执行时都创建一个新的实例。

除了重用不可变的对象之外，也可以重用那些已知不会被修改的可变对象。

反面例子，一个模型的某个判断方法中，每次执行都要新建一个日期类。而这个时间是不变的。
可以用静态的初始化器来避免这种效率低的做法。  
用static将不变的对象括起来。☺

自动装箱（autoboxing），会创建多余对象。
它允许程序员将基本类型和装箱基本类型混用，按需要自动装箱和拆箱。

```java
        Long sum = 0L;//autoboxing
        for (long i = 0; i < Integer.MAX_VALUE; i++) {
            sum += i;
        }
        System.out.println(sum);
```
打错一个字母，这里创建了2^31个多余的Long实例；应该用long

## 6. 消除过期的对象引用
如果一个栈先是增长，然后再收缩，那么，从栈中弹出来的对象讲不会被当做垃圾回收。
即使使用栈的程序不再引用这些对象，它们也不会被回收。
栈内部维护这对这些对象的过期引用。

只要类是自己管理内存，程序员就应该警惕内存泄露问题。

内存泄露的常见来源-缓存。监听器和其他回调。

## 9. 总是要改写toString

toString方法应该返回对象中包含的所有令人感兴趣的信息

## 12. 使类和成员的可访问能力最小化

信息隐藏（information hiding）或封装（encapsulation）

尽可能地使每一个类或成员不被外界访问

## 16. 接口优于抽象类

### 接口和抽象类区别是什么？
抽象类允许包含某些方法的实现，但是接口不允许。  
为了实现一个由抽象类定义的类型，它必须成为抽象类的一个子类。任何一个类，只要它定义了所有
要求的方法，并且遵守通用约定，那么它就允许实现一个接口，不管这个类位于类层次的哪个地方。
Java只允许单继承，抽象类作为类型定义受到了很大限制。

现有的类很容易被更新，以实现新的接口。

接口是定义mixin（混合类型）的理想选择。

**混合类型**：  
一个类除了实现它的“基本类型”之外，还可以实现这个mixin类型，以表明它提供了某些可供选择的行为。

接口允许我们构造非层次结构的类型框架

## 17.接口只是被用于定义类型
常量接口模式是对接口的不良使用。接口不应用于到处常量。

## 18.优先考虑静态成员变量
非静态成员类的每一个实例都隐含着与外围类的一个外围实例（enclosing instance）紧密关联在
一起。在非静态类的实例方法内部，调用外围实例上的方法是有可能的，或者使用经过修饰的this也
可以得到一个指向外围实例的引用。如果一个嵌套类的实例可以在它的外围类的实例之外独立存在，
那么这个类不可能是一个非静态成员类：在没有外围实例的情况下要创建非静态成员类的实例是不可能的。

## 27.返回零长度数组而不是返回null
没有理由从一个取数组值得方法中返回null

## 29.将局部变量的作用域最小化
把一个局部变量的作用域最小化，最有力的技术是在第一次使用它的地方声明。如果一个变量在使用
之前就已经被声明了，那么这会带来理解上的混乱。

几乎每一个局部变量的声明都应该包含一个初始化表达式。

* for循环优先于while循环
* 对list循环处理时，先取出size；省去每次都取size的开销

## 31.如果要求精确地答案，请避免使用float和double
尤其是对于货币计算，用BigDecimal

## 32.如果其他类型更适合，则尽量避免使用字符串

* 字符串不适合代替其他的值类型
* 字符串不适合代替枚举类型
* 字符串不适合代替聚集类型

不要用字符串来表示实体：比如`String compoundKey = className + "#" + i.next()`  
这种用自定义分隔符的方式不可取

* 字符串也不适合代替能力表（capabilities）

## 41. 慎用重载
重载依靠不同的输入参数来判断该使用哪一个方法。
```java
    // 有这三个类
    public static String classify(Set<?> s) {
        return "Set";
    }

    public static String classify(List<?> lst) {
        return "List";
    }

    public static String classify(Collection<?> c){
        return "Collection";
    }

    public static void main(String args[]) {
        Collection<?>[] collections = {
                new HashSet<String>(),
                new ArrayList<BigInteger>(),
                new HashMap<String, String>().values()
        };
        for (Collection<?> c : collections) {
            System.out.println(classify(c));
        }
    }
```
输出的并没有“Set”这些，因为根本没调用前两个方法
对于 for 循环中的三次迭代，编译时使用的参数都是相同的：Collection<?>

输出的是
```
Collection
Collection
Collection
```
需要修改最后一个重载方法
```java
    public static String classify(Collection<?> c) {
        return c instanceof Set ? "Set" :
                c instanceof List ? "List" : "Unknown Collection";
    }
```
输出：
```
Set
List
Unknown Collection
```
对于构造器，你没有选择使用不同名称的机会；一个类的多个构造器总是重载的。在许多情况下，可以选择到处静态工厂，而不是构造器。
