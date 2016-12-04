---
title: 访问者模式 Visitor Pattern
date: 2017-03-29 19:55:51
category: Design_pattern
tag: [design_pattern, Java]
toc: true
---


## 定义
封装一些作用于某种数据结构中的各元素的操作，它可以在不改变数据结构的前提下定义作用
于这些元素的新的操作。

通用源码结构
```
IVisitor        // 访问者接口
Visitor         // 具体访问者
Element         // 抽象元素类
ConcreteElement1// 具体元素类1
ConcreteElement2// 具体元素类2
ObjectStructure // 结构对象 - 暂时用于产生具体元素
```

元素抽象类和具体元素类
```java
public abstract class Element {

    public abstract void doSomething();

    public abstract void accept(IVisitor visitor); // 依赖访问者接口

}

// 具体元素类1
public class ConcreteElement1 extends Element {
    @Override
    public void doSomething() {
        // 业务逻辑放这里
        System.out.println(getClass().getSimpleName() + " do something.");
    }

    @Override
    public void accept(IVisitor visitor) {
        visitor.visit(this); // 将自身传入来访者
    }
}
public class ConcreteElement2 extends Element {
    @Override
    public void doSomething() {
        System.out.println(getClass().getSimpleName() + " do something.");
    }

    @Override
    public void accept(IVisitor visitor) {
        visitor.visit(this); // 将自身传入来访者
    }
}
```

访问者接口，依赖了具体的元素类
```java
public interface IVisitor {

    void visit(ConcreteElement1 element1);

    void visit(ConcreteElement2 element2);
}

public class Visitor implements IVisitor {

    @Override
    public void visit(ConcreteElement1 element1) {
        element1.doSomething(); // 实现具体的访问操作
    }

    @Override
    public void visit(ConcreteElement2 element2) {
        element2.doSomething();
    }
}
```

结构对象 - 暂时用于产生具体元素
```java
// 生成具体的元素类
public class ObjectStructure {
    public static Element createElement() {
        Random random = new Random();// 随机产生一些具体元素类实例
        if (random.nextInt(100) > 50) {
            return new ConcreteElement1();
        } else {
            return new ConcreteElement2();
        }
    }
}
```

测试代码
```java
Visitor visitor = new Visitor();
for (int i = 0; i < 4; i++) {
    Element el = ObjectStructure.createElement();
    el.accept(visitor);
}

/*
 output
 ConcreteElement1 do something.
 ConcreteElement2 do something.
 ConcreteElement2 do something.
 ConcreteElement2 do something.
 */
```

## 访问者模式的应用
### 优点
* 符合单一职责原则  
具体元素角色负责数据的加载，而访问者负责数据的展现。
* 扩展性好，灵活性高  
职责分开，访问者可以灵活的扩展方法

### 缺点
具体元素对访问者公布细节  
访问者要访问一个类就必然要求这个类公布一些方法和数据，也就是访问者关注了其他类的内部
细节，这是迪米特法则不建议的

具体元素变更比较困难   
如果具体元素增加属性，对应的所有visitor也要修改

违背了依赖倒置原则  
访问者依赖的是具体元素而不是抽象元素，破坏了依赖倒置原则。

### 使用场景
一个对象结构包含很多类对象，它们有不同的接口，而需要对这些对象实施一些依赖其具体类
的操作，也就是迭代器模式已不能胜任的场景。

需要对一个对象结构中的对象进行很多不同并且不相关的操作。

总结：业务规则要求遍历多个不同的对象。



> 参考：《设计模式之禅》  秦小波
