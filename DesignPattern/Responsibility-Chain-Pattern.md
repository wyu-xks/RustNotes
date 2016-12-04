---
title: 责任链模式 Responsibility Chain Pattern
date: 2017-03-24 19:51:51
category: Design_pattern
tag: [design_pattern]
toc: true
---

## 定义
使多个对象都有机会处理请求，从而避免了请求的发送者和接受者之间的耦合关系。
将这些对象连成一条链，并沿着这条链传递该请求，直到有对象处理它为止。  
Avoid coupling the sender of a request to its receiver by giving more than 
one object a chance to handle the request. Chain the receiving objects and 
pass the request along the chain until an object handles it.

每个处理者都必须判断请求，如果符合条件则进行处理，否则就交给下一个处理者。

## 优缺点
有点是将请求和处理分开。请求者可以不知道是谁处理的，处理者可以不知道请求的全貌。

缺点：性能可能会不好，每个请求都是逐次往后处理。调试不算方便。

处理者链中的节点需要控制，不能出现过长的情况。

## 代码示例
### 链式处理示例1
定义一个处理任务的抽象类`Handler`
```java
public abstract class Handler {

    private Handler nextHandler;

    public final Response handleMessage(Request request) {
        Response response = new Response(Response.ERROR);
        if (this.getHandlerLevel().equals(request.getRequestLevel())) {
            response = this.deal(request);
        } else {
            if (null != this.nextHandler) {
                response = this.nextHandler.handleMessage(request);
            } else {
                System.out.println("WARNING: no handler to: " + request.toString());
            }
        }
        return response;
    }

    public void setNextHandler(Handler handler) {
        this.nextHandler = handler;
    }

    protected abstract Level getHandlerLevel();

    protected abstract Response deal(Request request);

}
```
定义了一个请求的处理方法`handleMessage`  
`setNextHandler`是链的编排方法，设置下一个处理者  
`getHandlerLevel`和`deal`是具体的请求者必须实现的方法

核心文件
```
ResponsibilityChain/
|-- define
|   |-- Handler.java        // 抽象的处理者
|   |-- Level.java          // 任务等级定义
|   |-- Request.java        // 请求
|   `-- Response.java       // 回应，处理结果
|-- handler                 // 具体的处理者
|   |-- Level1Manager.java
|   |-- Level2Manager.java
|   `-- Level3Manager.java
`-- TestMain.java           // 测试代码
```

`define` 包内的 `Level`， `Request`， `Response` 类
```java
public class Level {

    private int intLevel;

    public Level(int levelInt) {
        this.intLevel = levelInt;
    }

    public int getIntLevel() {
        return intLevel;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (obj instanceof Level) {
            Level other = (Level) obj;
            return other.getIntLevel() == this.getIntLevel();
        }
        return false;
    }
}

public class Request {

    private String name;
    private Level requestLevel;

    public Request(Level level, String name) {
        this.requestLevel = level;
        this.name = name;
    }

    public Level getRequestLevel() {
        return this.requestLevel;
    }

    public String getName() {
        return name;
    }

    @Override
    public String toString() {
        return String.format(Locale.ENGLISH, "[%s, %d]", name, getRequestLevel().getIntLevel());
    }
}

public class Response {

    public static final String ERROR = "NO_RESPONSE";

    private String resStr = ERROR;

    public Response(String res) {
        this.resStr = res;
    }

    public String getResStr() {
        return resStr;
    }

    public void printRes() {
        System.out.println(resStr);
    }
}
```

具体的处理者类在`handler`包内  
```java
public class Level1Manager extends Handler {

    private Level level = new Level(1);

    @Override
    protected Level getHandlerLevel() {
        return level;
    }

    @Override
    protected Response deal(Request request) {
        return new Response(this.getClass().getSimpleName() + " handled this request");
    }

}

public class Level2Manager extends Handler {

    private Level level = new Level(2);

    @Override
    protected Level getHandlerLevel() {
        return this.level;
    }

    @Override
    protected Response deal(Request request) {
        return new Response(this.getClass().getSimpleName() + " handled " + request.toString());
    }
}

public class Level3Manager extends Handler {

    private Level level = new Level(3);

    @Override
    protected Level getHandlerLevel() {
        return this.level;
    }

    @Override
    protected Response deal(Request request) {
        return new Response(this.getClass().getSimpleName() + " handled " + request.toString());
    }
}
```

#### 测试代码  
先定义具体的处理者，并构建处理链  
定义不同的请求，处理者处理这些请求
```java
    Level1Manager level1Manager = new Level1Manager();
    Level2Manager level2Manager = new Level2Manager();
    Level3Manager level3Manager = new Level3Manager();

    level1Manager.setNextHandler(level2Manager);
    level2Manager.setNextHandler(level3Manager);

    Request request1 = new Request(new Level(1), "OA-1");
    Request request2 = new Request(new Level(2), "OA-2");
    Request request3 = new Request(new Level(3), "OA-3");
    level1Manager.handleMessage(request2).printRes();
    level2Manager.handleMessage(request1).printRes();
    level3Manager.handleMessage(request3).printRes();
```

输出
```
Level2Manager handled [OA-2, 2]
WARNING: no handler to: [OA-1, 1]
NO_RESPONSE
Level3Manager handled [OA-3, 3]
```

> 参考：《设计模式之禅》  秦小波
