---
title: 适配器模式 Adapter Pattern
date: 2017-03-26 15:35:01
category: Design_pattern
tag: [design_pattern]
toc: true
---

## 定义
将一个类的接口变换成客户端锁期待的另一种接口，从而使原本因接口不匹配而无法工作在一起的两个类
能够在一起工作。  
也叫作变压器模式，亦称包装模式，但包装模式不止一个。  
简单而言，适配器模式就是把一个接口或类转换成其他的接口或类。

## 应用
优点：
* 可以让没有任何关系的类在一起运行
* 增加了类的透明性
* 提高了类的复用度
* 灵活度好

注意事项：在详细阶段不要考虑适配器模式，它主要是用来解决正在服役的项目问题

## 代码示例
### 向已运行的系统添加新增的用户类型
文件目录如下
```
adapter/
├── sadapter  // 新增的适配器代码
│   ├── SecondUserAdapter.java
│   ├── SecondUserAddress.java
│   └── SecondUser.java
├── stable    // 已经在运行的代码，不可变
│   ├── FirstUser.java
│   └── IFirstUser.java
├── TestAdapter.java // 测试代码
└── updated   // 第三方提供的接口，不可变
    ├── ISecondUserAddress.java
    └── ISecondUser.java
```

首先看已经在运行的部分 （stable）
```java
public interface IFirstUser {
    void printInfo();
}
public class FirstUser implements IFirstUser {

    private String username;

    public FirstUser(String username) {
        this.username = username;
    }

    @Override
    public void printInfo() {
        System.out.println(this.username);
    }
}
```

再看按需求添加的部分 （updated）
```java
public interface ISecondUser {
    void printUsername();
}
public interface ISecondUserAddress {
    void printAddress();
}
```

为此新建的适配器 （sadapter）  
分别新建2个类来实现接口
```java
public class SecondUser implements ISecondUser {

    private String username;

    public SecondUser(String name) {
        this.username = name;
    }

    @Override
    public void printUsername() {
        System.out.print(username + " ");
    }
}

public class SecondUserAddress implements ISecondUserAddress {

    private String addr;

    public SecondUserAddress(String address) {
        this.addr = address;
    }

    @Override
    public void printAddress() {
        System.out.print(this.addr);
    }
}
```

适配器持有这两个接口的引用，并实现原有的接口
```java
public class SecondUserAdapter implements IFirstUser {

    private ISecondUser iSecondUser;
    private ISecondUserAddress iSecondUserAddress;

    public SecondUserAdapter(ISecondUser iSecondUser, ISecondUserAddress iSecondUserAddress) {
        this.iSecondUser = iSecondUser;
        this.iSecondUserAddress = iSecondUserAddress;
    }

    @Override
    public void printInfo() {
        iSecondUser.printUsername();
        iSecondUserAddress.printAddress();
    }
}
```

适配器构建完毕，测试代码
```java
        IFirstUser user1 = new FirstUser("User1");
        user1.printInfo();
        SecondUserAdapter userAdapter = 
            new SecondUserAdapter(new SecondUser("SUser2"),new SecondUserAddress("5 street"));
        userAdapter.printInfo();
```
output
```
User1
SUser2 5 street
```
最吸引人的地方就是适配器实现了原有的接口。需求变化时，可尽量少的改动已有代码。



> 参考：《设计模式之禅》  秦小波
