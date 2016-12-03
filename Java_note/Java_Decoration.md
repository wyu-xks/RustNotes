---
title: 装饰者模式 Decorator Pattern
date: 2015-04-29 22:11:39
category: Java_note
tag: [Java,Design_pattern]
---
在不必改变原类文件和使用继承的情况下，动态地扩展一个对象的功能。
装饰者与被装饰者拥有共同的超类，继承的目的是继承类型，而不是行为

## 使用示例
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
