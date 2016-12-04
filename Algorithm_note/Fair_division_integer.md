---
title: N个正整数尽量分成K组，使每组数字的和尽量接近
date: 2017-05-26 21:31:31
category: Algorithm
tag: [algorithm]
---

问题描述：  
* 数组元素均为正整数
* 把 N 个数尽量分成 K 组，使每组数字的和尽量接近
* 分组不需要保护数组元素的原始顺序
* “尽量接近”的精确定义：最小化 max(sum(Mi)) Mi 是得到的 K 个分组
* A group of N integer numbers need to be divided fairly into K subgroups.
* A fair division is that the max of the sums of K subgroups is minimal

解决思路：  
* 对输入数组进行排序，这里是从小到大排
* 用最大的K个来初始化分组的集合，得到K个集合，每个集合中有一个数字
* 从大到小遍历剩下的数字；每次遍历中，把当前数与分组之和相加，找出结果最小的那个分组，将当前数加入那个分组

对特殊情况进行了处理  
Java代码示例：
```java
private static List<ArrayList<Integer>> fairDivision(int[] input, int k) {
        ArrayList<ArrayList<Integer>> resultList = new ArrayList<>(k);
        if (k > input.length || k < 0) {
            return resultList;
        } else if (k == input.length) {
            for (int c : input) {
                ArrayList<Integer> t = new ArrayList<>();
                t.add(c);
                resultList.add(t);
            }
            return resultList;
        }

        for (int i = 0; i < k; i++) {
            resultList.add(new ArrayList<>());
        }

        int[] sortedInput = input.clone();
        int inputLen = sortedInput.length;
        Arrays.sort(sortedInput);

        // 从最大的开始填充到结果中
        for (int i = 0; i < k; i++) {
            resultList.get(i).add(sortedInput[inputLen - 1 - i]);
        }
        // 从大到小遍历剩下的数字
        for (int i = inputLen - 1 - k; i >= 0; i--) {
            ArrayList<Integer> tempSum = new ArrayList<>(k);
            for (List<Integer> l : resultList) {
                tempSum.add(getSum(l) + sortedInput[i]);
            }
            int minIndex = findMinIndex(tempSum); // 找出结果最小的那个分组
            resultList.get(minIndex).add(sortedInput[i]); // 将当前数加入那个分组
        }

        return resultList;
    }

    /**
     * @return The index of the min member
     */
    private static int findMinIndex(ArrayList<Integer> list) {
        int res = 0;
        int t = Integer.MAX_VALUE;
        for (int index = 0; index < list.size(); index++) {
            if (list.get(index) < t) {
                t = list.get(index);
                res = index;
            }
        }
        return res;
    }

    /**
     * @return Sum of list members
     */
    private static int getSum(List<Integer> list) {
        int res = 0;
        for (int i : list) {
            res += i;
        }
        return res;
    }
```

Java代码示例测试结果：
```java
private static void testAndPrint(int[] input, int k) {
    System.out.print(Arrays.toString(input) + " --> ");
    for (List r : fairDivision(input, k)) {
        System.out.print(r);
    }
    System.out.println("; k=" + k);
}

public static void main(String[] args) {
    int[] input1 = {6, 1, 6, 1, 2, 5};
    int[] input2 = {9, 2, 1};
    int[] input3 = {9, 2};
    int[] input4 = {19, 2, 6, 9, 2, 4, 7, 10};

    testAndPrint(input4, 3);
    testAndPrint(input4, 4);
    testAndPrint(input4, 5);
    testAndPrint(input1, 6);
    testAndPrint(input1, 5);
    testAndPrint(input1, 3);
    testAndPrint(input1, 2);
    testAndPrint(input2, 2);
    testAndPrint(input3, 2);
    testAndPrint(input3, 1);
}

/* output
[19, 2, 6, 9, 2, 4, 7, 10] --> [19][10, 6, 4][9, 7, 2, 2]; k=3
[19, 2, 6, 9, 2, 4, 7, 10] --> [19][10, 2, 2][9, 4][7, 6]; k=4
[19, 2, 6, 9, 2, 4, 7, 10] --> [19][10][9, 2][7, 2][6, 4]; k=5
[6, 1, 6, 1, 2, 5] --> [6][1][6][1][2][5]; k=6
[6, 1, 6, 1, 2, 5] --> [6][6][5][2][1, 1]; k=5
[6, 1, 6, 1, 2, 5] --> [6, 1][6, 1][5, 2]; k=3
[6, 1, 6, 1, 2, 5] --> [6, 5][6, 2, 1, 1]; k=2
[9, 2, 1] --> [9][2, 1]; k=2
[9, 2] --> [9][2]; k=2
[9, 2] --> [9, 2]; k=1
*/
```
