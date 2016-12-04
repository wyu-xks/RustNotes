---
title: Java ConcurrentHashMap 简介与源码阅读
date: 2018-01-24 20:48:48
category: Java_note
tag: [Java]
toc: true
---

本文概要
* ConcurrentHashMap 简介
* HashMap Fast-fail 产生原因
* ConcurrentHashMap 同步方式
* size操作

### ConcurrentHashMap 简介
`java.util.concurrent`包提供了映射表的高效实现。使用复杂的算法，通过允许并发地访问数据结构的不同部分来使竞争极小化。
与大多数集合不同，`size`方法通常需要遍历。

ConcurrentHashMap与HashMap相比，有以下不同点

* ConcurrentHashMap线程安全，而HashMap非线程安全
* HashMap允许Key和Value为null，而ConcurrentHashMap不允许
* HashMap不允许通过Iterator遍历的同时通过HashMap修改，而ConcurrentHashMap允许该行为，并且该更新对后续的遍历可见

### HashMap Fast-fail 产生原因
在使用迭代器的过程中如果HashMap被修改，那么ConcurrentModificationException将被抛出，也即Fast-fail策略。

当HashMap的iterator()方法被调用时，会构造并返回一个新的EntryIterator对象，
并将EntryIterator的expectedModCount设置为HashMap的modCount（该变量记录了HashMap被修改的次数）。
```java
HashIterator() {
  expectedModCount = modCount;
  if (size > 0) { // advance to first entry
  Entry[] t = table;
  while (index < t.length && (next = t[index++]) == null)
    ;
  }
}
```
在通过该Iterator的next方法访问下一个Entry时，它会先检查自己的expectedModCount与HashMap的modCount是否相等，
如果不相等，说明HashMap被修改，直接抛出ConcurrentModificationException。该Iterator的remove方法也会做类似的检查。
该异常的抛出意在提醒用户及早意识到线程安全问题。

### ConcurrentHashMap 同步方式
* 以下代码基于JDK 1.8.0_77
Java 7 ConcurrentHashMap使用了分段锁；Java 8使用了CAS（compare and swap）。

对于put操作，如果Key对应的数组元素为null，则通过CAS操作将其设置为当前值。
如果Key对应的数组元素（也即链表表头或者树的根元素）不为null，则对该元素使用synchronized关键字申请锁，然后进行操作。
如果该put操作使得当前链表长度超过一定阈值，则将该链表转换为树，从而提高寻址效率。

对于读操作，由于数组被volatile关键字修饰，因此不用担心数组的可见性问题。
同时每个元素是一个Node实例（Java 7中每个元素是一个HashEntry），它的Key值和hash值都由final修饰，不可变更，无须关心它们被修改后的可见性问题。
而其Value及对下一个元素的引用由volatile修饰，可见性也有保障。
```java
    static class Node<K,V> implements Map.Entry<K,V> {
        final int hash;
        final K key;
        volatile V val;
        volatile Node<K,V> next;
```

对于Key对应的数组元素的可见性，由Unsafe的`getObjectVolatile`方法保证。
```java
    @SuppressWarnings("unchecked")
    static final <K,V> Node<K,V> tabAt(Node<K,V>[] tab, int i) {
        return (Node<K,V>)U.getObjectVolatile(tab, ((long)i << ASHIFT) + ABASE);
    }
```

### size操作
put方法和remove方法都会通过addCount方法维护Map的size。
`size`方法通过`sumCount`获取由addCount方法维护的Map的size。
```java
    public int size() {
        long n = sumCount();
        return ((n < 0L) ? 0 :
                (n > (long)Integer.MAX_VALUE) ? Integer.MAX_VALUE :
                (int)n);
    }

    final long sumCount() {
        CounterCell[] as = counterCells; CounterCell a;
        long sum = baseCount;
        if (as != null) {
            for (int i = 0; i < as.length; ++i) {
                if ((a = as[i]) != null)
                    sum += a.value;
            }
        }
        return sum;
    }
```

### 参考
* [Java进阶（六）从ConcurrentHashMap的演进看Java多线程核心技术](https://www.jianshu.com/p/62b04a773886)
