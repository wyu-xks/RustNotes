---
title: 工厂方法 Java
date: 2017-01-15 22:17:01
category: Design_pattern
tag: [design_pattern]
toc: true
---


## 使用场景
客户代码不知道该对几个类中的哪一个类进行实例化。我们可以利用工厂方法模式定义一个用于
创建对象的接口，同时控制对哪个类进行实例化。

所有需要生成对象的地方都可以使用此方法。要慎重考虑是否要增加一个工厂类进行管理。


### 工厂方法模式的特征
* 该方法创建了一个新的对象
* 该方法的返回类型为一个抽象类或接口
* 有若干个类实现了上述抽象模型

工厂方法到底实例化什么样的类取决于客户代码调用的时哪一个类的工厂方法。

### 例子
#### Arrays.asList()并不符合工厂方法模式的设计意图
虽然Arrays.asList()方法实例化了一个对象，并且其返回类型为一个接口，但是此方法为所有用户都实例
化了同一个类型的对象，并不符合工厂方法的设计意图。工厂方法模式的核心是，让对象的创建者代替用户确定应该实例化哪一个类。

#### toString()方法并不属于工厂方法
toString()方法总是返回一个String对象。实现了toString()方法的类并不能决定实例化什么样的类。
因而这不是工厂方法模式的一个例子。

#### 典型例子：迭代器
通常iterator()方法本事是工厂方法模式的一个很好的例子。该方法让调用方无需了解所要实例化的类。
Java JDK（例如1.8.0）中所有集合类都要实现Collection接口，该接口包含一个iterator()方法。

以JDK1.8.0为例  
Iterator<E>接口如下
```java
public interface Iterator<E> {

    boolean hasNext();
    E next();
    default void remove() {
        throw new UnsupportedOperationException("remove");
    }
    default void forEachRemaining(Consumer<? super E> action) {
        Objects.requireNonNull(action);
        while (hasNext())
            action.accept(next());
    }
}
```
ArrayList中的iterator()方法返回一个Itr对象
```java
public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable
{      
    public Iterator<E> iterator() {
            return new Itr();
    }
    private class Itr implements Iterator<E> {
            // ......
    }
}
```
LinkedList的iterator()返回的是另一种对象。  
`LinkedList<E>` <-- `AbstractSequentialList<E>` <-- `AbstractList<E>`

```java
public ListIterator<E> listIterator() {
    return listIterator(0);
}
public ListIterator<E> listIterator(final int index) {
    rangeCheckForAdd(index);

    return new ListItr(index);
}
private class ListItr extends Itr implements ListIterator<E> {
    // ......
}
private class Itr implements Iterator<E> {
    // ......
}
```

## 工厂方法模式的扩展
### 缩小为简单工厂模式
一个模块仅需要一个工厂类，没有必要实例化这个工厂类，添加使用生产“产品”对象的静态方法即可。

### 升级为多个工厂类
情况：初始化一个对象很费精力，所有产品类放到一个工厂方法中进行初始化会使代码结构不清晰。

对策：使用多个工厂类。

### 延迟初始化（Lazy initialization）
一个对象被消费完毕后，并不立刻释放，工厂类保持其初始状态，等待再次被使用。  
线程池的设计思想是否满足此条件？



> 参考：
> 《设计模式Java手册》 Steven Jhon Metsker
> 《设计模式之禅》  秦小波
> JDK1.8
