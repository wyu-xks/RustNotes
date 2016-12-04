---
title: 状态模式 State Pattern
date: 2017-03-30 19:11:11
category: Design_pattern
tag: [design_pattern, Java]
toc: true
---


## 定义
当一个对象内在状态改变时允许其改变行为，这个对象看起来想改变了其类。

状态模式的核心是封装，状态的变更引起了行为的变更，从外部看起来就好像这个对象对应的
类发生了改变一样。

## 应用
优点：  
* 结构清晰，避免了过多的if..else或switch
* 遵循了开闭原则和单一职责原则，每个状态都是一个子类
* 封装性好，状态变换放置到类的内部实现

缺点：  
* 子类数量会太多

使用场景：  
行为随状态改变而改变的场景  
条件、分支语句的替代者

在写控制无人机的状态的心得：要让状态之间的跳转形成一个闭环。

## 代码示例
### 模拟电梯示例
模拟一部电梯。电梯有多种状态。  
代码目录
```
LiftContext             // 操控者
LiftState               // 状态抽象类
ClosingState            // 关门
OpeningState            // 开门
RunningState            // 上下运行
StoppingAndCloseState   // 停止并且门关着
StoppingAndOpenState    // 停止并且门开着
```

各个状态的代码
```java
public abstract class LiftState {

    protected LiftContext liftContext;

    public void setLiftContext(LiftContext liftContext) {
        this.liftContext = liftContext;
    }

    public abstract void openDoor();

    public abstract void closeDoor();

    public abstract void run();

    public abstract void stop();
}

public class ClosingState extends LiftState {
    @Override
    public void openDoor() {
        super.liftContext.setLiftState(LiftContext.OPENING_STATE);
        super.liftContext.openDoor();
    }

    @Override
    public void closeDoor() {
        System.out.println("Close door");
    }

    @Override
    public void run() {
        super.liftContext.setLiftState(LiftContext.RUNNING_STATE);
        super.liftContext.run();
    }

    @Override
    public void stop() {
        super.liftContext.setLiftState(LiftContext.STOPPING_AND_CLOSE_STATE);
        super.liftContext.stop();
    }
}

public class OpeningState extends LiftState {
    @Override
    public void openDoor() {
        System.out.println("open the door");
    }

    @Override
    public void closeDoor() {
        super.liftContext.setLiftState(LiftContext.CLOSING_STATE);
        super.liftContext.closeDoor();
    }

    @Override
    public void run() {
        System.out.println("(Opening, I can not run)"); // can't run now
    }

    @Override
    public void stop() {
        // already stopped, do nothing. But door is open
    }
}

public class RunningState extends LiftState {
    @Override
    public void openDoor() {
        System.out.println("(Running, can't open door)");
    }

    @Override
    public void closeDoor() {
        System.out.println("(Running, the door is already closed)");
    }

    @Override
    public void run() {
        System.out.println("Running up or down...");
    }

    @Override
    public void stop() {
        super.liftContext.setLiftState(LiftContext.STOPPING_AND_CLOSE_STATE);
        super.liftContext.stop();
    }
}

public class StoppingAndCloseState extends LiftState {
    @Override
    public void openDoor() {
        super.liftContext.setLiftState(LiftContext.STOPPING_AND_OPEN_STATE);
        super.liftContext.openDoor();
    }

    @Override
    public void closeDoor() {
        System.out.println("close the door");
    }

    @Override
    public void run() {
        super.liftContext.setLiftState(LiftContext.RUNNING_STATE);
        super.liftContext.run();
    }

    @Override
    public void stop() {
        System.out.println("Stop and door is close");
    }
}

public class StoppingAndOpenState extends LiftState {
    @Override
    public void openDoor() {
        System.out.println("open the door");
    }

    @Override
    public void closeDoor() {
        super.liftContext.setLiftState(LiftContext.STOPPING_AND_CLOSE_STATE);
        super.liftContext.closeDoor();
    }

    @Override
    public void run() {
        System.out.println("(can't run, please close the door first!)");
    }

    @Override
    public void stop() {
        System.out.println("(already open)");
    }
}
```

电梯Context代码；依赖于各个具体状态类
```java
public class LiftContext {

    public final static OpeningState OPENING_STATE = new OpeningState();
    public final static ClosingState CLOSING_STATE = new ClosingState();
    public final static RunningState RUNNING_STATE = new RunningState();
    public final static StoppingAndCloseState STOPPING_AND_CLOSE_STATE = new StoppingAndCloseState();
    public final static StoppingAndOpenState STOPPING_AND_OPEN_STATE = new StoppingAndOpenState();

    private LiftState liftState;

    public LiftState getLiftState() {
        return liftState;
    }

    public void setLiftState(LiftState liftState) {
        this.liftState = liftState;
        this.liftState.setLiftContext(this);
    }

    public void openDoor() {
        this.liftState.openDoor();
    }

    public void closeDoor() {
        this.liftState.closeDoor();
    }

    public void run() {
        this.liftState.run();
    }

    public void stop() {
        this.liftState.stop();
    }
}
```

测试代码，模拟电梯的一段运行状态
```java
    LiftContext liftContext = new LiftContext();
    liftContext.setLiftState(LiftContext.STOPPING_AND_CLOSE_STATE);
    liftContext.closeDoor();
    liftContext.openDoor();// somebody goes in
    liftContext.closeDoor();
    liftContext.run();
    liftContext.stop();
    liftContext.openDoor();// somebody leaves
    liftContext.run();
    liftContext.stop();
    liftContext.closeDoor();
    liftContext.run();
    liftContext.openDoor();

/* 控制台输出
close the door
open the door
close the door
Running up or down...
Stop and door is close
open the door
(can't run, please close the door first!)
(already open)
close the door
Running up or down...
(Running, can't open door)
*/
```

> 参考：《设计模式之禅》  秦小波
