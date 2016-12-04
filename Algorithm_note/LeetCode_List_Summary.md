---
title: LeetCode-链表问题小集
date: 2014-05-29 22:53:16
category: Algorithm
tag: [algorithm,LeetCode]
toc: true
---


```
19. Remove Nth Node From End of List
21. Merge Two Sorted Lists
24. Swap Nodes in Pairs
82. Remove Duplicates from Sorted List II
83. Remove Duplicates from Sorted List
141. Linked List Cycle
142. Linked List Cycle II
234. Palindrome Linked List
```

Java实现的链表节点
```java
// Definition for singly-linked list.
public class ListNode {
    int val;
    ListNode next;
    ListNode(int x) { val = x; }
}
```

Python实现的链表节点
```python
# Definition for singly-linked list.
class ListNode(object):
    def __init__(self, x):
        self.val = x
        self.next = None

    def __repr__(self):
        return 'ListNode{%d}' % self.val

    def add(self, tail):
        self.next = tail
```

#### 19. Remove Nth Node From End of List
>Given a linked list, remove the nth node from the end of list and return its head.

>For example,  
   Given linked list: 1->2->3->4->5, and n = 2.  
   After removing the second node from the end, the linked list becomes 1->2->3->5.  

>Note:
Given n will always be valid.
Try to do this in one pass.

```java
    /**
     * @param head
     * @param n
     * @return ListNode
     */
    public static ListNode removeNthFromEnd(ListNode head, int n) {
        if (n == 0) return head;
        ListNode fakeNode = head;
        int count = 0;
        while (fakeNode != null) {
            fakeNode = fakeNode.next;
            count++;
        }
        fakeNode = head;
        if (n == count) {
            head = head.next;
            return head;
        } else {
            for (int i = 0; i < count; i++) {
                if (i + n + 1== count) {
                    System.out.println(fakeNode.val);
                    ListNode cut = fakeNode.next.next;
                    fakeNode.next = cut;
                    count--;
                    continue;
                }
                fakeNode = fakeNode.next;
            }
        }
        return head;
    }
```
#### 21. Merge Two Sorted Lists
>Merge two sorted linked lists and return it as a new list. The new list should be made by splicing together the nodes of the first two lists.

```java
public class Solution {
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
                ListNode r1 = new ListNode(0);
        ListNode res = r1;
        ListNode t1 = l1;//java 中这样的赋值操作，对了l1操作等同于对t1操作
        ListNode t2 = l2;
        while (t1 != null && t2 != null){
            if (t1.val <= t2.val) {
                r1.next = t1;
                t1 = t1.next;
            } else {
                r1.next = t2;
                t2 = t2.next;
            }
            r1 = r1.next;
        }
        if (t1 != null) {
            r1.next = t1;
        }
        if (t2 != null) {
            r1.next = t2;
        }
        res = res.next;
        return res;
    }
}
```

#### 24. Swap Nodes in Pairs
Given a linked list, swap every two adjacent nodes and return its head.

For example,

Given 1->2->3->4, you should return the list as 2->1->4->3.

Your algorithm should use only constant space. You may not modify the values in the list, only nodes itself can be changed.

#### 82. Remove Duplicates from Sorted List II
```
Given a sorted linked list, delete all nodes that have duplicate numbers, leaving only distinct numbers from the original list.

For example,
Given 1->2->3->3->4->4->5, return 1->2->5.
Given 1->1->1->2->3, return 2->3.
```
难点在于要删掉所有连续重复的节点。有可能需要移动头部。

思路1，给链表创建一个新的假的头部。用双游标来查重。

Java代码
```java
    public static ListNode deleteDuplicates(ListNode head) {
        if (head == null) {
            return null;
        }
        ListNode fakeHead = new ListNode(head.val - 1);
        fakeHead.next = head;
        ListNode pre = fakeHead;
        ListNode cur = head;
        while (cur != null) {
            while (cur.next != null && cur.val == cur.next.val) {
                cur = cur.next; // 删掉连续的节点
            }
            if (pre.next == cur) {
                pre = pre.next; // cur 没有向后移动   pre向后移动一位
            } else {
                pre.next = cur.next; // 相当于删掉了这个cur 而pre并没有移动
            }
            cur = cur.next;
        }
        return fakeHead.next;
    }
```

Python实现
```python
    def deleteDuplicates(self, head):
        """
        :type head: ListNode
        :rtype: ListNode
        """
        fakeHead = ListNode(1)
        fakeHead.next = head
        pre = fakeHead
        cur = head

        while cur is not None:
            while cur.next is not None and cur.val == cur.next.val:
                cur = cur.next  # delete the duplicated node
            if pre.next == cur:
                pre = pre.next
            else:
                pre.next = cur.next
            cur = cur.next
        return fakeHead.next
```

#### 83. Remove Duplicates from Sorted List
```
Given a sorted linked list, delete all duplicates such that each element appear only once.

For example,
Given 1->1->2, return 1->2.
Given 1->1->2->3->3, return 1->2->3.
```

思路1，递归方法。  
Java代码
```java
    public static ListNode deleteDuplicates(ListNode head) {
        if (null == head) {
            return null;
        }
        if (head.next != null) {
            if (head.val == head.next.val) {
                head.next = head.next.next;
                deleteDuplicates(head);
            }
            if (head.next != null) {
                head.next = deleteDuplicates(head.next);
            }
        }
        return head;
    }
```

思路2，使用while循环解决问题。解法本质上和思路1一样。  
Java代码
```java
    public ListNode deleteDuplicates(ListNode head) {
        ListNode node = head;
        while (node != null) {
            if (node.next == null) {
                break;
            }
            if (node.val == node.next.val) {
                node.next = node.next.next;
            } else {
                node = node.next;
            }
        }
        return head;
    }
```

Python实现
```python
class Solution(object):
    def deleteDuplicates(self, head):
        """
        :type head: ListNode
        :rtype: ListNode
        """
        node = head

        while node is not None:
            if node.next is None:
                break
            if node.val == node.next.val:
                node.next = node.next.next  # delete
            else:
                node = node.next  # go to next loop
        return head
```

#### 141. Linked List Cycle
```
Given a linked list, determine if it has a cycle in it.

Follow up:
Can you solve it without using extra space?
```

判断单向链表中是否存在环。  

思路1，快慢指针法。创建2个指针，分别每次向后移动1步和2步。它们进入环后，
会相遇。相遇则表示环存在。

Python
```python
    def hasCycle(self, head):
        """
        :type head: ListNode
        :rtype: bool
        """
        try:
            one_step = head
            two_step = head.next
            while one_step is not two_step:
                one_step = one_step.next
                two_step = two_step.next.next
            return True
        except:
            return False
```

#### 142. Linked List Cycle II
```
Given a linked list, return the node where the cycle begins. If there is no cycle, return null.
Note: Do not modify the linked list.

Follow up:
Can you solve it without using extra space?
```

找出环行链表的入口节点，如果没有环则返回空

使用快慢2个指针，当二者相遇则表示环存在。此时另一个指针slow2从head开始一步一步向后
移动，同时前面的慢指针slow也一步一步向后移动。当二者相遇则是入口节点。

Python代码
```python
    def detectCycle(self, head):
        """
        :type head: ListNode
        :rtype: ListNode
        """
        slow = head
        fast = head
        while fast is not None and fast.next is not None:
            fast = fast.next.next
            slow = slow.next
            if fast is slow:
                slow2 = head
                while slow2 is not slow:
                    slow2 = slow2.next
                    slow = slow.next
                return slow
        return None

```

#### 234. Palindrome Linked List
>Given a singly linked list, determine if it is a palindrome.

回文链表。我用堆栈做，速度很慢。
