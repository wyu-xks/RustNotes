---
title: Java Swing intro
date: 2015-05-17 16:11:01
category: Java_note
tag: [Java]
toc: true
---


如果有Android app开发经验，快速上手Swing不是问题。UI方面有相似的地方。  
简单的几行代码就能抛出一个框框，记录一下操作过程
#### 1.先显示一个框框
EraseBlockGame类是主类，包含了main入口，继承自 JFrame
```java
public class EraseBlockGame extends JFrame{
......
    public EraseBlockGame(String GameTitle){  // 构造方法
        super(GameTitle);
        setSize(408, 640);
        setLocationRelativeTo(null);// place in the center of screen
        ......
        setVisible(true);
    }
}
```
设置窗口大小，设置窗口在屏幕上的位置，窗口可见
```java
    public static void main(String args[]){
        EraseBlockGame e = new EraseBlockGame("Erase Block Game");
    }
```
运行一下程序，弹出一个窗口；窗口名称为Erase Block Game

#### 2.菜单栏
菜单栏有菜单按钮，以及菜单选项
```java
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
```
* JMenuBar 是整个菜单
* JMenu 是菜单栏上的单个按钮
* JMenuItem 点开单个餐单键，弹出的子选项item

```java
public class EraseBlockGame extends JFrame{
    private static final long serialVersionUID = 1L;
    private JMenuBar menuBar = new JMenuBar();
    private JMenu mGame = new JMenu("Game");
    private JMenuItem miNewGame = new JMenuItem("New game");
    private JMenuItem miExit = new JMenuItem("Exit");
    ......
}
```
如果多几个选项，总是new似乎不大好，用简单工厂来代替new  
定义JMenuFactory，里面有创建JMenu的方法
```java
package com.rust.util;

import javax.swing.JMenu;

public class JMenuFactory {
    JMenu menu;
    public JMenuFactory(){

    }
    public JMenu createMenu(String title){
        JMenu menu = new JMenu(title);
        return menu;
    }
}
```
同样定义JMenuItemFactory
```java
package com.rust.util;

import javax.swing.JMenuItem;

public class JMenuItemFactory {
    JMenuItem item;
    public JMenuItemFactory(){

    }
    public JMenuItem createMenuItem(String title){
        item = new JMenuItem(title);
        return item;
    }
}
```
原来的new就可以替换为
```java
    private JMenu mGame;
    private JMenu mControl;
    private JMenu mInfo;
    private JMenuItem miNewGame;
    private JMenuItem miExit;
    ......
        mGame = menuFactory.createMenu("Game");
        mControl = menuFactory.createMenu("Control");
        mInfo = menuFactory.createMenu("Info");
        miNewGame = miFactory.createMenuItem("New game");
        miExit = miFactory.createMenuItem("Exit");
```

在构造函数中给菜单item添加ActionListener，和Android app的Button差不多
```java
        miNewGame.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {

            }
        });
        miExit.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                System.exit(0);
            }
        });

        mGame.add(miNewGame);//这里添加的顺序就是排列的顺序
        mGame.add(miExit);//往menu中添加子项

        menuBar.add(mGame);
        menuBar.add(mControl);//这里添加的顺序就是排列的顺序

        setJMenuBar(menuBar);
```
如此看来，Swing活在了Android中

#### 3.放置按钮
此时界面上只有一些菜单按键，多摆几个按钮上去看看

定义一个控制面板类ControlBoard 继承自 JPanel
```java
/**
 * 控制面板，提供很多快捷的控制功能
 * @author Rust Fisher
 */
public class ControlBoard extends JPanel{
    private JButton btnStart;
    private JButton btnStop;
    private JButton btnPause;
    private JButton btnReset;
    private JButton btnExit;
    /*定义一个按钮区域areaButton，用来存放btn*/
    private JPanel areaButton = new JPanel(new GridLayout(5, 1));

    private EraseBlockGame game;
    /*按钮区域的框框*/
    private Border border = new EtchedBorder(EtchedBorder.RAISED, Color.WHITE,Color.gray);

    public ControlBoard(final EraseBlockGame game){
        setLayout(new GridLayout(3,1,0,1));
        this.game = game;//用于控制

        btnStart = new JButton("Start");
        btnStart.setEnabled(true);
        btnStop = new JButton("Stop");
        btnStop.setEnabled(false);
        btnPause = new JButton("Pause");
        btnPause.setEnabled(false);
        btnReset = new JButton("Reset");
        btnReset.setEnabled(true);
        btnExit = new JButton("Exit");
        btnExit.setEnabled(true);

        areaButton.add(btnStart);
        areaButton.add(btnPause);
        areaButton.add(btnStop);
        areaButton.add(btnReset);
        areaButton.add(btnExit);

        areaButton.setBorder(border);

        add(areaButton);// 把按钮区添加到控制面板上
        btnStart.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                // go go go

            }
        });
        btnExit.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                System.exit(0);//886
            }
        });
    }
......
}
```
在EraseBlockGame类里加载按钮区域
```java
public class EraseBlockGame extends JFrame{
......
    private ControlBoard controlBoard;

    public EraseBlockGame(String title){
        ......
        Container container = getContentPane();
        controlBoard = new ControlBoard(this);
        container.add(controlBoard, BorderLayout.EAST);//添加控制面板
        ......
    }
}

```
于是按钮就被装到程序上了

其他的就先不纠结了，Swing了解个大概就好；可以多看看android开发
