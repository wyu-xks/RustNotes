---
title: 代理模式 Proxy Pattern
date: 2017-03-22 21:22:22
category: Design_pattern
tag: [design_pattern]
toc: true
---


## 定义
为其他对象提供一种代理以控制对这个对象的访问。  
也叫委托模式。许多其他模式，如状态模式、策略模式、访问者模式本质上是在更特殊的场合采用了委托模式。

主要有三个角色：  
* Subject抽象主题角色。
可以是抽象类或接口，是一个最普通的业务类型定义，无特殊要求。
* RealSubject具体主题角色。
也叫被委托角色、被代理角色。是具体业务的执行者。
* Proxy代理主题角色。
也叫委托类、代理类。负责对真实角色的应用，可以添加自定义的操作，例如预操作和善后处理。

RealSubject和Proxy都实现或继承Subject抽象主题角色。（个人倾向于接口，但要看实际情况来定）

## 优点
* 职责清晰 - 真实角色只负责实现实际的业务逻辑，不用关系其他事务。代理可以完成更多工作。
* 高扩展性 - 只要实现了接口，具体主题角色的实现可以高度地改变，而不用改代理。

## 扩展
### 普通代理
要求客户端只能访问代理角色，而不能访问真实角色。  
实际工作中，一般通过约定来禁止new一个真实角色。

#### 普通代理示例
文件目录
```
IBaseFunction.java
RealUser.java
UserProxy.java
```

抽象主题角色 `IBaseFunction.java`
```java
public interface IBaseFunction {
    void talk();
}
```

具体主题角色`RealUser.java`
```java
public class RealUser implements IBaseFunction {
    @Override
    public void talk() {
        System.out.println("Real user talk sth.");
    }
}
```

代理主题角色 `UserProxy.java`  
可以执行自定义的预操作和后续处理操作。
```java
public class UserProxy implements IBaseFunction {

    private RealUser realUser;

    public UserProxy() {
        if (this.realUser == null) {
            this.realUser = new RealUser();
        }
    }

    @Override
    public void talk() {
        prepare();
        this.realUser.talk();
        finishWork();
    }

    private void prepare() {
        System.out.println("Proxy is preparing...");
    }

    private void finishWork() {
        System.out.println("Proxy has done");
    }
}
```

测试示例
```java
    UserProxy userProxy = new UserProxy();
    userProxy.talk();
```
输出
```
Proxy is preparing...
Real user talk sth.
Proxy has done
```

### 强制代理
从真实角色找到代理角色，不允许直接操作真实角色。真实角色管理代理角色。  
高层模块只要调用getProxy（获取代理）就可以访问真实角色的所有方法。

#### 强制代理代码示例
文件目录。这里以Robot类为真实角色。
```
IRobot.java
Robot.java
RobotProxy.java
```

`IRobot` 定义了3个行为
```java
public interface IRobot {

    void login(String name, String password);

    void walk();

    void fly();
}
```

`RobotProxy` 代理中有一些准备工作。
```java
public class RobotProxy implements IRobot {

    private IRobot realRobot = null;

    public RobotProxy(IRobot _robot) {
        this.realRobot = _robot;
    }

    @Override
    public void login(String name, String password) {
        this.realRobot.login(name, password);
    }

    @Override
    public void walk() {
        System.out.println("Proxy prepares to walk");
        this.realRobot.walk();
    }

    @Override
    public void fly() {
        System.out.println("Proxy prepares to fly");
        this.realRobot.fly();
    }
}
```

真实角色`Robot`，会检查是否给自己设置了代理。如果没有代理，则不能操作。  
真实角色`Robot`有自己的name，提供用户登录功能`login(String name, String password)`
```java
public class Robot implements IRobot {

    private String name = "";
    private IRobot proxy = null;

    public Robot(String _name) {
        this.name = _name;
    }

    public String getName() {
        return name;
    }

    // get own proxy
    public IRobot getProxy() {
        this.proxy = new RobotProxy(this);
        return this.proxy;
    }

    private boolean isProxyWorking() {
        return null != this.proxy;
    }

    @Override
    public void login(String name, String password) {
        if (isProxyWorking()) {
            printf("user login: " + name);
        } else {
            outError();
        }
    }

    @Override
    public void walk() {
        if (isProxyWorking()) {
            printf(this.name + " is walking.");
        } else {
            outError();
        }
    }

    @Override
    public void fly() {
        if (isProxyWorking()) {
            printf(this.name + " is flying.");
        } else {
            outError();
        }
    }

    private void printf(String msg) {
        System.out.println(msg);
    }

    private void outError() {
        printf(this.name + ": DENY! Please use proxy!");
    }

}
```

测试代码：new一个名为"Wall-E"的Robot，不同的用户试图操作这个Robot   
第一次尝试直接操作，会得到失败信息。然后获取robot的代理robotProxy进行操作。
```java
    private static void testRobotProxy() {
        Robot robot = new Robot("Wall-E");
        robot.login("Tom", "pwd");
        robot.walk();
        robot.fly();
        System.out.println("");
        RobotProxy robotProxy = (RobotProxy) robot.getProxy();
        robotProxy.login("Jerry", "123");
        robotProxy.walk();
        robotProxy.fly();
    }
```

输出
```
Wall-E: DENY! Please use proxy!
Wall-E: DENY! Please use proxy!
Wall-E: DENY! Please use proxy!

user login: Jerry
Proxy prepares to walk
Wall-E is walking.
Proxy prepares to fly
Wall-E is flying.
```

### 代理扩展实现不同任务
代理类不仅仅可以实现主体接口，也可以实现其他接口完成不同的任务。也可以实现自己的职责。

#### 基于强制代理扩展代理类的功能代码
新增接口
```java
public interface IMessage {
    String say(String msg);
}
```

代理类增加实现接口
```java
public class RobotProxy implements IRobot, IMessage {

    private IRobot realRobot = null;

    public RobotProxy(IRobot _robot) {
        this.realRobot = _robot;
    }

    @Override
    public void login(String name, String password) {
        this.realRobot.login(name, password);
    }

    @Override
    public void walk() {
        System.out.println("Proxy prepares to walk");
        this.realRobot.walk();
    }

    @Override
    public void fly() {
        System.out.println("Proxy prepares to fly");
        this.realRobot.fly();
        say("Proxy: Flying high!");
    }

    @Override
    public String say(String msg) {
        System.out.println(msg);
        return msg;
    }
}
```

运行结果（部分）
```
user login: Jerry
Proxy prepares to walk
Wall-E is walking.
Proxy prepares to fly
Wall-E is flying.
Proxy: Flying high!
```

### 动态代理
在实现阶段不用关心代理谁，而在运行阶段才指定代理哪一个对象。  
AOP（Aspect Oriented Programming）的核心

#### 动态代理代码示例
文件目录
```
IVehicle
Tank
VehicleIH
```

定义车辆接口 `IVehicle`
```java
public interface IVehicle {

    void getIn(String username);

    void forward();

    void shoot();
}
```

定义一个类 `Tank` 实现 `IVehicle` 接口。这是真实角色。
```java
public class Tank implements IVehicle {

    private String name = "";

    public Tank(String _name) {
        this.name = _name;
    }

    @Override
    public void getIn(String username) {
        System.out.println(username + " got in tank");
    }

    @Override
    public void forward() {
        System.out.println(this.name + " forward");
    }

    @Override
    public void shoot() {
        System.out.println(this.name + " shoot!");
    }
}
```

动态代理类，实现`InvocationHandler`接口  
判断使用的方法名，并发出自定义通知
```java
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;

public class VehicleIH implements InvocationHandler {
    Class cls = null;
    Object obj = null;

    public VehicleIH(Object _obj) {
        this.obj = _obj;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        String methodName = method.getName();
        if (methodName.equalsIgnoreCase("getIn")) {
            System.out.println("VehicleIH: Somebody got in!");
        } else if (methodName.equalsIgnoreCase("forward")) {
            System.out.println("VehicleIH: Forward!");
        }
        return method.invoke(this.obj, args);
    }
}
```

测试代码
```java
IVehicle tank = new Tank("59");
InvocationHandler handler = new VehicleIH(tank);
ClassLoader cl = handler.getClass().getClassLoader();
IVehicle proxy = (IVehicle) 
    Proxy.newProxyInstance(cl, new Class[]{IVehicle.class}, handler);
proxy.getIn("Conductor Liu");
proxy.forward();
proxy.shoot();
```

输出
```
VehicleIH: Somebody got in!
Conductor Liu got in tank
VehicleIH: Forward!
59 forward
59 shoot!
```

> 参考： 《设计模式之禅》  秦小波
