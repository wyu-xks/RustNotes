---
title: Boyer–Moore majority vote algorithm
date: 2016-07-02 11:25:43
category: Algorithm
tag: [algorithm]
---
多数投票算法
找出数组中出现次数占总个数一半以上的元素。
```java
public class MajorityVote {
    public int majorityElement(int[] num) {
        int n = num.length;
        // 1.遍历数组，找出可能符合条件的元素
        // 如果有元素满足条件，那么会被存在 candidate 中
        int candidate = num[0], counter = 0;
        for (int i : num) {
            if (counter == 0) {
                candidate = i;
                counter = 1;
            } else if (candidate == i) {
                counter++;
            } else {
                counter--;
            }
        }

        // 2.检查确定此元素确实占了一半以上
        counter = 0;
        for (int i : num) {
            if (i == candidate) counter++;
        }
        if (counter < (n + 1) / 2) return -1;
        return candidate;

    }

    public static void main(String[] args) {
        MajorityVote s = new MajorityVote();
        System.out.format("%d\n", s.majorityElement(new int[]{4, 2, 3, 4, 77, 4, 7, 4, 4}));
        System.out.format("%d\n", s.majorityElement(new int[]{2, 2, 3}));
    }
}
```
