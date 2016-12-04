---
title: 命令模式 Command Pattern
date: 2017-03-23 23:21:39
category: Design_pattern
tag: [Java,design_pattern]
toc: true
---


## 定义
将一个请求封装成一个对象。从而让你使用不同的请求把客户端参数化，对请求排队或者记录请求日
志，可以提供命令的撤销和恢复功能。

这是个高内聚的模式。

把请求方和执行方分开了。内聚到了命令里面。

## 优缺点
优点是：
* 类间解耦 - 调用者和接受者角色之间没有任何依赖关系
* 易于扩展
* 可以结合其他模式

缺点是Command命令类容易膨胀

高层次的模块不需要知道接收者（执行者）是谁。

## 代码示例
### 篮球队训练指令
以篮球训练为例，定义一些命令
```
command/
|-- cmd
|   |-- Command.java // 命令抽象类 - 在这里是战术
|   |-- InsideCommand.java // 打内线
|   `-- ThreePointCommand.java // 三分战术
|-- Coach.java // 教练
|-- player     
|   |-- Center.java // 中锋
|   |-- Player.java // 运动员抽象类
|   |-- PointGuard.java    // 控卫
|   `-- SmallForward.java  // 小前锋
`-- TestMain.java // 测试代码
```

先看指令抽象类，里面有对具体接收者的引用
```java
public abstract class Command {

    // 能够调动的人员
    protected Center center = new Center();
    protected PointGuard pointGuard = new PointGuard();
    protected SmallForward smallForward = new SmallForward();

    public abstract void execute();
}
```

运动员抽象类。运动员能执行一些动作。
```java
public abstract class Player {

    public abstract void run();

    public abstract void shoot();

    public abstract void passBall();

    public abstract void catchBall();

    public abstract void dunk();
}
```

教练类，就是指挥者
```java
public class Coach {
    private Command command;

    public void setCommand(Command command) {
        this.command = command;
    }

    public void action() {
        this.command.execute();
    }
}
```

以下是各个人员类
```java
public class Center extends Player {
    @Override
    public void run() {
        System.out.println("Center is running.");
    }

    @Override
    public void shoot() {
        System.out.println("Center shoots the ball");
    }

    @Override
    public void passBall() {
        System.out.println("Center passes ball");
    }

    @Override
    public void catchBall() {
        System.out.println("Center got the ball");
    }

    @Override
    public void dunk() {
        System.out.println("Center dunk!");
    }
}

public class PointGuard extends Player {
    @Override
    public void run() {
        System.out.println("PointGuard is running.");
    }

    @Override
    public void shoot() {
        System.out.println("PointGuard shoots the ball");
    }

    @Override
    public void passBall() {
        System.out.println("PointGuard passes ball");
    }

    @Override
    public void catchBall() {
        System.out.println("PointGuard got the ball");
    }

    @Override
    public void dunk() {
        System.out.println("PointGuard dunk!");
    }
}

public class SmallForward extends Player {
    @Override
    public void run() {
        System.out.println("SmallForward is running.");
    }

    @Override
    public void shoot() {
        System.out.println("SmallForward shoots the ball.");
    }

    @Override
    public void passBall() {
        System.out.println("SmallForward passes the ball.");
    }

    @Override
    public void catchBall() {
        System.out.println("SmallForward got the ball.");
    }

    @Override
    public void dunk() {
        System.out.println("SmallForward dunk.");
    }
}

```

以下是简单的2个命令（战术）
```java
public class InsideCommand extends Command {
    public InsideCommand() {

    }
    @Override
    public void execute() {
        System.out.println(getClass().getSimpleName() + ":");
        super.pointGuard.catchBall();
        super.center.run();
        super.pointGuard.passBall();
        super.center.catchBall();
        super.center.dunk();
    }
}

public class ThreePointCommand extends Command {
    public ThreePointCommand() {

    }
    @Override
    public void execute() {
        System.out.println(getClass().getSimpleName() + ":");
        super.center.passBall();
        super.pointGuard.catchBall();
        super.smallForward.run();
        super.pointGuard.passBall();
        super.smallForward.catchBall();
        super.pointGuard.run();
        super.smallForward.passBall();
        super.pointGuard.catchBall();
        super.pointGuard.shoot();
    }
}
```

测试代码。定义一个教练，然后把战术实例交给教练，教练指挥队员执行战术
```java
    Coach coach = new Coach();
    Command command1 = new InsideCommand();
    Command command2 = new ThreePointCommand();
    coach.setCommand(command1);
    coach.action();
    System.out.println("------------------------------");
    coach.setCommand(command2);
    coach.action();
```

输出
```
InsideCommand:
PointGuard got the ball
Center is running.
PointGuard passes ball
Center got the ball
Center dunk!
------------------------------
ThreePointCommand:
Center passes ball
PointGuard got the ball
SmallForward is running.
PointGuard passes ball
SmallForward got the ball.
PointGuard is running.
SmallForward passes the ball.
PointGuard got the ball
PointGuard shoots the ball
```


> 参考：  《设计模式之禅》  秦小波
