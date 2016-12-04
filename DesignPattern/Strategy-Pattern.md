---
title: 策略模式 Strategy Pattern
date: 2017-03-24 20:11:11
category: Design_pattern
tag: [design_pattern, Java]
toc: true
---


## 定义
Define a family of algorithm, encapsulate each one, and make them 
interchangeable.  
定义一组算法，并将每个算法都封装起来，并且使它们之间可以互相替换。

常见结构
```
Strategy            // 抽象的策略角色
ConcreteStrategy    // 具体的策略类
Context             // 持有策略实例
```
策略模式的重点是封装角色，借用了代理模式的思路。

## 应用
### 优点
* 算法可以自由切换
* 避免使用多重条件判断
* 扩展性良好

### 缺点
* 策略类数量增多  每一个策略都是一个类，复用的可能性小，类数量很多
* 所有的策略类都需要对外暴露

### 使用场景
* 多个类只有在算法或者行为上稍有不同的场景
* 算法需要自由切换的场景
* 需要屏蔽算法规则的场景

> 注意事项，如果系统中的一个策略家族的具体策略数量超过4个，则需考虑使用混合模式，解决策略类
膨胀和对外暴露的问题。

## 代码示例
### 策略模式示例
文件目录
```
strategy/
|-- Add.java            // 具体的策略
|-- Division.java       // 具体的策略
|-- IStrategy.java      // 策略接口
|-- Minus.java          // 具体的策略
|-- Paper.java          // 测试代码
`-- StrategyContext.java// 上下文角色，承上启下
```

首先看策略接口类，定义了一个方法
```java
public interface IStrategy {

    float compute(float a, float b);

}
```

上下文类，屏蔽了高层模块对策略、算法的直接访问
```java
public class StrategyContext {
    private IStrategy strategy;

    public void setStrategy(IStrategy strategy) {
        this.strategy = strategy;
    }

    public StrategyContext(IStrategy strategy) {
        this.strategy = strategy;
    }

    public float calculate(float a, float b) {
       return this.strategy.compute(a, b);
    }

}
```

具体的策略类
```java
public class Add implements IStrategy {
    @Override
    public float compute(float a, float b) {
        return a + b;
    }
}
public class Minus implements IStrategy {
    @Override
    public float compute(float a, float b) {
        return a - b;
    }
}
public class Division implements IStrategy {
    @Override
    public float compute(float a, float b) {
        return a / b;
    }
}
```

测试代码
```java
    StrategyContext context = new StrategyContext(new Add());
    System.out.println("Add Res = " + context.calculate(1, 3));
    context.setStrategy(new Minus());
    System.out.println("Minus Res = " + context.calculate(14, 8));
    context.setStrategy(new Division());
    System.out.println("Division Res = " + context.calculate(12, 5));
```

output
```java
Add Res = 4.0
Minus Res = 6.0
Division Res = 2.4
```

### 枚举策略示例
使用枚举类来封装策略。  
```java
public enum Calculator {
    ADD("+") {
        public float exec(float a, float b) {
            return a + b;
        }
    },
    SUB("-") {
        public float exec(float a, float b) {
            return a - b;
        }
    };
    String value;

    Calculator(String _value) {
        this.value = _value;
    }

    public String getValue() {
        return value;
    }

    public abstract float exec(float a, float b);
}
```

测试代码和输出
```java
    System.out.println("ENUM ADD Res = " + Calculator.ADD.exec(12, 5));
    System.out.println("ENUM SUB Res = " + Calculator.SUB.exec(2, 5));

// output
ENUM ADD Res = 17.0
ENUM SUB Res = -3.0
```

> 参考：《设计模式之禅》  秦小波
