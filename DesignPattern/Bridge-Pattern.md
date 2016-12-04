---
title: 桥接模式 Bridge Pattern
date: 2016-04-01 23:15:10
category: Design_pattern
tag: [design_pattern]
toc: true
---

## 定义
将抽象和实现解耦，使得两者可以独立地变化

## 代码示例
### 工厂生产产品模拟
模拟工厂生产销售产品  
文件目录
```
bridge/
|-- Client.java             // 测试代码
|-- factory
|   |-- CanFactory.java     // 罐头工厂
|   `-- ModernFactory.java  // 现代化工厂
|-- Factory.java            // 工厂的抽象类
|-- product
|   |-- Can.java            // 产品具体类 罐头
|   `-- Toy.java            // 产品具体类 玩具
`-- Product.java            // 产品的抽象类
```

产品类相关代码
```java
public abstract class Product {

    protected void made() {
        System.out.println(getClass().getSimpleName() + " has been made");
    }
    protected void  sold() {
        System.out.println(getClass().getSimpleName() + " has been sold");
    }

}

public class Can extends Product {

    @Override
    public void made() {
        super.made();
    }

    @Override
    public void sold() {
        super.sold();
    }
}

public class Toy extends Product {
    @Override
    public void made() {
        super.made();
    }

    @Override
    public void sold() {
        super.sold();
    }
}
```

工厂相关代码
```java
public abstract class Factory {

    private Product product; // 引用抽象的产品类

    public Factory(Product p) {
        this.product = p;
    }

    public void makeMoney() {
        product.made();
        product.sold();
    }
}

public class CanFactory extends Factory {

    // 只接受Can类
    public CanFactory(Can p) {
        super(p);
    }

    @Override
    public void makeMoney() {
        super.makeMoney();
        System.out.println(getClass().getSimpleName() + " make money!");
    }
}

public class ModernFactory extends Factory {
    // 只要是Product即可生产
    public ModernFactory(Product p) {
        super(p);
    }

    @Override
    public void makeMoney() {
        super.makeMoney();
        System.out.println("ModernFactory make money!");
    }
}
```

测试与输出
```java
Can can = new Can();
CanFactory canFactory = new CanFactory(can);
canFactory.makeMoney();
ModernFactory modernFactory = new ModernFactory(new Toy());
modernFactory.makeMoney();
/*
Can has been made
Can has been sold
CanFactory make money!
Toy has been made
Toy has been sold
ModernFactory make money!
*/
```
