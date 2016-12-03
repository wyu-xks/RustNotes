---
title: LeetCode-链表问题小集-Java
date: 2014-05-29 22:53:16
category: Algorithm
tag: [algorithm,LeetCode]
toc: true
---

[TOC]

### 链表
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

//Definition for singly-linked list.
class ListNode {
    int val;
    ListNode next;
    ListNode(int x) { val = x; }
}
```
#### 21. Merge Two Sorted Lists
>Merge two sorted linked lists and return it as a new list. The new list should be made by splicing together the nodes of the first two lists.

```java
/**
* Definition for singly-linked list.
* public class ListNode {
*     int val;
*     ListNode next;
*     ListNode(int x) { val = x; }
* }
*/
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

#### 234. Palindrome Linked List
>Given a singly linked list, determine if it is a palindrome.

回文链表。我用堆栈做，速度很慢。
