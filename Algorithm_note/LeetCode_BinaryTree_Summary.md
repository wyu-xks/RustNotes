---
title: LeetCode-二叉树问题小集
date: 2014-05-29 22:27:16
category: Algorithm
tag: [algorithm,LeetCode]
toc: true
---

二叉树问题
```
94. Binary Tree Inorder Traversal （中序遍历）
96. Unique Binary Search Trees
98. Validate Binary Search Tree
100. Same Tree
101. Symmetric Tree
102. Binary Tree Level Order Traversal （层序遍历）
103. Binary Tree Zigzag Level Order Traversal
104. Maximum Depth of Binary Tree
105. Construct Binary Tree from Preorder and Inorder Traversal
106. Construct Binary Tree from Inorder and Postorder Traversal
107. Binary Tree Level Order Traversal II （层序遍历）
108. Convert Sorted Array to Binary Search Tree
109. Convert Sorted List to Binary Search Tree
110. Balanced Binary Tree
111. Minimum Depth of Binary Tree
114. Flatten Binary Tree to Linked List
124. Binary Tree Maximum Path Sum
144. Binary Tree Preorder Traversal
145. Binary Tree Postorder Traversal
173. Binary Search Tree Iterator
199. Binary Tree Right Side View
222. Count Complete Tree Nodes
226. Invert Binary Tree
235. Lowest Common Ancestor of a Binary Search Tree
236. Lowest Common Ancestor of a Binary Tree
331. Verify Preorder Serialization of a Binary Tree
501. Find Mode in Binary Search Tree
543. Diameter of Binary Tree
```

这里用到的二叉树实现，默认如下

Python二叉树
```python
class TreeNode(object):
    def __init__(self, x):
        self.val = x
        self.left = None
        self.right = None
```

#### 94. Binary Tree Inorder Traversal （中序遍历）
这里用递归实现

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

#### 98. Validate Binary Search Tree
```
Given a binary tree, determine if it is a valid binary search tree (BST).
Assume a BST is defined as follows:
The left subtree of a node contains only nodes with keys less than the node's key.
The right subtree of a node contains only nodes with keys greater than the node's key.
Both the left and right subtrees must also be binary search trees.

Example 1:
    2
   / \
  1   3
Binary tree [2,1,3], return true.

Example 2:
    1
   / \
  2   3
Binary tree [1,2,3], return false.
```

思路1，给每一个节点规定上下限，递归处理。根节点上下限为Long的极限值。

Java代码
```java
    public static boolean isValidBST(TreeNode root) {
        return isValidBST(root, Long.MAX_VALUE, Long.MIN_VALUE);
    }

    public static boolean isValidBST(TreeNode root, long maxValue, long minValue) {
        if (root == null) {
            return true;
        }
        if (root.val >= maxValue || root.val <= minValue) {
            return false;
        }
        return isValidBST(root.left, root.val, minValue) && isValidBST(root.right, maxValue, root.val);
    }
```

Python代码
```python
class Solution(object):
    def isValidBST(self, root):
        """
        :type root: TreeNode
        :rtype: bool
        """
        import sys
        return self.is_valid_bst(root, sys.maxsize, -sys.maxsize)

    def is_valid_bst(self, root, max_val, min_val):
        if root is None:
            return True
        if root.val >= max_val or root.val <= min_val:
            return False
        return self.is_valid_bst(root.left, root.val, min_val) and self.is_valid_bst(root.right, max_val, root.val)
```

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

#### 104. Maximum Depth of Binary Tree
Given a binary tree, find its maximum depth.
The maximum depth is the number of nodes along the longest path from the root node down to the farthest leaf node.

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

#### 108. Convert Sorted Array to Binary Search Tree
Given an array where elements are sorted in ascending order, convert it to a height balanced BST.

#### 109. Convert Sorted List to Binary Search Tree
Given a singly linked list where elements are sorted in ascending order, convert it to a height balanced BST.

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


#### 144. Binary Tree Preorder Traversal
前序遍历

#### 145. Binary Tree Postorder Traversal
后序遍历；递归与循环解法

#### 173. Binary Search Tree Iterator
```
Implement an iterator over a binary search tree (BST). Your iterator will be initialized with the root node of a BST.

Calling next() will return the next smallest number in the BST.

Note: next() and hasNext() should run in average O(1) time and uses O(h) memory, where h is the height of the tree.
```

思路1，使用堆栈暂存节点。针对二叉搜索树。初始化时先把所有的左子树节点压进堆栈。
调用`next`方法时，从堆栈顶部弹出的节点就是当前最小值。根据BST的特点，下一个最小值节点
是右子树`right_c`。若右子树`right_c`非空，将其压入堆栈中。并将`right_c`的所有左
子树压入堆栈（就像初始化时做的那样）。  
这个堆栈里的元素数量是不断变化的。

Python代码
```python
class BSTIterator(object):
    def __init__(self, root):
        """
        :type root: TreeNode
        """
        self.stack = []
        cur = root
        while cur:
            self.stack.append(cur)
            cur = cur.left

    def hasNext(self):
        """
        :rtype: bool
        """
        return len(self.stack) > 0

    def next(self):
        """
        :rtype: int
        """
        node = self.stack.pop()
        cur = node
        if cur.right:
            cur = cur.right
            while cur:
                self.stack.append(cur)
                cur = cur.left
        return node.val

# Your BSTIterator will be called like this:
# i, v = BSTIterator(root), []
# while i.hasNext(): v.append(i.next())
```


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

#### 222. Count Complete Tree Nodes
Given a complete binary tree, count the number of nodes.
Definition of a complete binary tree from Wikipedia:
In a complete binary tree every level, except possibly the last, is completely filled, and all nodes in the last level are as far left as possible. It can have between 1 and 2h nodes inclusive at the last level h.
计算完全二叉树的结点。结点个数就是根结点加上左右子树的结点。利用这一特点进行递归计算。
而完全二叉树中，能找到满二叉树类型的子树。可以利用2^h-1来计算子树结点。

#### 226. Invert Binary Tree
```
Invert a binary tree.

     4                 4 
   /   \             /   \
  2     7    to     7     2   
 / \   / \         / \   / \ 
1   3 6   9       9   6 3   1     
```

思路1，递归方法

Python代码
```python
class Solution(object):
    def invertTree(self, root):
        """
        :type root: TreeNode
        :rtype: TreeNode
        """
        if root is None:
            return root
        t = root.left
        root.left = root.right
        root.right = t
        root.left = self.invertTree(root.left)
        root.right = self.invertTree(root.right)
        return root
```

Java代码
```java
    public static TreeNode invertTree(TreeNode root) {
        if (root == null|| (root.left == null && root.right == null))
            return root;
        TreeNode tmp = root.right; 
        root.right = invertTree(root.left);
        root.left = invertTree(tmp); 
        return root;
    }
```

思路2，使用队列来暂存节点

Python代码
```python
    def invertTree(self, root):
        """
        :type root: TreeNode
        :rtype: TreeNode
        """
        if root is None:
            return root
        buff = []
        buff.append(root)
        while len(buff) != 0:
            node = buff[0]
            buff = buff[1:]  # 删掉首元素
            left = node.left
            node.left = node.right
            node.right = left
            if node.left is not None:
                buff.append(node.left)
            if node.right is not None:
                buff.append(node.right)
        return root
```

#### 235. Lowest Common Ancestor of a Binary Search Tree
```
Given a binary search tree (BST), find the lowest common ancestor (LCA) of two given nodes in the BST.

According to the definition of LCA on Wikipedia: “The lowest common ancestor is defined between two nodes 
v and w as the lowest node in T that has both v and w as descendants (where we allow a node to be a descendant of itself).”

        _______6______
       /              \
    ___2__          ___8__
   /      \        /      \
   0      _4       7       9
         /  \
         3   5
For example, the lowest common ancestor (LCA) of nodes 2 and 8 is 6. Another example is LCA of nodes 2 and 4 is 2, 
since a node can be a descendant of itself according to the LCA definition.
```

对于二叉搜索树，子树是按大小排列的。

思路1，while循环寻找下去，难点在于是往左还是往右往下遍历。  

Java代码
```java
    public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
        while ((root.val - p.val) * (root.val - q.val) > 0) { // 若计算得0，可直接返回root
            root = root.val > p.val ? root.left : root.right; // 决定左还是右
        }
        return root;
    }
```

思路2，递归。和思路1差不多，当前节点与传入p，q的值比大小，决定下一步的方向。

Java代码
```java
    public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
        if (root.val < Math.min(p.val, q.val)) return lowestCommonAncestor(root.right, p, q);
        if (root.val > Math.max(p.val, q.val)) return lowestCommonAncestor(root.left, p, q);
        return root;
    }
```

Python代码
```python
    def lowestCommonAncestor(self, root, p, q):
        """
        :type root: TreeNode
        :type p: TreeNode
        :type q: TreeNode
        :rtype: TreeNode
        """
        if p.val < q.val:
            min_v = p.val
            max_v = q.val
        else:
            min_v = q.val
            max_v = p.val
        if root.val < min_v:
            return self.lowestCommonAncestor(root.right, p, q)
        if root.val > max_v:
            return self.lowestCommonAncestor(root.left, p, q)
        return root
```

Python另一种写法，更高效简洁
```python
    def lowestCommonAncestor(self, root, p, q):
        next_node = p.val < root.val > q.val and root.left or \
               p.val > root.val < q.val and root.right
        return self.lowestCommonAncestor(next_node, p, q) if next_node else root
```

#### 236. Lowest Common Ancestor of a Binary Tree
```
Given a binary tree, find the lowest common ancestor (LCA) of two given nodes in the tree.

According to the definition of LCA on Wikipedia: “The lowest common ancestor is defined between two nodes v and w as the lowest node in T that has both v and w as descendants (where we allow a node to be a descendant of itself).”

        _______3______
       /              \
    ___5__          ___1__
   /      \        /      \
   6      _2       0       8
         /  \
         7   4
For example, the lowest common ancestor (LCA) of nodes 5 and 1 is 3. Another example is LCA of nodes 5 and 4 is 5, since a node can be a descendant of itself according to the LCA definition.
```
与第235题不同，这里的二叉树的节点没有规则。

思路1，递归方法。左右两个方向先后递归，找到目标子树所在的位置为止。找到目标子树后立刻停止递归。

Java代码
```java
    public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
        if (root == null || root == p || root == q) return root;
        TreeNode left = lowestCommonAncestor(root.left, p, q);
        TreeNode right = lowestCommonAncestor(root.right, p, q);
        return left == null ? right : right == null ? left : root;
    }
```

Python代码
```python
    def lowestCommonAncestor(self, root, p, q):
        if root is None or root == p or root == q:
            return root
        left_node = self.lowestCommonAncestor(root.left, p, q)
        right_node = self.lowestCommonAncestor(root.right, p, q)
        return root if left_node and right_node else left_node or right_node
```

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

#### 501. Find Mode in Binary Search Tree
```
Given a binary search tree (BST) with duplicates, find all the mode(s) (the most frequently occurred element) in the given BST.
Assume a BST is defined as follows:
The left subtree of a node contains only nodes with keys less than or equal to the node's key.
The right subtree of a node contains only nodes with keys greater than or equal to the node's key.
Both the left and right subtrees must also be binary search trees.
For example:
Given BST [1,null,2,2],
   1
    \
     2
    /
   2
return [2].

Note: If a tree has more than one mode, you can return them in any order.

Follow up: Could you do that without using any extra space? (Assume that the implicit stack space incurred due to recursion does not count).
```

思路1，递归遍历二叉树，统计出现次数

Python代码，dict的key是字符串
```python

    def findMode(self, root):
        """
        :type root: TreeNode
        :rtype: List[int]
        """
        if root is None:
            return []
        node_dict = dict()  # record count

        def travel_tree(node):
            if node:
                node_dict[str(node.val)] = node_dict.get(str(node.val), 0) + 1
                travel_tree(node.left)
                travel_tree(node.right)

        travel_tree(root)
        max_c = max(node_dict.values())
        res = []
        for k, v in node_dict.items():
            if v == max_c:
                res.append(int(k))
        return res
```

#### 543. Diameter of Binary Tree
```
Given a binary tree, you need to compute the length of the diameter of the tree. The diameter of a binary tree is the length of the longest path between any two nodes in a tree. This path may or may not pass through the root.

Example:
Given a binary tree 
          1
         / \
        2   3
       / \     
      4   5    
Return 3, which is the length of the path [4,2,1,3] or [5,2,1,3].

Note: The length of path between two nodes is represented by the number of edges between them.
```

思路1，求出所有的子树高度。递归求出左右子树高度，取最大值为高度。相加则得到题目要求的
路径。

Python代码
```python
    def diameterOfBinaryTree(self, root):
        """
        :type root: TreeNode
        :rtype: int
        """
        self.max_d = 1
        def depth(node):
            if not node:
                return 0
            left_d = depth(node.left)
            right_d = depth(node.right)
            self.max_d = max(self.max_d, left_d + right_d + 1)
            return max(left_d, right_d) + 1

        depth(root)
        return self.max_d - 1
```
