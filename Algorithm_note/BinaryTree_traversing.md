---
title: 二叉树 - 建立与遍历 Java
date: 2015-09-14 15:08:16
category: Algorithm
tag: [algorithm]
---
二叉树的遍历（traversing binary tree）是指从根节点出发，按照某种次序依次访问二叉树中所有节点，使得每个节点仅被访问一次

* 前序遍历：若二叉树为空，则空操作返回null。否则先访问根节点，然后前序遍历左子树，再前序遍历右子树

* 中序遍历：若二叉树为空，则空操作返回null。否则从根节点开始，中序遍历根节点左子树，然后访问根节点，最后中序遍历右子树

* 后序遍历：若二叉树为空，则空操作返回null。否则以从左到右先叶子后节点的方式遍历访问左右子树，最后访问根节点

* 层序遍历：若树为空，空操作返回null。否则从树的第一层，也就是根节点开始访问，从上而下逐层遍历，在同一层中，从左到右对结点逐个访问
```
com
    └── rust
        └── datastruct
            ├── BinaryTree.java
            └── TestBinaryTree.java
```
二叉树用一个类来实现，并包含内部类节点

里面内置前序遍历、中序遍历和后序遍历三种方法

```java
package com.rust.datastruct;

public class BinaryTree {
    private int BinaryNodeCount = 0;
    BinaryNode root;
    public BinaryTree(){}

    public BinaryNode createRoot(){
        return createRoot(1,null);
    }
    public BinaryNode createRoot(int key,String data){
        BinaryNode root = new BinaryNode(key, data);
        this.root = root;
        return root;
    }

    public BinaryNode createNode(int key,String data){
        return new BinaryNode(key,data);
    }
    public int getNodeCount(){
        return BinaryNodeCount;
    }
    public BinaryNode getRoot(){
        return root;
    }
    public void visitNode(BinaryNode node){
        if (node == null) {
            return ;
        }
        node.setVisited(true);
        System.out.print(node.getData());
    }
    // 前序遍历
    public void preOrderTravels(BinaryNode node) {  
        if (node == null) {  
            return;  
        } else {  
            BinaryNodeCount++;
            visitNode(node);  
            preOrderTravels(node.leftChild);  
            preOrderTravels(node.rightChild);  
        }  
    }  
    // 中序遍历
    public void midOrderTravels(BinaryNode node) {  
        if (node == null) {  
            return;  
        } else {  
            BinaryNodeCount++;
            midOrderTravels(node.leftChild);  // 向左跑到底
            visitNode(node);                  // 左到底后开始访问
            midOrderTravels(node.rightChild);  
        }  
    }  
    // 后序遍历
    public void postOrderTravels(BinaryNode node) {  
        if (node == null) {  
            return;  
        } else {  
            BinaryNodeCount++;
            postOrderTravels(node.leftChild);  
            postOrderTravels(node.rightChild);  
            visitNode(node);
        }  
    }  

    class BinaryNode{
        private int key;
        private String data;
        private BinaryNode leftChild = null;
        private BinaryNode rightChild = null;
        private boolean isVisited = false;

        public int getKey() {
            return key;
        }
        public void setKey(int key) {
            this.key = key;
        }
        public String getData() {
            return data;
        }
        public void setData(String data) {
            this.data = data;
        }
        public BinaryNode getLeftChild() {
            return leftChild;
        }
        public void setLeftChild(BinaryNode leftChild) {
            this.leftChild = leftChild;
        }
        public BinaryNode getRightChild() {
            return rightChild;
        }
        public void setRightChild(BinaryNode rightChild) {
            this.rightChild = rightChild;
        }
        public boolean isVisited() {
            return isVisited;
        }
        public void setVisited(boolean isVisited) {
            this.isVisited = isVisited;
        }
        public BinaryNode(){

        }
        public BinaryNode(int key, String data){
            this.key = key;
            this.data = data;
            this.leftChild = null;
            this.rightChild = null;
        }
    }

}
```
里面内置前序遍历、中序遍历和后序遍历三种方法
```java
package com.rust.datastruct;

import com.rust.datastruct.BinaryTree.BinaryNode;

public class TestBinaryTree {

    public static void main(String args[]){
        BinaryTree bt = new BinaryTree();
        initTree(bt, 1, "A");
        System.out.println("********preOrderTravels********");
        bt.preOrderTravels(bt.root);
        System.out.println();
        System.out.println("********midOrderTravels********");
        bt.midOrderTravels(bt.root);
        System.out.println();
        System.out.println("********postOrderTravels********");
        bt.postOrderTravels(bt.root);
    }
    /**
     *               A
     *        B            C
     *    D     E      F     G
     * H   I  J
     * @param bt 输入一个二叉树对象，定义一个根结点
     * @param rootKey
     * @param rootData
     */
    public static void initTree(BinaryTree bt,int rootKey, String rootData){
        BinaryNode root = bt.createRoot(rootKey, rootData);
        BinaryNode nodeB = bt.createNode(2, "B");
        BinaryNode nodeC = bt.createNode(3, "C");
        BinaryNode nodeD = bt.createNode(4, "D");
        BinaryNode nodeE = bt.createNode(5, "E");
        BinaryNode nodeF = bt.createNode(6, "F");
        BinaryNode nodeG = bt.createNode(7, "G");
        BinaryNode nodeH = bt.createNode(8, "H");
        BinaryNode nodeI = bt.createNode(9, "I");
        BinaryNode nodeJ = bt.createNode(10, "J");
        root.setLeftChild(nodeB);
        root.setRightChild(nodeC);
        nodeB.setLeftChild(nodeD);
        nodeB.setRightChild(nodeE);
        nodeC.setLeftChild(nodeF);
        nodeC.setRightChild(nodeG);
        nodeD.setLeftChild(nodeH);
        nodeD.setRightChild(nodeI);
        nodeE.setRightChild(nodeJ);
    }
}
```
输出：
```
********preOrderTravels********

ABDHIEJCFG

********midOrderTravels********

HDIBEJAFCG

********postOrderTravels********

HIDJEBFGCA
```
## 树，森林和二叉树

### 树转换为二叉树

1.加线，在所有兄弟节点之间加一条线

2.去线，对树中每一个节点，只保留它与第一个孩子结点的连线，删除它与其它孩子节点之间的连线

3.层次调整。以树的根节点为轴心，将整棵树顺时针旋转一定的角度，使其结构分明

### 森林转换为二叉树

1.把每棵树转换为二叉树

2.第一棵二叉树不动，从第二棵二叉树开始，依次把后一棵二叉树的根节点作为前一棵二叉树的根节点的右孩子，用线连起来。
当所有的二叉树连接起来后就得到了由森林转换来的二叉树。

### 二叉树转换为树

右孩子都跨一层连接上去，删掉二叉树右孩子的连线

### 二叉树转换为森林

逐层删掉右孩子的连线
