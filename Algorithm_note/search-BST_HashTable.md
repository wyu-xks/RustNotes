---
title: 《算法》 查找
date: 2015-07-11 15:08:19
category: Algorithm
tag: [algorithm]
toc: true
---
***Algorithms***  4th edition by Robert Sedgewick and Kevin Wayne  
《算法》第四版  网站  http://algs4.cs.princeton.edu/20sorting/

[TOC]

# 查找

**符号表** 描述一张抽象的表格，我们会将信息存储在其中，然后按照指定的键来搜索并获取这些信息

	定义 符号表是一种存储键值对的数据结构，支持两种操作：插入（put），即将一组新的键值对存入表中；查找（get），即根据给定的键得到相应的值

符号表最主要的目的就是将一个键和一个值联系起来。

二叉查找树，红黑树，散列表

所有的实现都遵循以下规则：

* 每个键只对应着一个值（表中不允许存在重复的键）
* 当用例代码向表中存入的键值对和表中已有的键冲突时，新值会取代旧的值

## 二叉查找树
将链表插入的灵活性和有序数组查找的高效性结合起来的符号表实习。具体来说，就是使用每个结点含有两个链接的二叉查找树来高效地实现符号表。

    定义 一棵二叉查找树（BST）是一棵二叉树。其中每个结点都含有一个Comparable的键，且每个结点的键都大于其左子树中的任意结点的键，并小于右子树的任意结点的键。

最好的情况下，一棵含有N个结点的树是完全平衡的，每条空链接和根节点的距离都为～lgN

最后实现的，是能够存储数据的二叉查找树。
### 数据表示
每个结点都含有一个键，一个值，一条左链接，一条右链接，一个结点计数器
* 左链接指向一棵由小于该结点的所有键组成的二叉查找树
* 右链接指向一棵由大于该结点的所有键组成的二叉查找树
* 变量N给出了以该结点为根的子树的结点总数

建立结点内部类
```java
    /**
     * 私有结点类
     */
    private class Node {
        private Key key;
        private Value val;
        private Node left, right;// 左右链接
        private int N;           // 以该结点为根的子树的结点总数

        public Node(Key key, Value val, int N) {
            this.key = key;
            this.val = val;
            this.N = N;
        }
    }
```
### 查找
如果树是空的，则查找未命中；如果被查找的键和根节点的键相等，查找命中；否则就在适当的子树中（递归地）继续查找。  
对应的是get方法
```java
    /**
     * @param key 键
     * @return 目标键对应的值
     */
    public Value get(Key key) {
        return get(root, key);
    }

    private Value get(Node x, Key key) {
        if (x == null)
            return null;
        int cmp = key.compareTo(x.key);
        if (cmp < 0) return get(x.left, key);
        else if (cmp > 0) return get(x.right, key);
        else return x.val;
    }
```
### 插入结点
如果树是空的，就返回一个含有该键值对的新结点；如果被查找的键小于根结点的键，继续在左子树中插入该键，否则在右子树中插入该键。  
对应的是put方法
```java
    /**
     * @param key 键
     * @param val 要插入的值
     */
    public void put(Key key, Value val) {
        // 如果key已存在，则更新它的值；否则创建一个新的结点
        root = put(root, key, val);
    }

    private Node put(Node x, Key key, Value val) {
        // 如果目标结点不存在，返回一个含有该键值对的新结点
        if (x == null) return new Node(key, val, 1);
        int cmp = key.compareTo(x.key);
        if (cmp < 0) x.left = put(x.left, key, val);// 尝试建立左子结点
        else if (cmp > 0) x.right = put(x.right, key, val);
        else x.val = val;
        x.N = size(x.left) + size(x.right) + 1;// 更新当前N值；沿着搜索路径更新
        return x;
    }
```
### 有序性相关的方法和删除操作
二叉查找树得以广泛应用的一个重要原因就是它能够保持*键的有序性*。

#### 最大键和最小键
如果根结点的左链接为空，那么一棵二叉查找树中最小的键就是根节点；如果左链接非空，那么树中的最小键就是左子树中的最小键。  
根据树的结构，从根节点开始递归地查找最大键或最小键。
```java
    /**
     * @return 最小的键
     */
    public Key min() {
        return min(root).key;
    }

    private Node min(Node x) {
        if (x.left == null) return x;
        return min(x.left);
    }

    /**
     * @return 最大的键
     */
    public Key max() {
        return max(root).key;
    }

    private Node max(Node x) {
        if (x.right == null) return x;
        return max(x.right);
    }
```
#### 向上取整和向下取整
给定键key，小于等于key的最大键（floor），大于等于key的最小键（ceiling）  
ceiling()的实现和floor基本相同，将left和right（以及大于小于号）调换即可
```java
    /**
     * @param key 目标键
     * @return 小于等于key的最大键
     */
    public Key floor(Key key) {
        Node x = floor(root, key);
        if (x == null) return null;
        return x.key;
    }

    private Node floor(Node x, Key key) {
        if (x == null) return null;
        int cmp = key.compareTo(x.key);
        if (cmp == 0) return x;
        if (cmp < 0) return floor(x.left, key);
        Node t = floor(x.right, key);
        if (t != null) return t;
        else return x;
    }
```

#### 排名
select和rank方法
```java
   /**
     * @param k 排名
     * @return 返回排名为k的结点的键
     */
    public Key select(int k) {
        return select(root, k).key;
    }

    private Node select(Node x, int k) {
        if (x == null) return null;
        int t = size(x.left);
        if (t > k) return select(x.left, k);
        else if (t < k) return select(x.right, k - t - 1);
        else return x;
    }

    /**
     * @param key 目标键
     * @return 获取键的排名，最小是0
     */
    public int rank(Key key) {
        return rank(key, root);
    }

    private int rank(Key key, Node x) {
        if (x == null) return 0;
        int cmp = key.compareTo(x.key);// 直接用键来比较
        if (cmp < 0) return rank(key, x.left);
        else if (cmp > 0) return 1 + size(x.left) + rank(key, x.right);
        else return size(x.left);
    }
```

#### 删除最大键和删除最小键
最小键一般在最左边，递归的寻找最左边的键，然后将指向该结点的链接指向该结点的右子树  
删除最大键也类似
```java
    /**
     * 删除键最小的键值对
     */
    public void deleteMin() {
        root = deleteMin(root);
    }

    private Node deleteMin(Node x) {
        if (x.left == null) return x.right;
        x.left = deleteMin(x.left);
        x.N = size(x.left) + size(x.right) + 1;
        return x;
    }
```
#### 删除指定键值对
在删除结点x后用它的后继结点填补它的位置。x有一个右子结点，因此它的后继结点就是右子树中最小结点。
```java
    /**
     * @param key 删除对应的键值对
     */
    public void delete(Key key) {
        root = delete(root, key);
    }

    private Node delete(Node x, Key key) {
        if (x == null) return null;
        int cmp = key.compareTo(x.key);
        if (cmp < 0) x.left = delete(x.left, key);
        else if (cmp > 0) x.right = delete(x.right, key);
        else {
            if (x.right == null) return x.left;
            if (x.left == null) return x.right;
            Node t = x;// t是将要被删除的结点
            x = min(t.right);// 找一个最小的来做后继结点
            x.right = deleteMin(t.right);
            x.left = t.left;
        }
        x.N = size(x.left) + size(x.right) + 1;
        return x;
    }
```
### 性能
    命题 在一棵二叉查找树中，所有操作在最坏情况下所需的时间都和树的高度成正比。

### 二叉查找树的实现
二叉查找树Java代码
```java
public class BST<Key extends Comparable<Key>, Value> {
    private Node root;

    /**
     * @return 根节点
     */
    public Node getRoot() {
        return root;
    }

    /**
     * @return 根节点的key和size，左右链接的key
     */
    public String getRootKey() {
        return "root key = " + root.key + "; size = " + root.N
                + ";left child = " + root.left.key
                + ";right child = " + root.right.key
                ;
    }

    /**
     * @return 结点总个数
     */
    public int size() {
        return size(root);
    }

    private int size(Node x) {
        if (x == null)
            return 0;
        else
            return x.N;
    }

    /**
     * 中序遍历
     *
     * @param x 结点
     */
    public void middleOrderPrint(Node x) {
        if (x == null) return;
        middleOrderPrint(x.left);
        System.out.print(x.key + " ");
        middleOrderPrint(x.right);
    }
    // 相关方法在前文中
}
```
使用BST存储数据，Java代码：
```java
public static void main(String args[]) {
        BST<String, Integer> bst = new BST<>();
        bst.put("H", 5);
        bst.put("E", 2);
        ......

        test(bst);

    }

    private static void test(BST bst) {
        bst.middleOrderPrint(bst.getRoot());
        ......
    }
```
输出结果：
```
A B D E H J L M
......
```
可以看到，二叉树的高度受输入数据的顺序影响；这样并不能很好地发挥出二叉查找树的性能。

## 平衡二叉树

### 2-3查找树
允许树中的一个结点保存多个键  
将一棵标准的二叉查找树中的结点称为2-结点（含有一个键和两条链接）  
3-结点，含有两个键和三条链接

    定义 一棵2-3查找树或为一棵空树，或由以下结点组成：

    2-结点，含有一个键（及其对应的值）和两条链接，左链接指向的2-3树中的键都小于该结点，右链接指向的2-3树中的键都大于该结点。

    3-结点，含有两个键（及其对应的值）和三条链接，左链接指向的2-3树中的键都小于该结点，中链接指向的2-3树中的键都位于该结点的两个键之间，右链接指向的2-3树中的键都大于该结点。

    指向一棵空树的链接称为空链接。

    命题 在一棵大小为N的2-3树中，查找和插入操作访问的结点必然不超过lgN个

一棵完美平衡的2-3查找树中的所有空链接到根结点的距离都应该是相同的。

和标准的二叉查找树由上向下生长不同，2-3树的生长是由下向上的。

### 红黑二叉查找树
用标准的二叉查找树和一些额外信息来表示2-3树。
将树中的链接分为两种类型：红链接将两个2-结点连接起来构成一个3-结点。黑链接则是2-3树中的普通链接。
这种表示法的优点是，无需修改就可以直接使用标准二叉查找树的get()方法。

```java
    private class Node {
        Key key;
        Value val;
        Node left, right;
        int N;
        boolean color;

        Node(Key key, Value val, int n, boolean color) {
            this.key = key;
            this.val = val;
            N = n;
            this.color = color;
        }
    }
```

#### 一种等价的定义
红黑树：

* 红链接皆为左链接
* 没有任何一个结点同时和两条红链接相连
* 该树是完美黑色平衡的，即任意空链接到根结点的路径上的黑链接数量相同

#### 颜色表示
每个结点都有一条指向自己的链接。链接的颜色保存在表示结点的Node数据类型的boolean color中。如果指向它的链接是红色的，则为true；黑色为false。

```java
    private boolean isRed(Node x) {
        return (x != null && x.color);
    }
```
#### 旋转
如果出现了红色右链接或者两条连续的红链接，需要旋转并修复；修复成红色左链接

左旋转 - 红色的右链接需要被转化为左链接  
将两个键中的较小者作为根节点变为将较大者作为根节点

旋转操作可以保持红黑树的两个重要性质：有序性和完美平衡性

```java
    /**
     * 红色右链接，旋转后为红色左链接
     *
     * @param h 在这里为父节点
     * @return 新的父节点，也就是h原来的右结点
     */
    private Node rotateLeft(Node h) {
        Node x = h.right;   // 设h的右结点为x
        h.right = x.left;   // h和x的中间结点先接过来
        x.left = h;         // 原右结点和父节点开始互换
        x.color = h.color;  // 设定新父节点颜色
        h.color = RED;      // 设定红链接
        x.N = h.N;          // 父结点N值不变
        h.N = 1 + size(h.right) + size(h.left);
        return x;   // 返回新的父节点，取代了原来的h
    }

    /**
     * 红色左链接，旋转后为红色右链接；出现连续红色左链接时候调用
     * 与 rotateLeft(Node h) 方法类似
     */
    private Node rotateRight(Node h) {
        Node x = h.left;
        h.left = x.right;
        x.right = h;
        x.color = h.color;
        h.color = RED;
        x.N = h.N;
        h.N = 1 + size(h.right) + size(h.left);
        return x;
    }
```
#### 颜色转换
flipColors(Node h)方法，父结点颜色变红，两个子结点颜色变黑
局部变换，不会影响整棵树的黑色平衡性

    命题 一棵大小为N的红黑树的高度不会超过2lgN

    命题 一棵大小为N的红黑树中，根结点到任意结点的平均路径长度为～1.00lgN

###### 完全二叉树(Complete Binary Tree)
若设二叉树的深度为h，除第 h 层外，其它各层 (1～h-1) 的结点数都达到最大个数，第 h 层所有的结点都连续集中在最左边，这就是完全二叉树。
完全二叉树是由满二叉树而引出来的。对于深度为K的，有n个结点的二叉树，当且仅当其每一个结点都与深度为K的满二叉树中编号从1至n的结点一一对应时称之为完全二叉树。
一棵二叉树至多只有最下面的一层上的结点的度数可以小于2，并且最下层上的结点都集中在该层最左边的若干位置上，则此二叉树成为完全二叉树。

## 散列表 （hash table）
哈希表

如果所有的键都是小整数，我们可以用一个数组来实现无序的符号表，将键作为数组的索引而数组中键i处储存的就是它对应的值。散列表采用这种方法的扩展，并能够处理更复杂的类型的键。

散列表是时间和空间上做出权衡的经典例子。如果没内存限制，可直接将键作为数组索引。那么所有查找操作只需要访问一次内存即可完成。

使用散列表分两步：

* 用散列函数将被查找的键转化为数组的一个索引
* 处理碰撞冲突 - 处理两个或多个键的散列值相同的情况
    * 拉链法和线性探索法

### 散列函数
散列函数的计算，将键化为数组的索引
对于每种类型的键都需要一个与之对应的散列函数

### 基于拉链法的散列表



## 应用
代表性例子

* 能够快速灵活地从文件中提取由逗号分隔的信息的一个字典程序和索引程序。
* 为一组文件构建逆向索引的一个程序。
* 一个表示稀疏矩阵的数据类型。

各种符号表实现的渐进性能的总结
![]()
