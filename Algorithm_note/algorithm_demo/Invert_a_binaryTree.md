---
title: Invert a binary tree 翻转一棵二叉树
date: 2015-07-16 15:08:14
category: Algorithm
tag: [algorithm]
---
假设有如下一棵二叉树：
```
     4
   /   \
  2     7
 / \   / \
1   3 6   9
```
翻转后：
```
     4
   /   \
  7     2
 / \   / \
9   6 3   1
```

这里采用递归的方法来处理。遍历结点，将每个结点的两个子结点交换位置即可。  
从左子树开始，层层深入，由底向上处理结点的左右子结点；然后再处理右子树


全部代码如下：
```java

public class InvertBinaryTree {

    public static void main(String args[]) {
        TreeNode root = new TreeNode(0); // 构建简单的二叉树
        TreeNode node1 = new TreeNode(1);
        TreeNode node2 = new TreeNode(2);
        TreeNode node3 = new TreeNode(3);
        TreeNode node4 = new TreeNode(4);
        TreeNode node5 = new TreeNode(5);
        TreeNode node6 = new TreeNode(6);
        TreeNode node7 = new TreeNode(7);
        root.left = node1;
        root.right = node2;
        node1.left = node3;
        node1.right = node4;
        node2.left = node5;
        node2.right = node6;
        node4.right = node7;

        preOrderTravels(root);          // 前序遍历一次
        System.out.println();
        root = invertBinaryTree(root);
        preOrderTravels(root);          // 翻转后再前序遍历一次

    }
    // 前序遍历
    public static void preOrderTravels(TreeNode node) {
        if (node == null) {
            return;
        } else {
            System.out.print(node.val + " ");
            preOrderTravels(node.left);
            preOrderTravels(node.right);
        }
    }
    // 翻转二叉树
    private static TreeNode invertBinaryTree(TreeNode root) {
        if (root == null|| (root.left == null && root.right == null))
            return root;// 为空，或没有子树，直接返回；这个结点可以被反转了
        TreeNode tmp = root.right;               // 右子树存入tmp中
        root.right = invertBinaryTree(root.left);// 先处理左子树，然后接到root的右链接
        root.left = invertBinaryTree(tmp);       // 处理tmp中原来的右子树，然后接到root的左链接
        return root;
    }
}
```
输出：
```
0 1 3 4 7 2 5 6
0 2 6 5 1 4 7 3
```
