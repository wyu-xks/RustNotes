---
title: LeetCode-二叉树问题小集-Java
date: 2014-05-29 22:27:16
category: Algorithm
tag: [algorithm,LeetCode]
toc: true
---

[TOC]

### 二叉树遍历问题
想要获取数据，一般都得遍历
#### 94. Binary Tree Inorder Traversal （中序遍历）
这里用递归实现

#### 102. Binary Tree Level Order Traversal （层序遍历）
控制循环次数，来获取同一层的元素；提取出当前元素，再把当前元素的子树推进队列，队列中的元素在不断变化
#### 103. Binary Tree Zigzag Level Order Traversal

Given a binary tree, return the zigzag level order traversal of its nodes' values. (ie, from left to right, then right to left for the next level and alternate between).
For example:
Given binary tree {3,9,20,#,#,15,7},
```
    3
   / \
  9  20
    /  \
   15   7
```
return its zigzag level order traversal as:
```
[
  [3],
  [20,9],
  [15,7]
]
```

和102的层序遍历类似；判断当前层是否需要逆序
#### 107. Binary Tree Level Order Traversal II （层序遍历）

Given a binary tree, return the bottom-up level order traversal of its nodes' values. (ie, from left to right, level by level from leaf to root).
For example:
Given binary tree {3,9,20,#,#,15,7},
```
    3
   / \
  9  20
    /  \
   15   7
```
return its bottom-up level order traversal as:
```
[
  [15,7],
  [9,20],
  [3]
]
```
和102类似，只是最后添加结果时是逆序的

#### 144. Binary Tree Preorder Traversal
前序遍历

#### 145. Binary Tree Postorder Traversal
后序遍历；递归与循环解法

#### 199. Binary Tree Right Side View

Given a binary tree, imagine yourself standing on the right side of it, return the values of the nodes you can see ordered from top to bottom.
For example:
Given the following binary tree,
```
   1            <---
 /   \
2     3         <---
 \     \
  5     4       <---
```
You should return [1, 3, 4].
处理方法和层序遍历差不多，输出最右边那个元素就行；
调换一下顺序，还能得到“Left Side View”

### 二叉树构建与转换

#### 105. Construct Binary Tree from Preorder and Inorder Traversal
利用**前序遍历**和**中序遍历**来建立二叉树
1.在中序遍历中找到root的位置，左边就是root的左子树，右边就是右子树
2.找root的左子节点left；确定left节点在中序遍历中的位置，它左边的就是left的左子树，右边到root之间的就是右子树
3.找root的右子节点right；确定right节点在中序遍历中的位置，它左边到root的就是right的左子树，右边的就是右子树
4.针对left和right，递归的实现这一过程

找root的左子树，位置为`root在前序遍历里的位置+1`；搜索范围，`上次的low到root在中序遍历位置-1`
找root的右子树，位置为`(posPre - low) + (posMid + 1)`；搜索范围，`root的posMid + 1, 上一次递归的high`
```java
root.left = buildTreeI(preorder, posPre + 1, inorder, low, posMid - 1);
root.right = buildTreeI(preorder, (posPre - low) + (posMid + 1), inorder, posMid + 1, high);
```

#### 106. Construct Binary Tree from Inorder and Postorder Traversal
利用**后序遍历**和**中序遍历**来建立二叉树
后序遍历最后一个就是root。找到root在中序遍历的下标，它左边的都是左子树，右边是右子树。使用递归的方法处理。


#### 114. Flatten Binary Tree to Linked List

Given a binary tree, flatten it to a linked list in-place.
For example,
Given
```
         1
        / \
       2   5
      / \   \
     3   4   6
```
The flattened tree should look like:
```
   1
    \
     2
      \
       3
        \
         4
          \
           5
            \
             6
```

二叉树转换为链表；仔细一看，其实转换后的链表顺序就是原二叉树的前序遍历

#### 108. Convert Sorted Array to Binary Search Tree
Given an array where elements are sorted in ascending order, convert it to a height balanced BST.
#### 109. Convert Sorted List to Binary Search Tree
Given a singly linked list where elements are sorted in ascending order, convert it to a height balanced BST.

### 二叉树分析
#### 96. Unique Binary Search Trees
Given n, how many structurally unique BST's (binary search trees) that store values 1...n?
For example,
Given n = 3, there are a total of 5 unique BST's.
```
   1         3     3      2      1
    \       /     /      / \      \
     3     2     1      1   3      2
    /     /       \                 \
   2     1         2                 3
```
本题其实关键是递推过程的分析，n个点中每个点都可以作为root，当 i 作为root时，
小于 i  的点都只能放在其左子树中，大于 i 的点只能放在右子树中，此时只需求出左、右子树各有多少种，
二者相乘即为以 i 作为root时BST的总数。

或者直接用卡塔兰数求解；卡塔兰数另类递归式：  `h(n)=((4*n-2)/(n+1))*h(n-1);(n>2)`
从第0项开始，前几项为 （OEIS中的数列A000108）: 1, 1, 2, 5, 14, 42, 132, 429, 1430, 4862,......
使用int进行除法计算时，特别要注意计算顺序，避免丢失数据。先求乘法比较稳妥。

#### 100. Same Tree

Given two binary trees, write a function to check if they are equal or not.
Two binary trees are considered equal if they are structurally identical and the nodes have the same value.
判断两棵二叉树是不是同样的。

#### 101. Symmetric Tree
Given a binary tree, check whether it is a mirror of itself (ie, symmetric around its center).
For example, this binary tree is symmetric:
```
    1
   / \
  2   2
 / \ / \
3  4 4  3
```
But the following is not:
```
    1
   / \
  2   2
   \   \
    3   3
```
Note:
Bonus points if you could solve it both recursively and iteratively.
#### 104. Maximum Depth of Binary Tree
Given a binary tree, find its maximum depth.
The maximum depth is the number of nodes along the longest path from the root node down to the farthest leaf node.

#### 110. Balanced Binary Tree
Given a binary tree, determine if it is height-balanced.
For this problem, a height-balanced binary tree is defined as a binary tree in which the depth of the two subtrees of every node never differ by more than 1.
判断一个二叉树是否平衡。
用递归的方式，判断每个节点的左右子节点的高度。比较左右子节点的高度，如果高度差大于1，则不平衡。

#### 111. Minimum Depth of Binary Tree
Given a binary tree, find its minimum depth.
The minimum depth is the number of nodes along the shortest path from the root node down to the nearest leaf node.
参考：
http://segmentfault.com/a/1190000003532763

#### 124. Binary Tree Maximum Path Sum
Given a binary tree, find the maximum path sum.

For this problem, a path is defined as any sequence of nodes from some starting node to any node
in the tree along the parent-child connections. The path does not need to go through the root.

For example:
Given the below binary tree,

       1
      / \
     2   3
Return 6.
这题求的是数值之和最大。不一定要过根节点。递归处理。需要一个int来保存结果。

#### 222. Count Complete Tree Nodes
Given a complete binary tree, count the number of nodes.
Definition of a complete binary tree from Wikipedia:
In a complete binary tree every level, except possibly the last, is completely filled, and all nodes in the last level are as far left as possible. It can have between 1 and 2h nodes inclusive at the last level h.
计算完全二叉树的结点。结点个数就是根结点加上左右子树的结点。利用这一特点进行递归计算。
而完全二叉树中，能找到满二叉树类型的子树。可以利用2^h-1来计算子树结点。

#### 331. Verify Preorder Serialization of a Binary Tree
One way to serialize a binary tree is to use pre-order traversal. When we encounter a non-null node,
we record the node's value. If it is a null node, we record using a sentinel value such as #.
```
     _9_
    /   \
   3     2
  / \   / \
 4   1  #  6
/ \ / \   / \
# # # #   # #
```
For example, the above binary tree can be serialized to the string "9,3,4,#,#,1,#,#,2,#,6,#,#", where # represents a null node.
Given a string of comma separated values, verify whether it is a correct preorder traversal serialization of a binary tree. Find an algorithm without reconstructing the tree.
Each comma separated value in the string must be either an integer or a character '#' representing null pointer.
You may assume that the input format is always valid, for example it could never contain two consecutive commas such as "1,,3".
| Example    | Return  |
| :------:   | :----:  |
| "9,3,4,#,#,1,#,#,2,#,6,#,#" | true |
| "1,#"      |  false  |
| "9,#,#,1"  |  false  |

**solution**
Some used stack. Some used the depth of a stack. Here I use a different perspective. In a binary tree, if we consider null as leaves, then
 *   all non-null node provides 2 outdegree and 1 indegree (2 children and 1 parent), except root
 *   all null node provides 0 outdegree and 1 indegree (0 child and 1 parent).

Suppose we try to build this tree. During building, we record the difference between out degree and in degree diff = outdegree - indegree.
When the next node comes, we then decrease diff by 1, because the node provides an in degree. If the node is not null, we increase diff by 2,
because it provides two out degrees. If a serialization is correct, diff should never be negative and diff will be zero when finished.
在二叉树中，如果我们将空节点视为叶子节点，那么除根节点外的非空节点（分支节点）提供2个出度和1个入度（2个孩子和1个父亲）
所有的空节点提供0个出度和1个入度（0个孩子和1个父亲）
假如我们尝试重建这棵树。在构建的过程中，记录出度与入度之差，记为diff = outdegree - indegree
当遍历节点时，我们令diff - 1（因为节点提供了一个入度）。如果节点非空，再令diff + 2（因为节点提供了2个出度）
如果序列化是正确的，那么diff在任何时刻都不会小于0，并且最终结果等于0
```java
    public boolean isValidSerialization(String preorder) {
        String[] nodes = preorder.split(",");
        int diff = 1;
        for (String node : nodes) {
            if (--diff < 0) return false;
            if (!node.equals("#")) diff += 2;
        }
        return diff == 0;
    }
```
