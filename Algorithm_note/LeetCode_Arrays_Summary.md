---
title: LeetCode-数组问题小集-Java
date: 2014-05-29 22:49:16
category: Algorithm
tag: [algorithm,LeetCode]
---

### 数组
#### 26. Remove Duplicates from Sorted Array
>Given a sorted array, remove the duplicates in place such that each element appear only once and return the new length.
Do not allocate extra space for another array, you must do this in place with constant memory.
For example,
Given input array nums = [1,1,2],
Your function should return length = 2, with the first two elements of nums being 1 and 2 respectively. It doesn't matter what you leave beyond the new length.

删除有序数组中重复的元素；返回新的长度；不允许新建额外的数组

解决思路

* 设立2个游标：游标index用来遍历数组，游标newLen用来插入元素
* 遍历数组，两两比较；如果不同，将index指向的元素复制到newLen指向位置；newLen与index各自右移

```java
package com.rust.cal;

public class RemoveDuplicatesfromSortedArray {
    public static int removeDuplicates(int[] nums) {
        if (nums.length <= 1) {
            return nums.length;
        }
        int index = 1;
        int newLen = 1;  // return value
        while(index < nums.length){
            if (nums[index] != nums[index - 1]) {
                nums[newLen] = nums[index];  // insert element
                newLen++;
            }
            index++;
        }
        return newLen;
    }
    public static void main(String args[]){
        int[] input = {1,2,2,3,4,5,5,5,5,5,6,6,6,7,7,7,7,8};
        System.out.println("new lengh: " + removeDuplicates(input));
        for (int i = 0; i < input.length; i++) {
            System.out.print(input[i] + "  ");
        }
    }
}
```
#### 27. Remove Element
>Given an array and a value, remove all instances of that value in place and return the new length.
The order of elements can be changed. It doesn't matter what you leave beyond the new length.

删掉指定的元素，并用后面的元素顶替空出来的位置；

#### 268. Missing Number
>Given an array containing n distinct numbers taken from 0, 1, 2, ..., n, find the one that is missing from the array.
For example,  
Given nums = [0, 1, 3] return 2.  
Note:  
Your algorithm should run in linear runtime complexity. Could you implement it using only constant extra space complexity?

需求：给出一个int型数组，包含不重复的数字0, 1, 2, ..., n；找出缺失的数字；  
如果输入是[0, 1, 2] 返回 3  
输入数组 nums = [0, 1, 2, 4] ；应该返回 3  
输入nums = [2, 0] ；返回 1  
输入nums = [1, 0]；返回 2  

* 方法1：先排序，再线性寻找

元素不一定按顺序排列；
先对数组进行排序，再按顺序寻找
```java
    public int missingNumber(int[] nums) {
        Arrays.sort(nums);
        int index;
        for (index = 0; index < nums.length; index ++) {
            if (index!= nums[index]) {
                return index;
            }
        }
        return index;
    }
```
这个方法比较容易想到，但缺点是速度太慢
* 方法2：异或法

输入的数组中没有重复的元素，可以利用异或的特点进行处理
异或：不同为1，相同为0；
任何数与0异或都不变，例如：a^0 = a ;  
多个数之间的异或满足互换性，a^b^c = a^c^b = a^(b^c)

1.假设输入的数组是[0, 1, 3]，应该返回2  
可以指定一个数组[0, 1, 2, 3]，这个数组包含缺失的那个数字x  
这个指定的数组其实是满足预设条件的数组  
x并不存在，只是占个位置；把它们的元素按位异或，即
```
0, 1, x, 3
0, 1, 2, 3
```
0^1^2^3^0^1^3 = 0^0^1^1^3^3^2 = 0^2 = 2   得到结果“2”

2.假设输入数组是[2, 0]，用数组[0, 1, 2]做如下运算：
0^0^1^2^2 = 1  得到结果 “1”

3.假设输入数组是[0, 1, 2, 3]，指定一个数组[0, 1, 2, 3]用上面的方法计算
0^0^1^1^2^2^3^3 = 0  结果错误；实际应该返回4
我们用来计算的数组，也可以看做是输入数组的下标，再加1；这里应该用[0, 1, 2, 3, 4]来计算
0, 1, 2, 3, x
0, 1, 2, 3, 4
返回4

Java代码
```java
public int missingNumber(int[] nums) {
    if(nums == null || nums.length == 0) {
        return 0;
    }
    int result = 0;
    for(int i = 0; i < nums.length; i++) {
        result ^= nums[i];
        result ^= i;
    }
    return result ^ nums.length;
}
```
代码中实现了前面的异或运算
