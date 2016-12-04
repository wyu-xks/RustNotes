---
title: 装饰者模式 Decorator Pattern
date: 2015-04-29 22:11:39
category: Design_pattern
tag: [design_pattern, Java]
toc: true
---


## 定义
动态的给一个对象添加一些额外的职责。就增加功能来说，装饰模式比生成子类更加灵活。  
在不必改变原类文件和使用继承的情况下，动态地扩展一个对象的功能。

装饰者与被装饰者拥有共同的超类，继承的目的是继承类型，而不是行为

> 装饰模式中，必然有一个最基本、最核心、最原始的接口或抽象类充当Component抽象构件。

装饰模式的通用结构
```
Component              // 最基本的抽象构件，接口或抽象类
    Operation()
ConcreteComponent      // 具体的构件
Decorator              // 抽象的装饰者
ConcreteComponent      // 具体的装饰者
```

## 优缺点和应用场景
优点：
* 装饰类和被装饰类可以独立发展，不会耦合
* 装饰模式是继承关系的一个替代方案
* 装饰模式可以动态地扩展一个类（扩展性好）

缺点：多层的装饰是比较复杂的。

### 应用场景
主要场景就是能发挥优点的地方  
* 扩展一个类的功能，或给一个类增加附加功能
* 动态地增加或撤销一个类的功能
* 需要为一批兄弟类进行改装或加装功能

## 代码示例
### worker示例
AWorker称为装饰者
Plumber称为被装饰者

先定义一个 Plumber，接着将其传入 AWorker 中；这样得到的是AWorker-Plumber
Carpenter 同理。这里装饰者的方法中调用的是传入对象的类的方法。

```java
/**
 * Decoration test
 */
public class Decoration {

    public static void main(String args[]) {
        Plumber plumber = new Plumber();
        AWorker aWorker = new AWorker(plumber);
        aWorker.doSomeWork();
        Carpenter carpenter = new Carpenter();
        BWorker bCarpenter = new BWorker(carpenter);
        bCarpenter.doSomeWork();
    }
}

interface Worker {
    void doSomeWork();
}

class Plumber implements Worker {
    public void doSomeWork() {
        System.out.println("Plumber do some work!");
    }
}

class Carpenter implements Worker {
    public void doSomeWork() {
        System.out.println("Carpenter do some work!");
    }
}

class AWorker implements Worker {
    private Worker tempWorker;

    public AWorker(Worker worker) {
        tempWorker = worker;
    }

    public void doSomeWork() {
        System.out.println("Hello,I am a A worker");
        tempWorker.doSomeWork();// use the Worker class method
    }
}

// use temp Worker, avoid "this"
class BWorker implements Worker {
    private Worker worker;

    public BWorker(Worker worker) {
        this.worker = worker;
    }

    public void doSomeWork() {
        System.out.println("Hello,I am a B worker");
        worker.doSomeWork();
    }
}
```

输出：
```
Hello,I am a A worker
Plumber do some work!
Hello,I am a B worker
Carpenter do some work!
```


> 参考：  《设计模式之禅》  秦小波
