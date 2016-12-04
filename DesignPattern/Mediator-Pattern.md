---
title: 中介者模式 Mediator Pattern
date: 2017-03-22 19:44:02
category: Design_pattern
tag: [design_pattern]
toc: true
---


## 定义
用一个中介对象封装一系列的对象交互，中介者使各对象不需要显示地互相作用，
从而达到松耦合的目的。

由以下几个部分组成
* mediator 抽象中介者 - 用于协调各个同事之间的交互
* Concrete mediator 具体中介者角色 - 依赖于各个同事类
* Colleague 同事角色（要被封装的对象）
每个同事角色都知道中介者角色，但不与其他同事进行交互，而是通过中介者来调度。  
同事类的行为分为2种：  
一种是同事本身的行为，比如改变对象本身的状态，处理自己的行为等等，叫自发行为（Self-Method）  
第二种是必须依赖中介者才能完成的行为，叫做依赖方法（Dep-Method）

## 优缺点
优点是减少类间的依赖，把原来的一对多的依赖关系改变成了一对一的依赖。降低耦合。  
缺点是中介者会变得很庞大，逻辑复杂。  

## 应用场景
机场调度中心；MVC框架中的Controller；中介服务，例如现实中的租房中介等等

### 进销存系统模拟代码示例
同事类有3个角色：销售，采购，库存  
一个协调者，可以看作是调度员（或经理）  

文件目录
```
AbstractMediator  // 抽象协调者类
AbstractColleague // 抽象同事类
Company           // 定义了一些常量值
Stock             // 库存
Mediator          // 具体的协调者
Purchase          // 具体的采购
Sale              // 具体的销售
```

抽象同事类`AbstractColleague.java`，持有抽象中介者的引用
```java
public abstract class AbstractColleague {
    protected AbstractMediator mediator;

    public AbstractColleague(AbstractMediator _mediator) {
        this.mediator = _mediator;
    }

}
```

抽象中介者类`AbstractMediator.java`，持有具体同事类的引用
```java
public abstract class AbstractMediator {
    protected Purchase purchase;
    protected Sale sale;
    protected Stock stock;
    public AbstractMediator() {
        purchase = new Purchase(this); // 初始化时自行实例化同事类
        sale = new Sale(this);
        stock = new Stock(this);
    }
    protected abstract void execute(String type, Object... objects);
}
```

定义一些常量
```java
public final class Company {
    public static final String SALE_SELL = "sale.sell";
    public static final String PURCHASE_BUY = "purchase.buy";
    public static final String STOCK_CLEAR = "stock.clear";
}
```

采购员类，负责采购电脑，也可以停止采购
```java
public class Purchase extends AbstractColleague {

    public Purchase(AbstractMediator mediator) {
        super(mediator);
    }

    public void buyComputer(int number) {
        super.mediator.execute(Company.PURCHASE_BUY, number);
    }

    public void refuseToBuyComputer() {
        System.out.println("采购员不再采购电脑");
    }
}
```

库存类；库存数量会增加或减少
```java
public class Stock extends AbstractColleague {

    public Stock(AbstractMediator mediator) {
        super(mediator);
    }

    // 库存数量是全局唯一的 实际项目中要注意并发问题
    private static int computerCount = 100; 

    public void increase(int number) {
        computerCount += number;
        System.out.println("增加后，库存电脑数量为 " + computerCount);
    }

    public void decrease(int number) {
        computerCount -= number;
        System.out.println("减少后，库存电脑数量为 " + computerCount);
    }

    public int getComputerCount() {
        return computerCount;
    }

    public void clearStock() {
        System.out.println("要清理的电脑库存为 " + computerCount);
        super.mediator.execute(Company.STOCK_CLEAR);
    }

}
```

销售类，能卖出电脑，获取到卖出速度（这里是随机值）
```java
public class Sale extends AbstractColleague {

    public Sale(AbstractMediator mediator) {
        super(mediator);
    }

    public void sellComputer(int number) {
        System.out.println("卖出电脑台数 " + number);
        super.mediator.execute(Company.SALE_SELL, number);
    }

    public int getSaleStatusPercent() {
        Random random = new Random(System.currentTimeMillis());
        int saleStatus = random.nextInt(100);
        System.out.println("卖电脑的速度 " + saleStatus + "%");
        return saleStatus;
    }

    public void offSale() {
        System.out.println("销售员开始打折销售");
    }
}
```

具体的中介者类;处理任务的地方
```java
public class Mediator extends AbstractMediator {

    @Override
    protected void execute(String type, Object... objects) {
        if (Company.PURCHASE_BUY.equals(type)) {
            this.buyComputerIn((Integer) objects[0]);
        } else if (Company.SALE_SELL.equals(type)) {
            this.sellComputer((Integer) objects[0]);
        } else if (Company.STOCK_CLEAR.equals(type)) {
            this.clearStock();
        }
    }

    // 在这里可以制定进销策略
    private void buyComputerIn(int number) {
        int percent = super.sale.getSaleStatusPercent();
        if (percent > 80) {
            System.out.println("销售状态不错，再采购电脑 " + number + "台");
            super.stock.increase(number);
        } else {
            int buyIn = number / 2;
            System.out.println("销售不如人意  补充采购电脑 " + buyIn + " ");
            super.stock.increase(buyIn);
        }
    }

    private void sellComputer(int number) {
        if (super.stock.getComputerCount() < number) {
            // 库存不足  先采购一些回来再卖
            super.purchase.buyComputer(number);
        }
        super.stock.decrease(number);
    }

    // 清空库存
    private void clearStock() {
        super.sale.offSale();
        super.purchase.refuseToBuyComputer();
    }

}
```

测试运行
```java
        AbstractMediator mediator = new Mediator();
        Purchase purchase = new Purchase(mediator);
        Sale sale = new Sale(mediator);
        Stock stock = new Stock(mediator);

        System.out.println("main 中的stock  " + stock.toString());
        System.out.println("mediator 中的stock  " + mediator.stock.toString());

        purchase.buyComputer(120);
        sale.sellComputer(140);
        stock.clearStock();
```
先定义出中介者，接着把中介者传入同事类中。同事类进行操作时，会通过中介者与其他同事交互。  
这里必须要注意，中介者引用的同事实例和外面new出来的同事实例不一样  
运行结果
```
main 中的stock  pattern.mediator.Stock@1b6d3586
mediator 中的stock  pattern.mediator.Stock@4554617c
卖电脑的速度 87%
销售状态不错，再采购电脑 120台
增加后，库存电脑数量为 220
卖出电脑台数 140
减少后，库存电脑数量为 80
要清理的电脑库存为 80
销售员开始打折销售
采购员不再采购电脑
```

> 参考： 《设计模式之禅》  秦小波
