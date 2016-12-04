---
title: 备忘录模式 Memento Pattern
date: 2017-03-28 20:24:12
category: Design_pattern
tag: [design_pattern]
toc: true
---


## 定义
在不破坏封装性的前提下，补货一个对象的内部状态，并在该对象之外保存这个状态。
这样就可以将该对象恢复到原先保存的状态。

## 备忘录模式的应用
### 使用场景
* 需要保存和恢复数据的相关状态场景
* 提供一个可回滚（rollback）的操作
* 需要监控的副本场景

### 注意事项
* 备忘录的生命周期；要主动管理备忘录的声明周期
* 备忘录的性能；不要在频繁建立备份的场景中使用备忘录模式；首先要控制备忘录建立的对象
数量，其次要考虑系统的承受能力。

## 扩展
### clone方式的备忘录
使用复制的方式产生一个对象的内部状态。  
这时可以不用备忘录管理者，发起者可以自己持有自己的备份状态。

### 多状态的备忘录模式
可以将状态存入HashMap中

## 代码示例
### 备忘录示例1
文件目录
```
memento/
|-- IMemento.java       // 备忘录接口
|-- MementoManager.java // 备忘录管理者
|-- TestMemento.java    // 测试代码
`-- Worker.java         // 工作者（需要备忘的类）
```

首先看备忘录接口。这个接口没有方法。
```java
public interface IMemento {
}
```

备忘录管理者，管理着`IMemento`
```java
public class MementoManager {
    private IMemento memento;

    public IMemento getMemento() {
        return memento;
    }

    public void setMemento(IMemento memento) {
        this.memento = memento;
    }
}
```

`Worker`内部有一个备忘录
```java
public class Worker {

    private String name = "default worker";
    private String state = "origin state";

    public Worker(String name) {
        this.name = name;
    }

    public void stateChange() {
        state = "fury state";
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public Memento createMemento() {
        return new Memento(this.state);
    }

    public void loadMemento(IMemento memento) {
        this.setState(((Memento) memento).getState());
    }

    public void printState() {
        System.out.println(this.name + ", " + this.state);
    }

    private class Memento implements IMemento {

        private String state = "";

        public Memento(String state) {
            this.state = state;
        }

        public String getState() {
            return state;
        }

        public void setState(String state) {
            this.state = state;
        }
    }
}
```

测试代码
```java
Worker worker = new Worker("Tom");
worker.printState();
MementoManager mementoManager = new MementoManager();
mementoManager.setMemento(worker.createMemento());   // 备份状态
worker.stateChange(); // 更改状态
worker.printState();
worker.loadMemento(mementoManager.getMemento());     // 恢复状态
worker.printState();
```

output
```
Tom, origin state
Tom, fury state
Tom, origin state
```

> 参考资料：《设计模式之禅》  秦小波
