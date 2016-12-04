---
title: Java容器类
date: 2015-04-28 22:11:39
category: Java_note
tag: [Java]
toc: true
---


* jdk1.7.0_79
* idea
* *Thinking in Java 4th edition*

### 泛型
 -----
Java有多种方式保存对象（对象的引用）。  
容器类：List    Set    Queue    Map  
容器的一些特性：Set对于每个值都只保存一个对象，Map允许将某些对象与其他一些对象关联起来。

ArrayList保存的是Object。在使用get()方法取出对象时，必须将其转型为保存的对象。
```java
import java.util.ArrayList;

/**
 * Created by Rust Fisher on 15-10-28.
 */
class Apple {
    private static long counter;
    private final long id = counter++;
    public long id() {return id;}
}
class Gala extends Apple{}
class RedFuShi extends Apple {}
class Orange {
    private static long counter;
    private final long id = counter++;
    /*复写toString方法*/
    @Override
    public String toString() {
        return "Orange{" +
                "id=" + id +
                '}';
    }
}

class Gerbil {
    private static int counter;
    private final int gerbilNumber = counter++;
    public void hop(){
        System.out.println(gerbilNumber + " is jumping");
    }
}

public class ApplesAndOrangeWithoutGenerics {
    public static void main(String args[]){
        ArrayList<Apple> apples = new ArrayList<Apple>();/*使用泛型来创建*/
        for (int i = 0;i < 3;i++){
            apples.add(new Apple());/*添加Apple*/
        }
        apples.add(new Gala());/*可以将Apple的子类添加到容器中*/
        apples.add(new RedFuShi());
        apples.add(new Gala());
        for (int i = 0;i < apples.size();i++){
            System.out.print((apples.get(i)).id() + "\t");
        }
        System.out.println();
        for (int i = 0; i < 2;i++) {
            System.out.print(new Orange() + " ");
        }
        System.out.println();
        for (Apple a : apples){
            System.out.print(a + ", ");
        }
        System.out.println();

        ArrayList<Gerbil> gerbils = new ArrayList<Gerbil>();
        for (int i = 0;i < 3;i++){
            gerbils.add(new Gerbil());
        }

        for (int i = 0;i < gerbils.size();i++){
            gerbils.get(i).hop();
        }
    }
}
```
输出：
```
0	1	2	3	4	5
Orange{id=0} Orange{id=1}
Apple@2b125a40, Apple@41e335d7, Apple@2be3d80c, Gala@7b7d1256, RedFuShi@503f0b70, Gala@6e1f5438,
0 is jumping
1 is jumping
2 is jumping
```

Apple@56c2c65b 程序输出是从Object默认的toString方法产生的，该方法打印类名，后面跟随该对象的散列码（由hashCode()方法产生）的无符号十六进制表示。

### 基本概念
 -----
两个不同的概念：
1.**Collection**
一个独立元素的序列，这些元素都服从一条或多条规则。List必须按照插入的顺序保持元素；Set不能有重复元素。Queue按照排队规则来确定对象产生的顺序。

2.**Map**
一组成对的“键值对”对象，允许你使用键来查找值。ArrayList允许你使用数字来查找值，因此某种意义上讲，
它将数字和对象关联在一起。映射表允许我们使用另一个对象来查找某个对象，也被称为“关联数组”；
或者被称为“字典”，因为可以使用键对象来查找值对象
```java
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;

public class SimpleCollection {
    public static void main(String args[]) {
        /* 用Integer对象填充了一个Collection */
        Collection<Integer> c = new HashSet<Integer>() {};
        Collection<Integer> a = new ArrayList<Integer>() {};
        for (int i = 0;i < 10;i++){
            c.add(i);/* Set不存放重复的值 */
            c.add(i);
            a.add(i);/* List不关心是否重复 */
            a.add(i);
        }
        for (Integer i : c){
            System.out.print(i + " ");
        }/* 所有的Collection都支持foreach语句 */
        System.out.println();
        for (Integer i : a){
            System.out.print(i + " ");
        }
    }
}
```
输出：
```
0 1 2 3 4 5 6 7 8 9
0 0 1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9
```
### 添加一组元素
 -----
可在Collection中添加一组元素。Collections.addAll()方法接受一个Collection对象。
Arrays.asList()方法接受一个数组或一个都好分隔的元素列表，并将其转换为一个List对象。
```java
import java.util.*;

public class AddingGroup {
    public static void main(String args[]) {
        Collection<Integer> collection =
                new ArrayList<>(Arrays.asList(1,2,3,4,5));
        Integer moreInts[] = {6,7,8,9,10};
        collection.addAll(Arrays.asList(moreInts));
        /* 添加元素collection */
        Collections.addAll(collection,20,30,40);
        /* 添加数组 */
        Collections.addAll(collection,moreInts);
        for (Integer i : collection){
            System.out.print(i + " ");
        }
        System.out.println();
        List<Integer> list = Arrays.asList(31,32,33,34);
        for (Integer i : list) System.out.print(i + " ");
        list.set(1,99);/* 修改值 */
        System.out.println();
        for (Integer i : list) System.out.print(i + " ");
    }
}
```
输出：
```
1 2 3 4 5 6 7 8 9 10 20 30 40 6 7 8 9 10
31 32 33 34
31 99 33 34
```
### 容器的打印
 -----
必须使用Arrays.toString()来产生数组的可打印表示
不复写toString()也可以得到可读性好的打印结果；Map与Collection打印风格不同   
以下为打印示例：
```java
import java.util.*;

/**
 * 生成名字的类
 */
class GenerateMovieName {
    int key = 0;
    public String next() {
        switch (key){
            case 0:
                key++;
                return "ONE";
            case 1:
                key++;
                return "We were solders";
            case 2:
                key++;
                return "Big";
            case 3:
                key++;
                return "Wind speaker";
            case 4:
                key++;
                return "La";
            default:
            case 5:
                key = 0;
                return "New";
        }
    }
    /* 用于填充数组 */
    public void loadNames(String names[]){
        for (int i = 0;i < names.length;i++){
            names[i] = next();
        }
    }
    /* 用于填充容器 */
    public Collection fill(Collection<String> c, int n){
        for (int i = 0;i < n;i++){
            c.add(next());
        }
        return c;
    }

}

public class PrintingContainers {
    static Collection fill(Collection<String> collection){
        collection.add("rat");
        collection.add("cat");
        collection.add("dog");
        collection.add("dog");
        collection.add("house");
        return collection;
    }
    static Map fill(Map<String, String> map){
        map.put("rat", "Jerry");
        map.put("cat", "Tom");
        map.put("dog", "Hou");
        map.put("dog", "Spot");
        map.put("house", "Home");
        return map;
    }

    public static void main(String args[]){
        System.out.println("ArrayList " + fill(new ArrayList<String>()));
        System.out.println("LinkedList " + fill(new LinkedList<String>()));
        System.out.println("HashSet " + fill(new HashSet<String>()));
        System.out.println("TreeSet " + fill(new TreeSet<String>()));
        System.out.println("TreeMap " + fill(new TreeMap<String, String>()));
        System.out.println("HashMap " + fill(new HashMap<String, String>()));
        System.out.println("LinkedHashMap " + fill(new LinkedHashMap<String, String>()));
        System.out.println();
        GenerateMovieName gener = new GenerateMovieName();
        String names[] = new String[10];
        gener.loadNames(names);
        System.out.println(gener.fill(new ArrayList<String>(), 8));
        System.out.println(gener.fill(new LinkedList<String>(), 8));
        System.out.println(gener.fill(new HashSet<String>(), 8));
        System.out.println(gener.fill(new TreeSet<String>(), 8));
        for (int i = 0;i < names.length;i++) System.out.print(names[i] + ", ");
    }
}
```
输出：
```
ArrayList [rat, cat, dog, dog, house]
LinkedList [rat, cat, dog, dog, house]
HashSet [cat, house, dog, rat]
TreeSet [cat, dog, house, rat]
TreeMap {cat=Tom, dog=Spot, house=Home, rat=Jerry}
HashMap {cat=Tom, house=Home, dog=Spot, rat=Jerry}
LinkedHashMap {rat=Jerry, cat=Tom, dog=Spot, house=Home}

[La, New, ONE, We were solders, Big, Wind speaker, La, New]
[ONE, We were solders, Big, Wind speaker, La, New, ONE, We were solders]
[Wind speaker, We were solders, ONE, Big, New, La]
[Big, La, New, ONE, We were solders, Wind speaker]
ONE, We were solders, Big, Wind speaker, La, New, ONE, We were solders, Big, Wind speaker,
```
HashMap提供了最快的查找技术

### List
两种类型的List：
* 基本的ArrayList，在List中间插入和移除元素较慢
* LinkedList，随机访问较慢

### 迭代器
 -----
迭代器，遍历并选择序列中的对象。
迭代器创建的代价小，常被称为轻量级对象。
```java
import java.util.*;

public class SimpleIteration {
    /**
     * 使用iterator来遍历序列
     * @param it
     */
    public static void display(Iterator<Integer> it) {
        while (it.hasNext()){
            Integer i = it.next();
            System.out.print(i + " ");
        }
        System.out.println();
    }
    public static void main(String args[]) {
        List<Integer> numbers = new ArrayList<Integer>();
        Collections.addAll(numbers,1,2,3,4,5,6,7,8,9,10);
        Iterator<Integer> it = numbers.iterator();/* 定义iterator */
        while (it.hasNext()){
            Integer i = it.next();
            System.out.print(i + " ");
        }//输出：1 2 3 4 5 6 7 8 9 10
        System.out.println();
        for (Integer i : numbers){
            System.out.print(i + " ");
        }//输出：1 2 3 4 5 6 7 8 9 10
        it = numbers.iterator();/* 重置一下 */
        for (int i = 0;i < 4;i++){
            it.next();
            it.remove();/* iterator也可操作元素 */
        }
        System.out.println();
        System.out.println("numbers:" + numbers);
        //输出：numbers:[5, 6, 7, 8, 9, 10]
        display(numbers.iterator());/* 直接输入Iterator */
        //输出：5 6 7 8 9 10
    }
}
```
方法display()不包含任何关于它所遍历的序列的类型信息，**将遍历序列的操作与序列底层的结构分离**。

### ListIterator
 -----
ListIterator是一个更加强大的Iterator的子类，只能用于各种List类的访问。可双向移动。  
hasPrevious()查看前面还有没有元素；  
previous()取得当前的元素
```java
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.ListIterator;

public class ListIteration {

    public static void main(String args[]) {
        List<String> str = new ArrayList<String>();
        Collections.addAll(str,"ab","cd","ef","gh","xyz");
        ListIterator lit = str.listIterator();
        while (lit.hasNext()){
            System.out.print(lit.next() + ", " + lit.nextIndex()
                    + ", " + lit.previousIndex());
            System.out.println();
        }
        while (lit.hasPrevious()){
            System.out.print(lit.previous() + " ");/* 倒着打印 */
        }
        System.out.println();
        System.out.println(str);
        lit = str.listIterator(3);/* 从指定下标开始 */
        while (lit.hasNext()){
            lit.next();
            lit.set("SET");/* 替换元素 */
        }
        System.out.println(str);
        /*********************************************************/
        /**
         * 把num1倒着接到num2后面
         */
        List<Integer> num1 = new ArrayList<>();
        List<Integer> num2 = new ArrayList<>();
        Collections.addAll(num1,1,2,3,4,5);/* 初始化 */
        Collections.addAll(num2,6,7,8,9,10);
        ListIterator it = num1.listIterator();
        it = num1.listIterator(num1.size());/* 把it移到num1的末尾 */
        while (it.hasPrevious()){
            num2.add(num1.get(it.previousIndex()));
            it.previous();
        }
        System.out.println(num2);
    }
}
```
输出：
```
ab, 1, 0
cd, 2, 1
ef, 3, 2
gh, 4, 3
xyz, 5, 4
xyz gh ef cd ab
[ab, cd, ef, gh, xyz]
[ab, cd, ef, SET, SET]
[6, 7, 8, 9, 10, 5, 4, 3, 2, 1]
```
### LinkedList
 -----
可以成为一个Queue实现。

Java代码：
```java
import java.util.*;

/**
 * 熟悉LinkedList的特性
 */
public class LinkedListFeatures {
    public static void main(String args[]){
        /*********************************************************************/
        /*
        * 熟悉一下操作
        */
        LinkedList<Integer> numbers = new LinkedList<Integer>();
        Collections.addAll(numbers,0,1,2,3,4,5,6,7,8,9,10);
        System.out.println("numbers: " + numbers);
        System.out.println("numbers.getFirst(): " + numbers.getFirst());/* 返回头部 */
        System.out.println("numbers.element(): " + numbers.element());/* 返回头部 */
        System.out.println("numbers.peek(): " + numbers.peek());
        System.out.println("numbers.remove(): " + numbers.remove());
        System.out.println("numbers.removeFirst(): " + numbers.removeFirst());
        System.out.println("numbers.poll(): " + numbers.poll());
        System.out.println("numbers: " + numbers);
        numbers.addFirst(0);
        System.out.println("numbers after addFirst(0): " + numbers);
        numbers.offer(1);
        System.out.println("numbers after offer(1): " + numbers);
        numbers.addLast(99);
        System.out.println("numbers after addLast(99): " + numbers);
        System.out.println("numbers.removeLast() : " + numbers.removeLast());
        /*********************************************************************/
        /*
        * 在LinkedList中插入对象
        */
        LinkedList<Integer> em =
                new LinkedList<>(Arrays.asList(10,20,30,40,50,60,70,80,90,100));
        System.out.println("/**********************************************/");
        System.out.println("new LinkedList: " + em);
        ListIterator it = em.listIterator();
        System.out.println("it.previousIndex() == " + it.previousIndex());
        it = em.listIterator(7);/* 根据下标来设定it */
        System.out.println(it.previousIndex() + " -- " + it.previous());
        it.add(77);/* 插入一个Integer */
        System.out.println("After insert LinkedList: " + em);
        System.out.println("em.get(0) == " + em.get(0));
    }
}
```

输出结果：
```
numbers: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
numbers.getFirst(): 0
numbers.element(): 0
numbers.peek(): 0
numbers.remove(): 0
numbers.removeFirst(): 1
numbers.poll(): 2
numbers: [3, 4, 5, 6, 7, 8, 9, 10]
numbers after addFirst(0): [0, 3, 4, 5, 6, 7, 8, 9, 10]
numbers after offer(1): [0, 3, 4, 5, 6, 7, 8, 9, 10, 1]
numbers after addLast(99): [0, 3, 4, 5, 6, 7, 8, 9, 10, 1, 99]
numbers.removeLast() : 99
/**********************************************/
new LinkedList: [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
it.previousIndex() == -1
6 -- 70
After insert LinkedList: [10, 20, 30, 40, 50, 60, 77, 70, 80, 90, 100]
em.get(0) == 10
```

### Stack
 -----
栈，LIFO
LinkedList具有能够直接实现栈的所有功能的方法，可直接当做栈来使用；
用LinkedList实现一个栈，存放在另一个目录下：
```java
package com.rust.util;

import java.util.LinkedList;

public class Stack<T> {
    private LinkedList<T> storage = new LinkedList<T>();
    public void push(T v) {storage.addFirst(v);}
    public T peek() {return storage.getFirst();}
    public T pop() {return storage.removeFirst();}
    public boolean empty() {return storage.isEmpty();}
    public String toString() {return storage.toString();}
}
```
测试一下这个类，引入包名，不要与java.util的冲突
```java
import com.rust.util.Stack;

public class StackTest {
    public static void main(String args[]) {
        Stack<String> stack = new Stack<String>();
        for (String s : "Don't worry , be happy".split(" ")) {
            stack.push(s);
        }
        while (!stack.empty()) {
            System.out.print(stack.pop() + " ");
        }
        System.out.println();
        /****************************************************/
        Stack<String> wordStack = new Stack<String>();
        String expretion =
                "+U+n+c---+e+r+t---+a-+i-+n+t+y---+-+r+u--+l+e+s---";/* 解析这段字符 */
        for (int i = 0; i < expretion.length(); i++) {
            if (expretion.charAt(i) == '+') {
                wordStack.push(expretion.charAt(i + 1) + "");
            } else if (expretion.charAt(i) == '-'){
                System.out.print(wordStack.pop() + "");
            }
        }
    }
}
```
输出：
```
happy be , worry Don't
cnUtreaiytn-ursel
```

### Set
 -----
不保存重复的元素。常用于测试归属性，很容易地询问某个对象是否存在与某个Set中。
实际上Set就是Collection，只是行为不同。
HashSet使用了散列。TreeSet将元素存储在红黑树数据结构中。
使用contains()测试Set的归属性
```java
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

/**
 * 操作HashSet
 */
public class SetOperations {
    public static void main(String args[]){
        Set<String> set1 = new HashSet<>();/* HashSet 的用法 */
        Collections.addAll(set1,"A B C D E F G H I J K".split(" "));
        set1.add("M");
        System.out.println("H: " + set1.contains("H"));
        System.out.println("M: " + set1.contains("M"));
        Set<String> set2 = new HashSet<>();
        Collections.addAll(set2,"H I J K".split(" "));
        System.out.println("set2 in set1 ? " + set1.containsAll(set2));
        set1.remove("H");
        System.out.println("After remove set1: " + set1);
        System.out.println("set2 in set1 ? " + set1.containsAll(set2));
        set1.removeAll(set2);
        System.out.println("Remove set2 from set1: " + set1);
        Collections.addAll(set1,"X Y Z".split(" "));
        System.out.println("X Y Z added to set1 : " + set1);
    }
}
```
输出：
```
H: true
M: true
set2 in set1 ? true
After remove set1: [D, E, F, G, A, B, C, M, I, J, K]
set2 in set1 ? false
Remove set2 from set1: [D, E, F, G, A, B, C, M]
X Y Z added to set1 : [D, E, F, G, A, B, C, M, Y, X, Z]
```

### Map
 -----
能将对象映射到其他对象。  
一个程序，检查Java的Random类的随机性。
```java
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

public class Statistics {
    public static void main(String args[]) {
        Random rand = new Random(47);
        Map<Integer, Integer> m =
                new HashMap<Integer, Integer>();
        for (int i = 0; i < 10000; i++) {
            int r = rand.nextInt(20);
            Integer freq = m.get(r);
            m.put(r, freq == null ? 1 : freq + 1);
        }
        for (int i = 0; i < 10; i++)
            System.out.print(i + "=" + m.get(i) + "; ");
        System.out.println();
        for (int i = 10; i < m.size(); i++)
            System.out.print(i + "=" + m.get(i) + "; ");
    }
}
```
如果键不在容器中，get()方法将返回null（这表示第一次找）。

Map与数组和其他的Collection一样，可以很容易地扩展到多维，而我们只需将其值设置为Map。
因此，我们能够很容易地将容器组合起来从而快速地生成强大的数据结构。

### Queue
 -----
FIFO。队列常被当做一种可靠的将对象从程序的某个区域传输到另一个区域的途径。
队列在并发编程中特别重要。它们可以安全地将对象从一个任务传送到另一个任务。
LinkedList可以用作Queue的一种实现。通过将LinkedList向上转型为Queue
```java
import java.util.LinkedList;
import java.util.Queue;
import java.util.Random;

public class QueueDemo {
    public static void printQ(Queue queue){
        while (queue.peek() != null){
            System.out.print(queue.remove() + " ");
        }
        System.out.println();
    }
    public static void main(String args[]){
        Queue<Integer> queue = new LinkedList<>();
        Random rand = new Random(47);
        for (int i = 0; i < 10; i++){
            queue.offer(rand.nextInt(i + 10));
        }
        printQ(queue);
        Queue<Character> qc = new LinkedList<>();
        for (char c : "Berrytail".toCharArray()){
            qc.offer(c);
        }
        printQ(qc);
    }
}
```
输出：
```
8 1 1 1 5 14 3 1 0 1
B e r r y t a i l
```
offer()方法是与Queue相关的方法之一，它在允许的情况下，将一个元素插入到队尾，或者返回false。
peek()和element()方法都将在不移除的情况下返回队头。peek方法在队列为空时返回null，element方法会抛出NoSuchElementExceptio异常。
poll()和remove()方法将移除并返回队头，但是poll方法在队列为空时返回null，remove则抛出异常

#### PriorityQueue
优先级队列声明下一个弹出元素是最需要的元素（具有最高优先级）。
当在PriorityQueue上调用offer()方法来插入一个对象时，这个对象会在队列中被排序。
默认的排序将使用对象在队列中的自然顺序，可提供Comparator来修改这个顺序。
PriorityQueue可以确保你在调用peek()、 poll()和 remove()方法时，获取的元素是队列中优先级最高的元素。
PriorityQueue与Integer和String这样的内置类型一起工作，示例：
```java
import java.util.*;

public class PriorityQueueDemo {
    public static void main(String args[]) {
        PriorityQueue<Integer> priorityQueue =
                new PriorityQueue<>();
        Random rand = new Random(47);
        for (int i = 0; i < 10; i++) {
            priorityQueue.offer(rand.nextInt(i + 10));
        }/* 使用前一个类里面的打印方法 */
        QueueDemo.printQ(priorityQueue);/* 随机数打出来已被排好序 */
        List<Integer> ints = Arrays.asList(22,33,21,1,5,7,33,61,43);
        priorityQueue = new PriorityQueue<>(ints);
        QueueDemo.printQ(priorityQueue);/* 打出来的数字都被排好序了 */
        priorityQueue = new PriorityQueue<>(ints.size(), Collections.reverseOrder());/* 倒序 */
        priorityQueue.addAll(ints);
        QueueDemo.printQ(priorityQueue);/* 输出已是倒序，从大到小 */

        String fact = "EDUCATION SHOULD ESCHEW";
        List<String> str = Arrays.asList(fact.split(""));/* 切开 */
        PriorityQueue<String> strPQ = new PriorityQueue<>(str);
        QueueDemo.printQ(strPQ);/* 打印出单个字符，包括空格 */
        strPQ = new PriorityQueue<>(str.size(), Collections.reverseOrder());/* 设置倒序 */
        strPQ.addAll(str);
        QueueDemo.printQ(strPQ);
    }
}
```
输出：
```
0 1 1 1 1 1 3 5 8 14
1 5 7 21 22 33 33 43 61
61 43 33 33 22 21 7 5 1
     A C C D D E E E H H I L N O O S S T U U W
W U U T S S O O N L I H H E E E D D C C A      
```
可以看到，默认顺序，空格排在字母的前面；顺序可以通过参数设定；重复是允许的；

### 优先级队列
 ------
to-do列表，该列表中每个对象都包含一个字符串，一个主要优先级，一个次要优先级值。
该列表的排序顺序也是通过实现Comparable而进行控制的
```java
package com.rust.containers;

import java.util.PriorityQueue;

public class ToDoList extends PriorityQueue<ToDoList.ToDoItem> {
    static class ToDoItem implements Comparable<ToDoItem> {
        private char primary;   /* 排序的首要调条件 */
        private int secondary;  /* 次要条件 */
        private String item;    /* 项目名称 */

        public ToDoItem(String td, char pri, int sec) {
            primary = pri;
            secondary = sec;
            item = td;
        }

        /**
         * 比较方法，根据条件来比较
         * @param arg
         * @return
         */
        public int compareTo(ToDoItem arg) {
            if (primary > arg.primary)
                return +1;
            if (primary == arg.primary) {
                if (secondary > arg.secondary) {
                    return +1;
                } else if (secondary == arg.secondary) {
                    return 0;
                }
            }
            return -1;
        }

        public String toString() {
            return Character.toString(primary) +
                    secondary + ": " + item;
        }
    }

    /**
     * 输入3个参数
     * @param td - 项目名称
     * @param pri - 首要条件
     * @param sec - 次要条件
     */
    public void add(String td, char pri, int sec) {
        super.add(new ToDoItem(td, pri, sec));
    }

    public static void main(String args[]) {
        ToDoList toDoList = new ToDoList();
        toDoList.add("扔垃圾", 'C', 4);
        toDoList.add("喂狗", 'A', 2);
        toDoList.add("喝水", 'B', 1);
        toDoList.add("浇花", 'A', 3);
        toDoList.add("扫地", 'C', 6);
        toDoList.add("刷牙", 'B', 5);
        while (!toDoList.isEmpty()){
            System.out.println(toDoList.remove());
        }
    }
}
```
输出：
```
A2: 喂狗
A3: 浇花
B1: 喝水
B5: 刷牙
C4: 扔垃圾
C6: 扫地
```

练习题：创建一个类，包含一个Integer，新建类时随机产生一个数；将其多个对象传入PriorityQueue中，再输出观察
```java
package com.rust.containers;

import java.util.PriorityQueue;
import java.util.Random;

/***********************************
 * Exercise 11
 * Create a class that contains an Integer that is
 * initialized to a value between 0 and 100 using
 * java.util.Random. Implement Comparable using this
 * Integer field. Fill a PriorityQueue with objects of
 * your class, and extract the values using poll() to
 * show that it produces the expected order.
 ***********************************************/
class Item implements Comparable<Item> {
    private static final Random rnd = new Random(47);
    private Integer priority = rnd.nextInt(101);

    @Override
    public int compareTo(Item o) {
        return priority < o.priority ? -1 :
                priority == o.priority ? 0 : 1;
    }

    @Override
    public String toString() {
        return "Item{" +
                "priority=" + priority +
                '}';
    }
}

public class E11_PriorityQueue {
    public static void main(String args[]) {
        PriorityQueue<Item> queue = new PriorityQueue<>();
        for (int i = 0; i < 10; i++) {
            queue.add(new Item());
        }
        Item item;
        while ((item = queue.poll()) != null) {
            System.out.println(item);
        }
    }
}
```
输出：
```
Item{priority=15}
Item{priority=17}
Item{priority=18}
Item{priority=20}
Item{priority=22}
Item{priority=62}
Item{priority=65}
Item{priority=67}
Item{priority=95}
Item{priority=100}
```

### 双向队列
 ------
可以在任何一端添加或移除元素。在LinkedList中包含支持双向队列的方法，使用组合来创建一个Deque类，并直接从LinkedList中暴露相关的方法。
```java
package com.rust.util;

import java.util.LinkedList;

public class Deque<T> {
    private LinkedList<T> deque = new LinkedList<T>();

    public void addFirst(T e) {
        deque.addFirst(e);
    }

    public void addLast(T e) {
        deque.addLast(e);
    }

    public T getFirst() {
        return deque.getFirst();
    }

    public T getLast() {
        return deque.getLast();
    }

    public T removeFirst() {
        return deque.removeFirst();
    }

    public T removeLast() {
        return deque.removeLast();
    }

    public int size() {
        return deque.size();
    }

    public String toString() {
        return deque.toString();
    }
}
```
```java
package com.rust.containers;

import com.rust.util.Deque;

public class DequeTest {
    static void fillTest(Deque<Integer> deque) {
        for (int i = 20; i < 27; i++) {
            deque.addFirst(i);
        }

        for (int i = 50; i < 57; i++) {
            deque.addLast(i);
        }

    }

    public static void main(String args[]) {
        Deque<Integer> deque = new Deque<>();
        fillTest(deque);
        System.out.println(deque);
        while (deque.size() != 0) {
            System.out.print(deque.removeFirst() + " ");/* 从头开始 */
        }
        fillTest(deque);
        System.out.println();
        while (deque.size() != 0) {
            System.out.print(deque.removeLast() + " ");/* 从尾开始 */
        }

    }
}
```
输出：
```
[26, 25, 24, 23, 22, 21, 20, 50, 51, 52, 53, 54, 55, 56]
26 25 24 23 22 21 20 50 51 52 53 54 55 56
56 55 54 53 52 51 50 20 21 22 23 24 25 26
```

### Collection和Iterator
 -----
使用接口描述，能创建更通用的代码。针对接口而非具体实现来编码，可以应用与更多的对象类型。
```java
import java.util.*;

public class InterfaceVsIterator {
    /**
     * 这种方法耦合度更低
     * @param it - Iterator
     */
    public static void display(Iterator<Integer> it) {
        while (it.hasNext()) {
            Integer i = it.next();
            System.out.print(i + " ");
        }
        System.out.println();
    }

    public static void display(Collection<Integer> nums) {
        for (Integer n : nums) {
            System.out.print(n + " ");
        }
        System.out.println();
    }

    public static void main(String args[]) {
        List<Integer> numsList = new ArrayList<>();
        Collections.addAll(numsList, 1, 2, 3, 4, 5, 6, 7);
        Set<Integer> numsSet = new HashSet<>();
        Collections.addAll(numsSet, 1, 2, 3, 4, 5, 6, 7);
        Map<String, Integer> numsMap =
                new LinkedHashMap<>();
        String names[] = ("Ralph Eric David Lucy Sam").split(" ");
        for (int i = 0; i < names.length; i++) {
            numsMap.put(names[i], numsList.get(i));
        }
        display(numsList);/* 打印值 */
        display(numsSet);
        display(numsSet.iterator());
        display(numsList.iterator());
        System.out.println(numsMap);
        System.out.println(numsMap.keySet());/* 输出key */
        display(numsMap.values());/* 输出值 */
        display(numsMap.values().iterator());
    }
}
```
输出：
```
1 2 3 4 5 6 7
1 2 3 4 5 6 7
1 2 3 4 5 6 7
1 2 3 4 5 6 7
{Ralph=1, Eric=2, David=3, Lucy=4, Sam=5}
[Ralph, Eric, David, Lucy, Sam]
1 2 3 4 5
1 2 3 4 5
```

### Foreach与迭代器
----
foreach语法可应用与任何Collection对象  
iterable的接口，包含一个能够产生Iterator的iterator()方法，并且Iterable接口被foreach用来在序列中移动
```java
import java.util.Iterator;
import java.util.Map;

public class IterableClass implements Iterable<String> {
    protected String words[] = ("And this is how we know").split(" ");
    @Override
    public Iterator<String> iterator() {
        return new Iterator<String>() {
            private int index = 0;
            @Override
            public boolean hasNext() {/* 先判断还有没有后续的 */
                return index < words.length;
            }

            @Override
            public String next() {/* 然后返回值 */
                return words[index++];
            }

            @Override
            public void remove() {

            }
        };
    }
    public static void main(String args[]){
        for (String s : new IterableClass()){
            System.out.print(s + " ");
        }

        /* 打印出系统的环境信息 */
        for (Map.Entry entry : System.getenv().entrySet()){
            System.out.println(entry.getKey() + ": " + entry.getValue());
        }
        /* System.getenv()返回一个Map，entrySet()产生一个由Map.Entry的元素构成的Set */
        /* 并且这个Set是一个Iterable，可用于foreach循环 */
    }
}
```
部分输出：
```
And this is how we know
```

### 适配器方法惯用法
-----
假如要向前或者向后迭代一个单词列表。使用适配器方法。在默认的前向迭代器基础上，添加产生反响迭代器的能力。添加一个能够产生Iterable对象的方法，该对象可以用于foreach语句。
```java
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Iterator;

class ReversibleArrayList<T> extends ArrayList<T> {
    public ReversibleArrayList(Collection<T> c) {
        super(c);
    }

    public Iterable<T> reversed() {
        return new Iterable<T>() {
            @Override
            public Iterator<T> iterator() {
                return new Iterator<T>() {
                    int current = size() - 1;/* 从尾开始 */

                    @Override
                    public boolean hasNext() {
                        return current > -1;/* 是否到头？ */
                    }

                    @Override
                    public T next() {
                        return get(current--);/* 向前取值 */
                    }

                    @Override
                    public void remove() {
                    }
                };
            }
        };
    }
}

public class AdapterMethodIdiom {
    public static void main(String args[]) {
        ReversibleArrayList<String> ral =
                new ReversibleArrayList<String>(
                        Arrays.asList(("That is how we do it").split(" "))
                );
        for (String s : ral){/* 顺序输出 */
            System.out.print(s + " ");
        }
        System.out.println();
        for (String s : ral.reversed()){/* 倒序输出 */
            System.out.print(s + " ");
        }
    }
}
```
输出：
```
That is how we do it
it do we how is That
```
在前文的IterableClass.java示例中添加两种适配器方法，写一个类继承IterableClass
新增方法reversed() 和 randomized()
再研究一下Collection.shuffle()对原数组顺序的影响
```java
import java.util.*;

public class MultiIterableClass extends IterableClass {
    /**
     * 新增方法，倒序输出
     * @return Iterable
     */
    public Iterable<String> reversed() {
        return new Iterable<String>() {
            @Override
            public Iterator<String> iterator() {
                return new Iterator<String>() {
                    int current = words.length - 1;
                    @Override
                    public boolean hasNext() {
                        return current > -1;
                    }

                    @Override
                    public String next() {
                        return words[current--];
                    }

                    @Override
                    public void remove() {

                    }
                };
            }
        };
    }

    /**
     * 新增方法，乱序输出
     * @return Iterable
     */
    public Iterable<String> randomized(){
        return new Iterable<String>() {/* 返回被打乱的List中的Iterator */
            @Override
            public Iterator<String> iterator() {
                List<String> shuffled =
                        new ArrayList<>(Arrays.asList(words));
                Collections.shuffle(shuffled,new Random(47));
                return shuffled.iterator();
            }
        };
    }

    public static void main(String args[]){
        MultiIterableClass mic = new MultiIterableClass();
        for (String s : mic.reversed()){
            System.out.print(s + " ");/* 倒序输出 */
        }
        System.out.println();
        for (String s : mic){
            System.out.print(s + " ");/* 顺序（默认）输出*/
        }
        System.out.println();
        for (String s : mic.randomized()){
            System.out.print(s + " ");/* 乱序（随机）输出*/
        }
        System.out.println();
        /* Collection.shuffle()方法没有影响到原来的数组，只是打乱了shuffled中的引用 */
        Random rand = new Random(47);
        Integer ia[] = {1,2,3,4,5,6,7,8,9,10};
        List<Integer> list1 = new ArrayList<>(Arrays.asList(ia));/* 构造了一个新的ArrayList<> */
        System.out.println("list1 before shuffling: " + list1);
        Collections.shuffle(list1,rand);
        System.out.println("list1 after shuffling: " + list1);
        System.out.println("ia array: " + Arrays.toString(ia));/* ia的顺序没有改变 */

        List<Integer> list2 = Arrays.asList(ia);/* 直接使用Arrays.asList(ia)的结果 */
        System.out.println("list2 before shuffling: " + list2);
        Collections.shuffle(list2,rand);
        System.out.println("list2 after shuffling: " + list2);
        System.out.println("ia array: " + Arrays.toString(ia));/* 打乱原来ia的顺序 */
    }
}
```
输出:  
```
know we how is this And
And this is how we know
this we how know And is
list1 before shuffling: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
list1 after shuffling: [4, 6, 3, 1, 8, 7, 2, 5, 10, 9]
ia array: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
list2 before shuffling: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
list2 after shuffling: [9, 1, 6, 3, 7, 2, 5, 10, 4, 8]
ia array: [9, 1, 6, 3, 7, 2, 5, 10, 4, 8]
```

### 小结
-----
Java提供了大量的持有对象的方式

1. 数组将数字与对象联系起来。但数组一旦生成，容量不能改变。
2. Collection保存单一的元素，而Map保存相关联的键值对。
3. List也建立了数字与对象的关联，能够自动扩充容量。
4. 若要进行大量的随机访问，使用ArrayList；经常插入或删除元素，使用LinkedList。
5. 各种Queue与栈的行为，由LinkedList提供支持。


### 填充容器
 -----
 fill()方法，复制同一个对象引用来填充整个容器，只对List对象有用。
 只能替换List中存在的元素，不能添加新的元素。
 ```java
 package com.rust.containers;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

class StringAddress {
    private String s;

    public StringAddress(String s) {
        this.s = s;
    }

    public String toString() {
        return /*super.toString() + " " + */s;/* 对象的散列码就不输出了 */
    }
}

public class FillingLists {
    public static void main(String args[]) {
        List<StringAddress> list = new ArrayList<StringAddress>(
                Collections.nCopies(3, new StringAddress("Hello"))
        );/* 填充list */
        System.out.println(list);
        Collections.fill(list, new StringAddress("World"));/* 填充，替换掉原有的元素 */
        System.out.println(list);/* 填充后，所有引用都被设置为指向相同的对象 */
    }
}
```
输出：
```
[Hello, Hello, Hello]
[World, World, World]
```

### Collection的功能方法
示例代码：
```java
package com.rust.containers;

import java.util.*;

public class CollectionMethods {
    public static void main(String args[]) {
        Collection<String> c = new ArrayList<String>();
        Collections.addAll(c, ("ONE TWO THREE FOUR FIVE")
                .toLowerCase().split(" "));
        c.add("ten");
        c.add("zero");
        System.out.println("c = " + c);
        /* 根据ASCII码来找大小值 */
        System.out.println("Collections.max(c) = " + Collections.max(c));
        System.out.println("Collections.min(c) = " + Collections.min(c));
        Collection<String> c2 = new ArrayList<String>();
        c2.addAll(Arrays.asList(("morning noon night").split(" ")));
        c.addAll(c2);/* 把c2添加到c里面去 */
        System.out.println("c = " + c);
        c.remove("one");
        c.remove("zero");/* 删掉两个元素 */
        System.out.println("c = " + c);
        String val = "ten";
        System.out.println("c.contains(" + val + ") ? " + c.contains(val));
        c.removeAll(c2);/* 从c中把c2全部删掉 */
        System.out.println("c2 = " + c2);
        Collection<String> c3 = ((List<String>) c).subList(2, 4);
        c2.retainAll(c3);/* c2中仅保存c2和c3共同存在的元素 */
        System.out.println("c3 = " + c3);
        System.out.println("c2.isEmpty() ? " + c2.isEmpty());
    }
}
```
输出
```
c = [one, two, three, four, five, ten, zero]
Collections.max(c) = zero
Collections.min(c) = five
c = [one, two, three, four, five, ten, zero, morning, noon, night]
c = [two, three, four, five, ten, morning, noon, night]
c.contains(ten) ? true
c2 = [morning, noon, night]
c3 = [four, five]
c2.isEmpty() ? true
```

### Set和存储顺序
Set不保存重复元素。HashSet速度快。
为了使用特定的Set实现类型而必须定义方法

```java
package com.rust.containers;

import java.util.Collections;
import java.util.Iterator;
import java.util.SortedSet;
import java.util.TreeSet;

public class SortedSetDemo {
    public static void main(String args[]) {
        SortedSet<String> sortedSet = new TreeSet<>();
        Collections.addAll(sortedSet,
                ("one two three four five six seven eight nine").split(" "));
        System.out.println("/* SortedSet的意思是“按对象的比较函数对元素排序”，\n" +
                " * 而不是指“元素插入的次序”；插入顺序可以用LinkedHashSet来保存*/");
        System.out.println(sortedSet);
        String low = sortedSet.first();
        String high = sortedSet.last();
        System.out.println("low : " + low);
        System.out.println("high : " + high);
        Iterator<String> it = sortedSet.iterator();
        for (int i = 0; i <= 6; i++) {
            if (i == 3) low = it.next();
            if (i == 6) high = it.next();
            else it.next();
        }
        System.out.println("after low : " + low);
        System.out.println("after high : " + high);
        System.out.println("sortedSet.subSet(low,high) = " + sortedSet.subSet(low, high));
        /* 跟在low后面的元素，包括low*/
        System.out.println("tailSet(low)  = " + sortedSet.tailSet(low));
        /* high之前的元素，不包括high*/
        System.out.println("headSet(high) = " + sortedSet.headSet(high));
    }
}
```
输出：
```
/* SortedSet的意思是“按对象的比较函数对元素排序”，
 * 而不是指“元素插入的次序”；插入顺序可以用LinkedHashSet来保存*/
[eight, five, four, nine, one, seven, six, three, two]
low : eight
high : two
after low : nine
after high : three
sortedSet.subSet(low,high) = [nine, one, seven, six]
tailSet(low)  = [nine, one, seven, six, three, two]
headSet(high) = [eight, five, four, nine, one, seven, six]
```
