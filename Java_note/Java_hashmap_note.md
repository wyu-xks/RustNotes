---
title: Java HashMap 简介与工作原理
date: 2018-01-24 20:42:30
category: Java_note
tag: [Java]
toc: true
---

本文概要
* HashMap 简介
* HashMap 工作原理
    * 属性介绍
    * 方法介绍
    * 数据的存储结构
* 相关参考

链表和数组可以按照人们的意愿排列元素的次序。但若想查看某个指定的元素，却忘记了位置，就需要访问所有元素，直到找到为止。
如果集合包含的元素太多，会消耗很多时间。为了快速查找所需的对象，我们来看HashMap。

### HashMap简介
映射表（Map）数据结构。映射表用来存放键值对。如果提供了键，就能查找到值。
Java类库为映射表提供了两个通用的实现：HashMap和TreeMap。这两个类都实现了Map接口。

HashMap采取的存储方式为：链表数组或二叉树数组。
散列映射表对键进行散列，数映射表的整体顺序对元素进行排序，并将其组织成搜索树。
散列或比较函数只能左右与键。与键关联的值不能进行散列或比较。

每当往映射表中添加或检索对象时，必须同时提供一个键。即通过Key查找Value。
键必须是唯一的。不能对同一个键存放两个值。如果对同一个键两次调用put方法，后一个值将会取代第一个值。

HashMap 继承于AbstractMap，实现了Map、Cloneable、java.io.Serializable接口。 
HashMap 的实现不是同步的，这意味着它不是线程安全的。它的key、value都可以为null。此外，HashMap中的映射不是有序的。 

下面是构造函数
```java
    public HashMap()
    public HashMap(int initialCapacity)
    public HashMap(int initialCapacity, float loadFactor)
    
    // 包含 "子Map" 的构造函数 
    public HashMap(Map<? extends K, ? extends V> map)
```
用给定的容量和装填因子构造一个空散列映射表。
装填因子是一个0.0~1.0之间的数值。这数值决定散列表填充的百分比。默认装填因子是0.75。
一旦到了这个百分比，就要将其再散列（rehashed）到更大的表中，并将现有元素插入新表，并舍弃原来的表。

### HashMap 工作原理
* JDK 1.8

HashMap 继承 AbstractMap，实现了Map、Cloneable、java.io.Serializable接口
```java
public class HashMap<K,V> extends AbstractMap<K,V>
    implements Map<K,V>, Cloneable, Serializable
```

#### 内部节点类
内部数据结构类，基础hash节点
```java
    /**
     * Basic hash bin node, used for most entries.  (See below for
     * TreeNode subclass, and in LinkedHashMap for its Entry subclass.)
     */
    static class Node<K,V> implements Map.Entry<K,V> 
```

内部数据结构类，二叉树节点
```java
    /**
     * Entry for Tree bins. Extends LinkedHashMap.Entry (which in turn
     * extends Node) so can be used as extension of either regular or
     * linked node.
     */
    static final class TreeNode<K,V> extends LinkedHashMap.Entry<K,V>
```

#### 常量定义
默认容量必须是2的次方，这里是16  
`static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16`

最大容量必须小于等于 1<<30 。若设置的容量大于最大容量，将其限制在最大容量。  
`static final int MAXIMUM_CAPACITY = 1 << 30;`

超过此阈值，将某个元素的链表结构转换成树结构  
`static final int TREEIFY_THRESHOLD = 8;`

小于等于此阈值，将二叉树结构转换成链表结构  
`static final int UNTREEIFY_THRESHOLD = 6;`

#### 状态变量
已存储的键值对数量，map中有多少个元素  
`transient int size;`

当存储的数量达到此值后，需要重新分配大小(capacity * load factor)  
`int threshold;`

此HashMap的结构被修改的次数  
`transient int modCount;`

存储数据的数组。必要时会重新分配空间。长度永远是2的次方。不需要序列化。  
它的长度会参与存入元素索引的计算。假设长度n为默认的16，那么通过`(n - 1) & hash`计算得到的索引范围是[0, 15]  
装载节点的数组table。首次使用时会初始化，必要时重新分配大小。长度是2的次方。  
`transient Node<K,V>[] table;`

table的存储结构，利用链表  
![list1](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Java_note/pics/hashmap_internal_storage_list_1.png)

或者二叉树结构  
![tree1](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Java_note/pics/hashmap_internal_storage_tree_1.png)

链表结构和二叉树结构会根据实际使用情况互相转换。具体参见`UNTREEIFY_THRESHOLD`与`TREEIFY_THRESHOLD`。

#### 构造函数
带容量和装载因子的构造函数。检查输入的容量值，将其限制在0到最大容量之间。检查装载因子。
```java
    public HashMap(int initialCapacity, float loadFactor) {
        if (initialCapacity < 0)
            throw new IllegalArgumentException("Illegal initial capacity: " +
                                               initialCapacity);
        if (initialCapacity > MAXIMUM_CAPACITY)
            initialCapacity = MAXIMUM_CAPACITY;
        if (loadFactor <= 0 || Float.isNaN(loadFactor))
            throw new IllegalArgumentException("Illegal load factor: " +
                                               loadFactor);
        this.loadFactor = loadFactor;
        this.threshold = tableSizeFor(initialCapacity);
    }
```
#### 方法
获取key对象的hash值。高位与低位进行亦或（XOR）计算。
```java
    static final int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
    }
```

创建一个常规节点
```java
    // Create a regular (non-tree) node
    Node<K,V> newNode(int hash, K key, V value, Node<K,V> next) {
        return new Node<>(hash, key, value, next);
    }
```

初始化或让table的尺寸放大一倍  
`final Node<K,V>[] resize()`

LinkedHashMap用的回调
```java
    // Callbacks to allow LinkedHashMap post-actions
    void afterNodeAccess(Node<K,V> p) { }
    void afterNodeInsertion(boolean evict) { }
    void afterNodeRemoval(Node<K,V> p) { }
```

##### `put(K key, V value)`方法流程
调用put方法时，发生了什么？

添加键值对的方法。重点看`putVal`方法。将尝试插入的键值对暂时称为`目标元素`。
* 检查table实例是否存在，获取table的长度
* 检查输入的hash值，计算得到索引值
    * 若table中对应索引值中没有元素，插入新建的元素
    * 检查当前是否需要扩充容量
* 尝试更新现有的元素
* 若使用了二叉树结构，调用二叉树节点类的插入方法`putTreeVal`
* 遍历内部元素，插入新值或更新原有值
* 检查是否要扩大存储空间
```java
    public V put(K key, V value) {
        return putVal(hash(key), key, value, false, true);
    }

    /**
     * @param onlyIfAbsent 若为true，则不改变已有的值
     * @param evict 若为false，table处于创建状态
     */
    final V putVal(int hash, K key, V value, boolean onlyIfAbsent, boolean evict)
```

实例 `HashMap<String, String>`初始化并调用put方法
```java
        HashMap<String, String> strMap = new HashMap<>();
        strMap.put("one", "value");
        strMap.put("two", "value");
        strMap.put("three", "value");
        System.out.println("hash(\"one\") = " + hash("one"));
        System.out.println("hash(\"two\") = " + hash("two"));
        System.out.println("hash(\"three\") = " + hash("three"));

/*
hash("one") = 110183
hash("two") = 115277
hash("three") = 110338829
*/
```
已知`"one"`的hash值是110183，通过`(n - 1) & hash`计算存储索引。
默认容量n=16，计算得到索引是7。以此类推。

##### `get` 方法流程
计算输入key对象的hash值，根据hash值查找。
若map中不存在相应的key，则返回null。
```java
    public V get(Object key) {
        Node<K,V> e;
        return (e = getNode(hash(key), key)) == null ? null : e.value;
    }
```

#### 从源码中学到的实用方法
求hash值的方法
```java
    public static int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
    }
```

大于且最接近输入值的2的次方数
```java
    /**
     * Returns a power of two size for the given target capacity.
     * MAXIMUM_CAPACITY 是上限
     */
    public static int tableSizeFor(int cap) {
        int n = cap - 1;
        n |= n >>> 1;
        n |= n >>> 2;
        n |= n >>> 4;
        n |= n >>> 8;
        n |= n >>> 16;
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }
```

### 参考
* 《Java核心技术 卷1 基础知识（原书第9版）》
* [Java HashMap 工作原理 - coding-geek](http://coding-geek.com/how-does-a-hashmap-work-in-java/)
