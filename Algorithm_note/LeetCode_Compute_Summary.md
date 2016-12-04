---
title: LeetCode-计算问题小集
date: 2014-05-29 22:29:16
category: Algorithm
tag: [algorithm,LeetCode]
---


```
1. Two Sum
7. Reverse Integer
15. 3Sum
16. 3Sum Closest
18. 4Sum
36. Valid Sudoku
136. Single Number
137. Single Number II
149. Max Points on a Line
258. Add Digits
263. Ugly Number
264. Ugly Number II
```

#### 1. Two Sum
```
Given an array of integers, return indices of the two numbers such that they add up to a specific target.
You may assume that each input would have exactly one solution, and you may not use the same element twice.

Example:
Given nums = [2, 7, 11, 15], target = 9,
Because nums[0] + nums[1] = 2 + 7 = 9,
return [0, 1].
```

思路1，时间复杂度O(1)的方法，用空间换时间。将下标存进HashTable中，索引是当前数值与target的差值

Python实现
```python
    def twoSum(self, nums, target):
        """
        :type nums: List[int]
        :type target: int
        :rtype: List[int]
        """
        if len(nums) < 2:
            return False
        index_dict = dict()
        for i in range(len(nums)):
            if nums[i] in index_dict:
                return [index_dict[nums[i]], i]
            else:
                index_dict[target - nums[i]] = i
```

思路2，时间O(n^2)的方法，使用双游标遍历数组。

#### 7. Reverse Integer
Reverse digits of an integer.
Example1: x = 123, return 321
Example2: x = -123, return -321

Have you thought about this?
Here are some good questions to ask before coding. Bonus points for you if you have already thought through this!
If the integer's last digit is 0, what should the output be? ie, cases such as 10, 100.
Did you notice that the reversed integer might overflow? Assume the input is a 32-bit integer, then the reverse of 1000000003 overflows. How should you handle such cases?
For the purpose of this problem, assume that your function returns 0 when the reversed integer overflows.
```java
    public static int reverseInt(int input){
        if (input == 0) {
            return 0;
        }
        int flag = -1;
        int result = 0;
        if (input < 0) {
            input = input * flag;
            if (input < 0) {
                return 0;
            }
        } else {
            flag = 1;
        }
        int digits = 1;
        int temp = input;
        while(temp/10 != 0){
            digits++;
            temp/=10;
        }
        //judge before calculate at every may out of range place
        for (int i = 1; i <= digits; i++) {
            int a,b;
            a = (int) (input/Math.pow(10, i-1));
            a = a%10;//get the single number
            b = (int) Math.pow(10, digits-i);
            if ((a*b<0)) {//use number to judge
                return 0;
            } else {
                temp = a*b;
            }
            if (result + temp < 0) {//judge
                return 0;
            } else {
                result += temp;
            }
        }
        return result*flag;
    }
```
#### 15. 3Sum
Given an array S of n integers, are there elements a, b, c in S such that a + b + c = 0?
Find all unique triplets in the array which gives the sum of zero.
Note: Elements in a triplet (a,b,c) must be in non-descending order. (ie, a ≤ b ≤ c)
The solution set must not contain duplicate triplets.
    For example, given array S = {-1 0 1 2 -1 -4},
    A solution set is:
    (-1, 0, 1)
    (-1, -1, 2)

先排序，定点从左到右走。每一个定点只考虑它右边的数字。右边收缩寻找。结果要求从小到大排好数字
```java
    public static List<List<Integer>> threeSum(int[] nums) {
        List<List<Integer>> res = new ArrayList<List<Integer>>();
        if (nums.length < 3) {
            return res;
        }
        Arrays.sort(nums);
        int len = nums.length;
        for (int i = 0; i < len - 2; i++) {
            if (i > 0 && nums[i] == nums[i-1]) continue;//skip this loop
            int l = i + 1;
            int r = len - 1;
            while (l < r) {
                List<Integer> singleAns = new ArrayList<Integer>();
                int sum = nums[l] + nums[r] + nums[i];
                if (sum == 0) {
                    singleAns.add(nums[l]);
                    singleAns.add(nums[r]);
                    singleAns.add(nums[i]);
                    res.add(singleAns);
                    while (l < r && nums[l] == nums[l+1]) l++;  //look forward
                    while (l < r && nums[r] == nums[r-1]) r--;   //skip the same number in nums[]
                    l++;
                    r--;
                } else if (sum > 0) {
                    r--;
                } else {
                    l++;
                }
            }
        }
        return res;
    }
```

#### 16. 3Sum Closest
Given an array S of n integers, find three integers in S such that the sum is closest to a given
number, target. Return the sum of the three integers.
You may assume that each input would have exactly one solution.
    For example, given array S = {-1 2 1 -4}, and target = 1.
    The sum that is closest to the target is 2. (-1 + 2 + 1 = 2).
```java
    public static int threeSumClosest(int[] nums, int target) {
        if (nums.length < 3) {
            return -1;
        }
        int closest = Math.abs(nums[0] + nums[1] + nums[2] - target);//find distance
        Arrays.sort(nums);
        int len = nums.length;
        int res = 0;//nums[0] + nums[1] + nums[2];
        for (int i = 0; i < len-2; i++) {
            if (i > 0 && nums[i] == nums[i-1]) continue;//skip this loop
            int l = i + 1;
            int r = len - 1;
            while (l < r) {
                int sum = nums[l] + nums[r] + nums[i];
                if (closest >= Math.abs(sum-target)) {
                    closest = Math.abs(sum-target);
                    res = sum;
                }
                if (sum == target) {
                    return sum;
                } else if (sum - target > 0) {
                    r--;
                } else {
                    l++;
                }
            }
        }
        return res;
    }
```

#### 18. 4Sum
Given an array S of n integers, are there elements a, b, c, and d in S such that
a + b + c + d = target? Find all unique quadruplets in the array which gives the sum of target.
Note:
Elements in a quadruplet (a,b,c,d) must be in non-descending order. (ie, a ≤ b ≤ c ≤ d)
The solution set must not contain duplicate quadruplets.
For example, given array S = {1 0 -1 0 -2 2}, and target = 0.
A solution set is:
    (-1,  0, 0, 1)
    (-2, -1, 1, 2)
    (-2,  0, 0, 2)

遍历方法是个问题；定好左右两个游标，中间两个游标移动。
```java
    public static List<List<Integer>> fourSum(int[] nums, int target) {
        List<List<Integer>> res = new ArrayList<List<Integer>>();
        Arrays.sort(nums);
        int len = nums.length;
        for (int i = 0; i < len - 3; i++) {
            if (i > 0 && nums[i] == nums[i-1])    continue;
            for (int j = len - 1; j > i + 2; j--) {
                if (j < len - 1 && nums[j] == nums[j+1])    continue;
                int side = nums[i] + nums[j];
                int left = i + 1;
                int right = j - 1;
                while (left < right) {
                    int inner = nums[left] + nums[right];
                    if (side + inner == target) {
                        List<Integer> singleAns = new ArrayList<Integer>();
                        singleAns.add(nums[i]);
                        singleAns.add(nums[left]);
                        singleAns.add(nums[right]);
                        singleAns.add(nums[j]);
                        res.add(singleAns);
                        while (left < right && nums[left] == nums[left+1]) left++;  //look forward
                        while (left < right && nums[right] == nums[right-1]) right--;
                              //skip the same number in nums[]
                        left++;
                        right--;
                    } else if (inner + side > target){
                        right--;
                    } else {
                        left++;
                    }
                }
            }
        }
        return res;
    }
```

#### 36. Valid Sudoku
Determine if a Sudoku is valid, according to:[ Sudoku Puzzles - The Rules.](http://sudoku.com.au/TheRules.aspx)
The Sudoku board could be partially filled, where empty cells are filled with the character '.'.
这是一个9*9的数独。需要判定9个宫是否满足条件。
下面的方法只需一次遍历
自己第一次用HashSet来存储遍历到的数字，效果太差。这里使用二进制的位来保存数据。比如读到‘1’，保存是‘1’；又读到3，保存是‘101’
二进制保存结果，用移位来实现。用按位与来判断是否重复。
9个宫的处理方式：遍历是从左到右，从上到下。通过一个坐标转换方法来存储每个宫的数字`board[i / 3 * 3 + j / 3][i % 3 * 3 + j % 3]`
```java
    /*
     * 36. Valid Sudoku -- faster!!!
     * From: https://leetcode.com/discuss/80526/my-one-pass-o-1-space-solution-using-java
     */
    public boolean isValidSudoku(char[][] board) {
        // precondition: board is not null
        if (board == null) {
            throw new NullPointerException();
        }

        for (int i = 0; i < 9; i++) {
            int row = 0;
            int col = 0;
            int block = 0;
            for (int j = 0; j < 9; j++) {
                int rowVal = board[i][j] - '1';// '1' got 0, check if number
                int colVal = board[j][i] - '1';
                int blockVal = board[i / 3 * 3 + j / 3][i % 3 * 3 + j % 3] - '1';// calculate rooms index
                if (rowVal >= 0 && (row & (1 << rowVal)) != 0/* is number && never exist before */
                        || colVal >= 0 && (col & (1 << colVal)) != 0
                        || blockVal >= 0 && (block & (1 << blockVal)) != 0) {
                    return false;
                }
                row |= rowVal >= 0 ? 1 << rowVal : 0;// it's a bit-map to save exists numbers, '2' and '3' means 110
                col |= colVal >= 0 ? 1 << colVal : 0;
                block |= blockVal >= 0 ? 1 << blockVal : 0;
            }
        }
        return true;
    }
```

#### 136. Single Number
```
Given an array of integers, every element appears twice except for one. Find that single one.

Note:
Your algorithm should have a linear runtime complexity. Could you implement it without using extra memory?
```

思路1，亦或运算

Python实现
```python
    def singleNumber(self, nums):
        """
        :type nums: List[int]
        :rtype: int
        """
        res = 0
        for i in nums:
            res = res ^ i
        return res
```

#### 137. Single Number II
```
Given an array of integers, every element appears three times except for one, which appears exactly once. Find that single one.

Note:
Your algorithm should have a linear runtime complexity. Could you implement it without using extra memory?
```

别的数字出现3次。找出只出现了1次的那个数字。

Python代码
```python
    def singleNumber2(self, nums):
        """
        :type nums: List[int]
        :rtype: int
        """
        ones = 0
        twos = 0
        for i in nums:
            ones = (ones ^ i) & ~twos
            twos = (twos ^ i) & ~ones
        return ones
```

这类问题的通用解法。
https://discuss.leetcode.com/topic/22821/an-general-way-to-handle-all-this-sort-of-questions
```python
    def single_number(self, nums):
        """
        数组中找只出现一次的数字的通用解法
        :type nums: List[int]
        :rtype: int
        """
        a = 0
        b = 0
        for c in nums:
            ta = (~a & b & c) | (a & ~b & ~c)
            b = (~a & ~b & c) | (~a & b & ~c)
            a = ta
        return a | b

```

#### 149. Max Points on a Line
输入一组点，找出最多有多少个点共线。重复点也算进去。
按点遍历。先确定一个点a，遍历后面的点b；在a与b之间寻找，然后在b后面寻找。
利用斜率相等来判断是否在同一条直线上。计算斜率时，换算为乘法，可以避免分母为0的情况。
```java
    public static int maxPoints(Point[] points) {
        if (points.length < 3) {
            return points.length;
        }
        int max = 0;
        for (int a = 0; a < points.length - 2; a++) {
            boolean[] checked = new boolean[points.length];
            for (int b = a + 1; b < points.length; b++) {
                if (checked[b]) continue;// Do not check the same line

                // The point-b should differ from point-a
                while (b < points.length && points[b].x == points[a].x && points[b].y == points[a].y) {
                    b++;
                }

                // Count all points between point-a and point-b
                // witch have the same coordinates as point-a
                int count = b == points.length ? 1 : 2;
                for (int i = a + 1; i < b; i++) {
                    if (points[i].x == points[a].x && points[i].y == points[a].y) {
                        count++;
                    }
                }

                // Count point-c if it lies on the point-a-point-b-line.
                for (int c = b + 1; c < points.length; c++) {
                    if (isOnLine(points[a], points[b], points[c])) {
                        count++;
                        checked[c] = true;
                    }
                }

                if (count > max) {
                    max = count;
                }
            }
        }
        return max;
    }

    // Calculate the slope. If c is same to a, return true
    private static boolean isOnLine(Point a, Point b, Point c) {
        return (b.y - a.y) * (c.x - a.x) == (c.y - a.y) * (b.x - a.x);
    }
```

#### 258. Add Digits
Given a non-negative integer num, repeatedly add all its digits until the result has only one digit.
For example:
Given num = 38, the process is like: 3 + 8 = 11, 1 + 1 = 2. Since 2 has only one digit, return it.
Follow up:
Could you do it without any loop/recursion in O(1) runtime?
```java
    public static int addOnce(int n) {
        int result = 0;
        while (n != 0) {
            result += n%10;
            n = n/10;
        }
        return result;
    }

    public static int addDigits(int num) {
        int res = 0;
        res = addOnce(num);
        while (res > 9) {
            res = addOnce(res);
        }
        return res;
    }
```

#### 263. Ugly Number
Write a program to check whether a given number is an ugly number.
Ugly numbers are positive numbers whose prime factors only include 2, 3, 5.
For example, 6, 8 are ugly while 14 is not ugly since it includes another prime factor 7.
Note that 1 is typically treated as an ugly number.

#### 264. Ugly Number II
Write a program to find the n-th ugly number.
Ugly numbers are positive numbers whose prime factors only include 2, 3, 5.
For example, 1, 2, 3, 4, 5, 6, 8, 9, 10, 12 is the sequence of the first 10 ugly numbers.
Note that 1 is typically treated as an ugly number

```java
    public static boolean hasDigit(double d){
        return  d*10%10 != 0;
    }
    public static boolean isUgly(int num) {
        if (num <= 0) {
            return false;
        }
        if (num == 1) {
            return true;
        }
        if (!hasDigit(num/2.0)) {
            if (isUgly(num/2)) {
                return true;
            }
        }
        if (!hasDigit(num/3.0)) {
            if (isUgly(num/3)) {
                return true;
            }
        }
        if (!hasDigit(num/5.0)) {
            if (isUgly(num/5)) {
                return true;
            }
        }

        return false;
    }
    public static int nthUglyNumber(int n) {
        if (n <= 0) {
            return -1;
        }
        int count = 0;
        int i = 0;
        while (count <= n){
            if (isUgly(i)) {
                count++;
            }
            if (count == n) {
                break;
            }
            i++;

        }
        return i;
    }
```
