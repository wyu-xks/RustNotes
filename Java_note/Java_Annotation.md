---
title: Java 注解使用与简单说明
date: 2017-02-04 20:01:01
category: Java_note
toc: true
---

参考书籍： *Core Java, Volume II - Advanced Features 8th Edition*  

## 使用注解
注解是那些插入到源代码中用于某种工具处理的标签。这些标签可以在源码层次上进行操作。

注解的使用还是很广泛的，可能用法有：
* 附属文件的自动生成，例如部署描述符或者bean信息类
* 测试、日志、事物语义等代码的自动生成

在Java中，注解是当做一个修饰符来使用的，它被置于被注解项前，中间没有分号。

每个注解都必须通过一个注解接口来定义。这些接口中的方法与注解中的元素相对应。

### 使用实例：注解事件处理器
以GUI为例，设置按钮的点击监听事件。这个例子虽不完善，但简单说明了注解的用法。

文件如下：
```
annotationdemo/
├── ActionListenerFor.java
├── ActionListenerInstaller.java
└── ButtonTest.java
```

下面是所有文件的代码

`ButtonTest.java` 显示一个带有按钮的界面

```java
package annotationdemo;

import javax.swing.*;
import java.awt.*;

/**
 * For annotation test
 */
public class ButtonTest {
    public static void main(String[] args) {
        ButtonFrame btnFrame = new ButtonFrame();
        btnFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        btnFrame.setVisible(true);
    }

    static class ButtonFrame extends JFrame {
        private JPanel panel;
        private JButton yellowBtn;
        private JButton blueBtn;
        private JButton redBtn;

        public ButtonFrame() {
            setTitle("ButtonTest");
            setSize(300, 200);

            panel = new JPanel();
            add(panel);

            yellowBtn = new JButton("Yellow");
            blueBtn = new JButton("blue");
            redBtn = new JButton("red");

            panel.add(yellowBtn);
            panel.add(blueBtn);
            panel.add(redBtn);

            ActionListenerInstaller.processAnnotations(this);

        }

        @ActionListenerFor(source = "yellowBtn", level = 1)
        public void yellowBg() {
            panel.setBackground(Color.YELLOW);
        }

        @ActionListenerFor(level = 2, source = "blueBtn")
        public void blueBg() {
            panel.setBackground(Color.BLUE);
        }

        @ActionListenerFor(source = "redBtn")
        public void redBg() {
            panel.setBackground(Color.RED);
        }

    }

}

```

我们设计了一个注解来代替`addActionListener`  
上面的level有默认值0，不设置也可以。2个元素谁先谁后都没关系。

`ActionListenerInstaller` - 分析注解以及安装行为监听器的机制

```java
package annotationdemo;

import java.awt.event.ActionListener;
import java.lang.reflect.*;

/**
 * Install action listener
 */
public class ActionListenerInstaller {

    public static void processAnnotations(Object obj) {
        try {
            Class cl = obj.getClass();
            for (Method m : cl.getDeclaredMethods()) {
                ActionListenerFor a = m.getAnnotation(ActionListenerFor.class);
                if (null != a) {
                    Field f = cl.getDeclaredField(a.source());
                    f.setAccessible(true);
                    addListener(f.get(obj), obj, m);
                    a.level();// 可以获取定义的level
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void addListener(Object source, final Object param, final Method m) throws NoSuchMethodException,
            InvocationTargetException, IllegalAccessException {

        InvocationHandler handler = new InvocationHandler() {
            @Override
            public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                return m.invoke(param);
            }
        };

        Object listener = Proxy.newProxyInstance(null,
                new Class[]{java.awt.event.ActionListener.class},
                handler);
        Method adder = source.getClass().getMethod("addActionListener", ActionListener.class);
        adder.invoke(source, listener);

    }
}
```

`processAnnotations`方法枚举出某个对象接收到的所有方法。对于每一个方法，先获取`ActionListenerFor`
对象，然后再进行处理。


`ActionListenerFor.java` 定义我们想要的注解

```java
package annotationdemo;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface ActionListenerFor {
    String source();
    int level() default 0;
}
```

`Target`和`Retention`是元注解。它们注解了`ActionListenerFor`注解，即将`ActionListenerFor`
注解标识成一个只能运用到方法上的注解，并且当类文件载入到虚拟机时，仍可以保留下来。

## 注解语法
模仿前面的例子即可

一个注解是由一个注解接口来定义的：
```java
modifiers @interface AnnotaionName {
    element declaration1
    element declaration2
    ......
}
```
每个元素声明的形式 `type elementName();`  
或者 `type elementName() default value;`

注解的元素为下例之一：
* 一个基本类型（int short long byte char double float boolean）
* 一个String
* 一个Class（具有一个可供选择的类型参数，例如Class<? extends MyClass>）
* 一个enum类型
* 一个注解类型
* 一个由前面所描述类型组成的数组（数组组成的数组不是合法的元素类型）

因注解是由编译器计算而来，因此，所有元素必须是编译期常量
