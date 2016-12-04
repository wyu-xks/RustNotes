---
title: 《算法》 排序
date: 2015-08-23 15:08:20
category: Algorithm
tag: [algorithm]
toc: true
---

***Algorithms***  4th edition by Robert Sedgewick and Kevin Wayne  
《算法》第四版  网站  http://algs4.cs.princeton.edu/20sorting/

# 排序
## 准备工作
交换方法，供后续调用：
```java
    private static void exch(int a[], int i, int j) {
        int t = a[i];
        a[i] = a[j];
        a[j] = t;
    }
```
比较方法：
```java
    /**
     * v < w 返回 true
     */
    private static boolean less(Comparable v, Comparable w) {
        return v.compareTo(w) < 0;//v < w 返回 -1
    }
```

## 选择排序 selection
- 一个游标往右走，不停地找到右部分最小的值并换到左边。

首先，找到数组中最小的那个元素，其次，将其与数组第一个元素交换位置（如果第一个元素就是最小的，那么它自己和自己交换位置）。
接下来在剩下的元素中寻找最小的元素，与数组第二个元素交换位置，如此反复。

选择排序和冒泡还是有差别的。
对于长度为N的数组，选择排序需要大约N^2/2次比较和N次交换

代码段：
```java
    public static void select_sort(int a[]) {
        int N = a.length;
        for (int i = 0; i < N; i++) {
            int min = i;//假设最小位为最左位
            for (int j = i + 1; j < N; j++) {//遍历后面的元素，找到最小值
                if (less(a[j], a[min])) min = j;//比较后，min为最小元素索引
            }
            exch(a, i, min);//交换位置
        }
    }
```

运行时间与输入无关；数据移动是最少的，只有最小值才会移动。

## 插入排序 insertion
- 特点：游标一步一步向右走，每步遍历游标左边的部分；**交换相邻元素**。

游标从索引为1的位置往右走；对比游标以及游标左边的元素，向左边交换元素；
从游标到起始点，向左边一位一位地比较并交换元素；  
小的元素会往左边一位一位地移动；当索引到达右端，排序完成。

对于随机排列的长度为N且主键不重复的数组，平均情况下插入排序需要约N^2/4次比较，
以及约N^2/4次交换。最坏情况下要约N^2/2次比较和N^2/2次交换。
最好情况下N-1次比较，0次交换。

插入排序对常见的某些类型的非随机数组很有效。

代码段：
```java
    public static void insertion_sort(int a[]) {
        int N = a.length;
        for (int i = 1; i < N; i++) {
            for (int j = i; j > 0 && (a[j] < a[j - 1]); j--) {
                exch(a, j, j - 1);
            }
        }
    }
```

### 部分有序
*倒置*指的是数组中两个顺序颠倒的元素。比如EXAMPLE中有11对倒置。E-A等等。  
如果数组中倒置的数量小于数组大小的某个倍数，那么我们说这个数组是部分有序的。

几种典型部分有序数组：  
- 数组中每个元素距离它的最终位置不远
- 一个有序的大数组接一个小数组
- 数组中只有几个元素位置不正确

插入排序对部分有序的数组很有效，选择排序则不然

## 希尔排序 shell
- 设定步进值h，利用插入排序。

基于插入排序的快速的排序算法  
对于大规模乱序数组，插入排序很慢，因为它只会交换相邻的元素，因此元素只能从一端缓慢移动到另一端。

希尔排序的思想是：使数组中任意间隔为h的元素都是有序的。这样的数组称为**h有序数组**。

实现希尔排序的一种方法是对每个h，用插入排序将h个子数组独立地排序。

在插入排序中加入一个外循环`while (h >= 1)`，插入排序以h为间隔；得到一个简洁的希尔排序  
代码段：
```java
    public static void shell_sort(int a[]) {
        int N = a.length;
        int h = 1;
        while (h < N / 3) {
            h = 3 * h + 1;// 找到最大的h
        }
        while (h >= 1) {
            for (int i = h; i < N; i+=h) { // 以h为查询间隔
                for (int j = i; j >= h && less(a[j], a[j - h]); j -= h) {
                    exch(a, j, j - h);// 插入排序
                }
            }
            h = h / 3;// 当h=1时，变成了插入排序
        }
    }
```

希尔排序比插入和选择排序都快得多，并且数组越大优势越大。

Python实现
```python
def shell_sort(arr):
    a_len = len(arr)
    h = 1
    while h < a_len / 3:  # 找到最大间隔
        h = h * 3 + 1
    print "输入长度 len =", a_len, ", 间隔 h =", h
    while h > 0:
        for i in range(h, a_len, h):
            for j in range(i, h - 1, -h):  # 从i开始往左走  注意边界
                if arr[j] < arr[j - h]:
                    t = arr[j]  # exchange
                    arr[j] = arr[j - h]
                    arr[j - h] = t
                print "--> (i=%d,j=%d,h=%d)" % (i, j, h), arr
        h = h / 3

if __name__ == "__main__":
    arr1 = [1, 6, 5, 4, 0, 3, 8, 3, 5, 2]
    print "arr1=", arr1
    shell_sort(arr1)
    print "arr1=", arr1
```

测试输出
```
arr1= [1, 6, 5, 4, 0, 3, 8, 3, 5, 2]
输入长度 len = 10 , 间隔 h = 4
--> (i=4,j=4,h=4) [0, 6, 5, 4, 1, 3, 8, 3, 5, 2]
--> (i=8,j=8,h=4) [0, 6, 5, 4, 1, 3, 8, 3, 5, 2]
--> (i=8,j=4,h=4) [0, 6, 5, 4, 1, 3, 8, 3, 5, 2]
--> (i=1,j=1,h=1) [0, 6, 5, 4, 1, 3, 8, 3, 5, 2]
--> # h=1之后，就是插入排序的过程了
arr1= [0, 1, 2, 3, 3, 4, 5, 5, 6, 8]
```

### 理念： 为何要研究算法的设计和性能？
原因之一：**提升速度来解决其他方式无法解决的问题**

## 归并排序
将两个有序的数组归并成一个更大的有序数组  
递归实现的归并排序是算法设计中分治思想的典型应用。
我们将一个大问题分割成小问题分别解决，然后用小问题的答案来解决整个大问题。


归并排序，将任一长度为N的数组排序所需的时间和NlogN成正比

### 原地归并的抽象方法
原地归并的抽象方法，需要一个辅助数组
```java
/**************************************
 * 原地归并方法
 **************************************/
private static void merge(int a[], int low, int mid, int high) {
    int i = low;// 左数组索引
    int j = mid + 1;// 右数组索引
    int temp[] = new int[high + 1];
    for (int k = low; k <= high; k++) {
        temp[k] = a[k];// 全部复制到辅助数组中
    }
    for (int k = low; k <= high; k++) {
        if (i > mid) {
            a[k] = temp[j++];// 若左数组用尽（左游标走到了右数组）直接取右数组的元素
        } else if (j > high) {
            a[k] = temp[i++];// 若右数组用尽，取左数组的值
        } else if (temp[i] < temp[j]) {
            a[k] = temp[i++];// 哪个小取哪个的
        } else {
            a[k] = temp[j++];// i j 不要写错了
        }
    }
}
```
### 自顶向下的归并排序
如果它能将两个子数组排序，它就能够通过归并两个子数组来将整个数组排序  
分治思想最典型的一个例子  
以int[]为例；基于原地归并的抽象实现了另一种归并
```java
private static void mergeSort(int a[]) {
    iMergeSort(a, 0, a.length - 1);
}

private static void iMergeSort(int a[], int low, int high) {
    if (high <= low) return;
    int mid = low + (high - low) / 2;
    iMergeSort(a, low, mid);         // 将左半部分排序  左半部分变成有序数组
    iMergeSort(a, mid + 1, high);    // 将右半部分排序  右半部分变成有序数组
    merge(a, low, mid, high);        // 调用原地归并方法
}
```
***命题：对于长度为N的任意数组，自顶向下的归并排序需要1/2NlgN至NlgN此比较***

Python实现
```python
def _do_merge(arr, low, mid, high):
    left = low
    right = mid + 1
    temp_origin_arr = [ele for ele in arr]  # Copy list
    print "merging--", arr
    for k in range(low, high + 1):
        if left > mid:
            arr[k] = temp_origin_arr[right]
            right += 1
        elif right > high:
            arr[k] = temp_origin_arr[left]
            left += 1
        elif temp_origin_arr[left] < temp_origin_arr[right]:
            arr[k] = temp_origin_arr[left]
            left += 1
        else:
            arr[k] = temp_origin_arr[right]
            right += 1


def _help_merge(arr, low, high):
    if low >= high:
        return
    mid = low + (high - low) / 2
    _help_merge(arr, low, mid)  # 先处理左半部分
    _help_merge(arr, mid + 1, high)  # 后处理右半部分
    _do_merge(arr, low, mid, high)


def merge_sort_up_down(arr):
    _help_merge(arr, 0, len(arr) - 1)

if __name__ == "__main__":
    arr1 = [3, 2, 8, 4, 1, 5, 2]
    print "arr1=", arr1
    merge_sort_up_down(arr1)
    print "arr1=", arr1
```

Python输出
```
arr1= [3, 2, 8, 4, 1, 5, 2]
merging-- [3, 2, 8, 4, 1, 5, 2]
merging-- [2, 3, 8, 4, 1, 5, 2]
merging-- [2, 3, 4, 8, 1, 5, 2]
merging-- [2, 3, 4, 8, 1, 5, 2]
merging-- [2, 3, 4, 8, 1, 5, 2]
merging-- [2, 3, 4, 8, 1, 2, 5]
arr1= [1, 2, 2, 3, 4, 5, 8]
```
可以看出，先对左半部分归并排序成有序数组，再处理右半部分；最后处理全部。

### 自底向上的归并排序
先归并微型数组，然后再成对归并得到的子数组。直到将整个数组归并在一起。  
步骤  
1.第一层循环，分割成小数组。小数组长度每次都翻倍。  
2.第二层循环，两两归并小数组。  

会多次遍历数组，根据子数组大小进行两两归并。子数组的大小sz的初始值为1，每次加倍。
```java
/*****************************************************
 * 自底向上的归并排序
 *****************************************************/
public static void mergeSortBU(int a[]) {
    int N = a.length;
    // sz 是子数组大小，会翻倍增加
    for (int sz = 1; sz < N; sz = sz + sz) {// low 是子数组的索引
        for (int low = 0; low < N - sz; low += sz + sz) {
            merge(a, low, low + sz - 1, Math.min(low + sz + sz - 1, N - 1));
        }
    }
}
```
当数组长度为2的幂时，自顶向下和自底向上的归并排序所用的比较次数和数组访问次数相同，只是顺序不同。

自底向上的归并排序比较适合链表组织的数据。

## 快速排序
原地排序，且将长度为N的数组排序所需时间与NlgN成正比

缺点是非常脆弱

### 基本算法
分治的排序算法。将一个数组分成两个子数组，两部分分别独立地进行排序。
快速排序和归并排序是互补的。

一个数组被分为两部分，当两个子数组都有序时，整个数组就有序了。

方法的关键在于切分，这个过程使得数组满足以下三个条件：
* 对于某个j，a[j]已经排定
* a[lo]到a[j-1]中的所有元素都不大于a[j]
* a[j+1]到a[hi]中的所有元素都不小于a[j]

通过递归地调用切分来排序。因为切分总是能排定一个元素。

```java
    /*****************************************************
     * 快速排序方法
     *****************************************************/
    public static void quickSort(int a[]) {
        quickSort(a, 0, a.length - 1);
    }

    private static void quickSort(int a[], int lo, int hi) {
        if (hi <= lo) return;
        int j = partition(a, lo, hi); // 通过递归地调用切分来排序
        quickSort(a, lo, j - 1);      // 递归后优先处理左边的元素
        quickSort(a, j + 1, hi);
    }

    /**
     * 切分方法
     */
    private static int partition(int a[], int lo, int hi) {
        int i = lo;         // 扫描左指针
        int j = hi + 1;     // 右指针
        int v = a[lo];      // 取a[lo]为切分元素
        while (true) {      // 扫描
            while (less(a[++i], v)) if (i == hi) break;
            while (less(v, a[--j])) if (j == lo) break;
            if (i >= j) break;  // 扫描结束条件：i与j相遇主循环退出
            exch(a, i, j);      // 扫描找到左右符合条件的元素，交换位置
        }
        exch(a, lo, j);         // 将切分元素放到正确的位置
        return j;               // 返回切分元素的索引
    }

```
总是把小的移到a[lo]那边去

快速排序Python实现
```python
def _partition_quick(arr, low, high):
    left = low + 1
    right = high
    gap = arr[low]
    while True:
        while arr[left] < gap:
            left += 1
            if left >= high:
                break
        while arr[right] > gap:
            right -= 1
            if right <= low:
                break
        if left >= right:
            break
        t = arr[left]
        arr[left] = arr[right]
        arr[right] = t
        print "quick sorting--(left=%d,right=%d)" % (left, right), arr
    t = arr[low]
    arr[low] = arr[right]
    arr[right] = t
    print "quick sorting--(left=%d,right=%d)" % (left, right), arr
    return right


def _help_quick_sort(arr, low, high):
    if low >= high:
        return
    par = _partition_quick(arr, low, high)
    _help_quick_sort(arr, low, par - 1)
    _help_quick_sort(arr, par + 1, high)


def quick_sort(arr):
    _help_quick_sort(arr, 0, len(arr) - 1)


if __name__ == "__main__":
    arr1 = [3, 2, 8, 4, 1, 5, 2]
    print "arr1=", arr1
    quick_sort(arr1)
    print "arr1=", arr1
```
测试输出：
```
arr1= [3, 2, 8, 4, 1, 5, 2]
quick sorting--(left=2,right=6) [3, 2, 2, 4, 1, 5, 8]
quick sorting--(left=3,right=4) [3, 2, 2, 1, 4, 5, 8]
quick sorting--(left=4,right=3) [1, 2, 2, 3, 4, 5, 8]
quick sorting--(left=1,right=0) [1, 2, 2, 3, 4, 5, 8]
quick sorting--(left=2,right=2) [1, 2, 2, 3, 4, 5, 8]
quick sorting--(left=5,right=4) [1, 2, 2, 3, 4, 5, 8]
quick sorting--(left=6,right=5) [1, 2, 2, 3, 4, 5, 8]
arr1= [1, 2, 2, 3, 4, 5, 8]
```

### 性能特点
快速排序的速度优势在于它的比较次数很少。
快速排序最好的情况是每次都正好能将数组对半分。

命题：将长度为N的无重复数组排序，快速排序平均需要～2NlgN次比较

命题：快速排序最多需要约N^2/2次比较，但随机打乱数组能够预防这种情况。

移动数据的次数少，就会更快

## 优先队列
很多情况下我们会收集一些元素，处理当前键值最大的元素，然后再收集更多的元素，再处理当前键值最大的元素。

应用场景：任务调度，数值计算等等

优先队列最重要的两种操作：删除最大元素和插入元素

考虑这样一种情况，输入多个元素，要从中找出最大的M个元素。输入可能是无穷无尽的。
解决办法，一种是将输入的元素排序，取前M个；但是输入太多了。
另一种办法是将每个新的输入和已知的M个最大元素比较，但除非M较小，否则代价会非常高昂。

### 堆的定义
**当一棵二叉树的每个结点都大于等于它的两个子结点时，它被称为堆有序。**

根结点是堆有序的二叉树中的最大结点。

相应的，在堆有序的二叉树中，每个结点都小于等于它的父结点。从任意结点往上，我们都能得到一列非递减的元素；从任意结点往下，我们都能得到一列非递增的元素。

**定义** 二叉堆是一组能够用堆有序的完全二叉树排序的元素，并在数组中按照层级存储（不使用数组的第一个位置）

**命题** 对于一个含有N个元素的基于堆的优先队列，插入元素操作只需不超过(lgN+1)次比较，删除最大元素的操作不需要超过2lgN次比较


## 应用

- 指针排序：只处理元素的引用而不移动数据本身。
- 稳定性：一个排序算法能够保留数组中重复元素的相对位置。
- 归约指的是为解决某个问题而发明的算法正好可以用来解决另一种问题。
