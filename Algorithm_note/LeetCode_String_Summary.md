---
title: LeetCode-字符串处理问题小集-Java
date: 2014-05-29 22:37:16
category: Algorithm
tag: [algorithm,LeetCode]
toc: true
---

### 字符串处理
#### 5. Longest Palindromic Substring
Given a string S, find the longest palindromic substring in S. You may assume that the maximum length of S is 1000, and there exists one unique longest palindromic substring.

如果一个字符串从左向右写和从右向左写是一样的,这样的字符串就叫做palindromic string  
没啥头绪，判断回文数还行；但找出来就有点难了  
中间开花法，定一个中心，向两边散开。这个中心是从左到右移动的。需要2个游标

#### 6. ZigZag Conversion
The string "PAYPALISHIRING" is written in a zigzag pattern on a given number of rows like this: (you may want to display this pattern in a fixed font for better legibility)
```
P   A   H   N
A P L S I I G
Y   I   R
```
And then read line by line: "PAHNAPLSIIGYIR"
Write the code that will take a string and make this conversion given a number of rows:
string convert(string text, int nRows);
convert("PAYPALISHIRING", 3) should return "PAHNAPLSIIGYIR".
需求：将所给的字符串以“倒N型”输出，可以指定输出的行数
函数 String convert(String s, int numRows)
例如输入“abcdefghijklnmopqrstuvwxyz”，输出成3行；得到
```
a e i n q u y
bdfhjlmprtvxz
c g k o s w
```

下面是一个5行的例子
String s = "abcdefghijklnmopqrstuvwxyzabcdefghijklnmopqrstuvwxyzabcdefghijklnmopqrstuvwxyz";
```
a___i___q___y___g___o___w___e___n___u
b__hj__pr__xz__fh__mp__vx__df__lm__tv
c_g_k_o_s_w_a_e_i_n_q_u_y_c_g_k_o_s_w
df__lm__tv__bd__jl__rt__zb__hj__pr__xz
e___n___u___c___k___s___a___i___q___y
```
便于观察，用下划线代替空格；可以看到行末是没有空格的;

观察例子：

1.从0开始计数，第0行第0列是“a”；第4行第0列是“e”；把位于斜线的字母称为斜线位

2.完整列之间间隔为3，即5-2；对于3行的例子，间隔为1=3-2;2行的例子，间隔为0=2-2；间隔为numRows-2；

3.首行和尾行没有斜线位；观察编号，得知a到i之间间隔2*numRows-2；令zigSpace=2*numRows-2

4.对于空格数量，第0行字母之间有3个空格；第1行斜线位左边有2个空格，右边0个；
  第2行斜线位左边1个空格，右边1个；第3行斜线位左边0个空格，右边2个；
  这里斜线位字符的位置是： 2*numRows-2 + j - 2*i（其中i为行数，j为该行第几个字符）。

5.最后一列后面不再添加空格，可用游标是否越界来判断

convertOneLine将结果成从左到右读成一行

#### 8. String to Integer (atoi)
Implement atoi to convert a string to an integer.

【函数说明】atoi() 函数会扫描 str 字符串，跳过前面的空白字符（例如空格，tab缩进等），直到遇上数字或正负符号才开始做转换，而再遇到非数字或字符串结束时('\0')才结束转换，并将结果返回。

【返回值】返回转换后的整型数；如果 str 不能转换成 int 或者 str 为空字符串，那么将返回 0。如果超出Integer的范围，将会返回Integer最大值或者最小值。

【处理思路】按照函数说明来一步步处理。首先判断输入是否为null。然后使用trim()函数删掉空格。判断是否有正负号，做一个标记。返回的是整形数，可以使用double来暂存结果。按位来计算出结果。如果遇到非数字字符，则返回当前结果。加上前面的正负号。结果若超出了整形范围，则返回最大或最小值。最后返回处理结果。

#### 10. Regular Expression Matching
Implement regular expression matching with support for '.' and '*'.

'.' Matches any single character.
'*' Matches zero or more of the preceding element.

The matching should cover the entire input string (not partial).

The function prototype should be:
`bool isMatch(const char *s, const char *p)`

Some examples:
```
isMatch("aa","a") → false
isMatch("aa","aa") → true
isMatch("aaa","aa") → false
isMatch("aa", "a*") → true
isMatch("aa", ".*") → true
isMatch("ab", ".*") → true
isMatch("aab", "c*a*b") → true
```

#### 14. Longest Common Prefix
Write a function to find the longest common prefix string amongst an array of strings.
```java
    public static String longestCommonPrefix(String[] strs) {
        if (strs.length == 0) {
            return "";
        }
        String result = strs[0];
        if (result.length() == 0 ) {
            return "";
        }
        for (int i = 0; i < strs.length; i++) {
            if (strs[i].length() == 0) {
                return "";
            }
            int preLen = result.length() > strs[i].length() ?strs[i].length() : result.length() ;
            int j;
            for (j = 0; j < preLen; j++) {
                if (result.charAt(j) != strs[i].charAt(j)) {
                    break;
                }
            }
            result = result.substring(0, j);
        }
        return result;
    }
```

#### 17. Letter Combinations of a Phone Number
Given a digit string, return all possible letter combinations that the number could represent.
A mapping of digit to letters (just like on the telephone buttons) is given below.
Input:Digit string "23"

Output:`["ad", "ae", "af", "bd", "be", "bf", "cd", "ce", "cf"]`

```java
public class LetterCombinationsofaPhoneNumber {
    public static List<String> letterCombinations(String digits) {
         List<String> result = new ArrayList<String>();
         String[] keys = new String[10];
         keys[0] = "";
         keys[1] = "";
         keys[2] = "abc";
         keys[3] = "def";
         keys[4] = "ghi";
         keys[5] = "jkl";
         keys[6] = "mno";
         keys[7] = "pqrs";
         keys[8] = "tuv";
         keys[9] = "wxyz";
         char[] temp = new char[digits.length()];
         combine(keys, temp, digits, 0, result);
         return result;
    }
    public static void combine(String[] keys, char[] temp, String digits, int index, List<String> res) {
        if (index == digits.length()) {
            res.add(new String(temp));
            return;  // get out now
        }
        char digitChar = digits.charAt(index);
        for (int i = 0; i < keys[digitChar - '0'].length(); i++) {  // scan char at keys[digitChar - '0']
            temp[index] = keys[digitChar - '0'].charAt(i);
            combine(keys, temp, digits, index + 1, res);
        }
    }
```

#### 22. Generate Parentheses

Given n pairs of parentheses, write a function to generate all combinations of well-formed parentheses.

For example, given n = 3, a solution set is:

```
"((()))", "(()())", "(())()", "()(())", "()()()"
```

使用递归的方法处理。第一次添加的必须是左括弧；然后可以添加左括弧或者右括弧。

变成这样`((`或`()`。递归方法不反回值，只是在满足条件后将字符串添加到结果中。

因此在一次递归中，传递的参数并不影响下一次递归调用。

```java
package com.rust.TestString;
import java.util.ArrayList;
import java.util.List;
class solution {
    List<String> res = new ArrayList<String>();
    public List<String> generateParenthesis(int n) {
        if (n == 0) {
            res.add("");
            return res;
        }
        addBrackets("", 0, 0, n);//这个递归并没有返回的条件，跑到完为止
        return res;
    }
    public void addBrackets(String str,int leftB,int rightB,int n) {
        if (leftB == n && rightB == n) {
            res.add(str);
        }// 每次递归进来，根据现有情况，还会分割成不同的情况
        if (leftB < n) {
            addBrackets(str + "(", leftB + 1, rightB, n);
        }
        if (rightB < leftB) {
            addBrackets(str + ")", leftB, rightB + 1, n);
        }
    }
}
public class GenerateParentheses {
    public static void main(String args[]){
        solution output = new solution();
        List<String> out = output.generateParenthesis(3);
        System.out.println(out.size());
        for (int i = 0; i < out.size(); i++) {
            System.out.println(out.get(i));
        }
    }
}
```

#### 30. Substring with Concatenation of All Words
You are given a string, s, and a list of words, words, that are all of the same length.
Find all starting indices of substring(s) in s that is a concatenation of each word in words exactly once and without any intervening characters.
For example, given:

s: "barfoothefoobarman"

words: ["foo", "bar"]

You should return the indices: [0,9].
(order does not matter).

搜索满足连续条件的字符串，返回下标。

#### 31. Next Permutation
Implement next permutation(n.置换；排列), which rearranges numbers into the lexicographically(顺序) next greater permutation of numbers.
If such arrangement is not possible, it must rearrange it as the lowest possible order (ie, sorted in ascending order).
The replacement must be in-place, do not allocate extra memory.
Here are some examples. Inputs are in the left-hand column and its corresponding outputs are in the right-hand column.
1,2,3 → 1,3,2
3,2,1 → 1,2,3
1,1,5 → 1,5,1

大致分三个步骤：
(1)从右[len-1]往左[i]遍历，找到nums[i] > num[i-1]；如没有，即i==0,则num为从大到小排列的数组，此时的下一个排列，为所有元素从小到大的排列；
(2)找到[nums[i], nums[len-1]]闭区间中比nums[i-1]大的最小数nums[minIndex]，交换nums[minIndex]和nums[i-1]；注：因为肯定有nums[i] > nums[i-1]，所以minIndex从i开始；
(3)对新的[nums[i], nums[len-1]]，从小到大排序。

#### 32. Longest Valid Parentheses
Given a string containing just the characters '(' and ')', find the length of the longest valid
(well-formed) parentheses substring.
For "(()", the longest valid parentheses substring is "()", which has length = 2.
Example ")()())", where the longest valid parentheses substring is "()()", which has length = 4.
分成2个步骤；第一次遍历找出合法的括号串，并标记在一个boolean数组中；第二步去遍历boolean数组，找出最长的合法记录。
```java
    public static int longestValidParentheses(String s) {
        boolean[] position = new boolean[s.length()];
        Stack<Integer> stack = new Stack<>();
        for (int i = 0; i < s.length(); i++) {
            if (s.charAt(i) == '(') {
                stack.push(i);
            } else if (s.charAt(i) == ')' && !stack.isEmpty()) {
                position[i] = true;
                position[stack.pop()] = true;
            }
        }
        int longest = 0;
        int currentLength = 0;
        for (int i = 0; i < s.length(); i++) {
            if (position[i]) currentLength++;
            else currentLength = 0;
            longest = Math.max(longest, currentLength);
        }
        return longest;
    }
```

#### 38. Count and Say
The count-and-say sequence is the sequence of integers beginning as follows:
1, 11, 21, 1211, 111221, ...

1 is read off as "one 1" or 11.
11 is read off as "two 1s" or 21.
21 is read off as "one 2, then one 1" or 1211.
Given an integer n, generate the nth sequence.
第一个读作“1”；第二个是第一个的读音“11”；第三个是第二个的读音“二个一”，“21”；以此类推

#### 39. Combination Sum
Given a set of candidate numbers (C) and a target number (T), find all unique combinations in C
where the candidate numbers sums to T.
The same repeated number may be chosen from C unlimited number of times.

Note:
All numbers (including target) will be positive integers.
Elements in a combination (a1, a2, … , ak) must be in non-descending order. (ie, a1 ≤ a2 ≤ … ≤ ak).
The solution set must not contain duplicate combinations.
For example, given candidate set 2,3,6,7 and target 7,
A solution set is:
[7]
[2, 2, 3]

```java
    public static List<List<Integer>> combinationSum(int[] candidates, int target) {
        List<List<Integer>> res = new ArrayList<>();
        List<Integer> temp = new ArrayList<>();
        Arrays.sort(candidates);
        sum39(candidates, target, 0, 0, temp, res);
        return res;
    }

    public static void sum39(int[] candidates, int target, int sum, int level,
                             List<Integer> temp, List<List<Integer>> res) {
        if (sum == target) {
            res.add(new ArrayList<>(temp));
        } else if (sum > target) {
            return;
        } else {
            for (int i = level; i < candidates.length; i++) {
                temp.add(candidates[i]);
                sum39(candidates, target, sum + candidates[i], i, temp, res);// 同一个数字也可叠加
                temp.remove(temp.size() - 1);// 删掉最后加入的一个数字
            }
        }
    }
```
假设输入：`int[]{2, 3, 5}, 7`
上面解法的过程是：
```
2, → 2,2, → 2,2,2, → 2,2,2,2, → (sum > target)
2,2,2,3, → (sum > target)
2,2,2,5, → (sum > target)
2,2,3, → (solution)
2,2,5, → (sum > target)
2,3, → 2,3,3, → (sum > target)
2,3,5, → (sum > target)
2,5, → (solution)
3, → 3,3, → 3,3,3, → (sum > target)
3,3,5, → (sum > target)
3,5, → (sum > target)
5, → 5,5, → (sum > target)
```

#### 40. Combination Sum II
Each number in C may only be used once in the combination.
输入数组是未排序的，其他要求和第39题一样
For example, given candidate set 10,1,2,7,6,1,5 and target 8,
A solution set is:
[1, 7]
[1, 2, 5]
[2, 6]
[1, 1, 6]
下面是一个比较快的解法，基本思路和第39题的一样
```java
    public static List<List<Integer>> combinationSum2(int[] candidates, int target) {
        List<List<Integer>> rst = new ArrayList<>();
        if (candidates == null || candidates.length == 0) {
            return rst;
        }
        Arrays.sort(candidates);
        sum40Helper(rst, new ArrayList<Integer>(), 0, candidates, target, 0);
        return rst;
    }

    public static void sum40Helper(List<List<Integer>> rst, List<Integer> path,
                                   int sum, int[] candidates, int target, int pos) {
        if (sum == target) {
            rst.add(new ArrayList<>(path));
            return;
        }
        for (int i = pos; i < candidates.length; i++) {
            if (sum + candidates[i] > target) break;
            if (i != pos && candidates[i] == candidates[i - 1]) continue;// 跳过重复数字
            path.add(candidates[i]);
            sum40Helper(rst, path, sum + candidates[i], candidates, target, i + 1);
            path.remove(path.size() - 1);
        }
    }
```

#### 65. Valid Number
Validate if a given string is numeric.
Some examples:
```
"0" => true
" 0.1 " => true
"abc" => false
"1 a" => false
"2e10" => true
```
>Note: It is intended for the problem statement to be ambiguous. You should gather all requirements up front before implementing one.

#### 76. Minimum Window
Given a string S and a string T, find the minimum window in S which will contain all the characters in T in complexity O(n).

For example,
```
S = "ADOBECODEBANC"
T = "ABC"
Minimum window is "BANC".
```
>Note:If there is no such window in S that covers all characters in T, return the empty string "".
If there are multiple such windows, you are guaranteed that there will always be only one unique minimum window in S.

找最小的窗口。方法是2下标。先移动右下标找到所有的目标，再移动左下标到不能动为止。再移动右下标，再移动左下标。移动下标的规则就是，保证窗口里有所有的目标字符。

#### 77. Combinations
Given two integers n and k, return all possible combinations of k numbers out of 1 ... n.

For example,

If n = 4 and k = 2, a solution is:
```
[
  [2,4],
  [3,4],
  [2,3],
  [1,2],
  [1,3],
  [1,4],
]
```
也就是求C(n, k)，从1到n这些数字中取出k个，一共有多少种方案。
回溯法递归。

#### 79. Word Search
Given a 2D board and a word, find if the word exists in the grid.
The word can be constructed from letters of sequentially adjacent cell, where "adjacent" cells are those horizontally or vertically neighboring. The same letter cell may not be used more than once.

For example,

Given board =
```
[
  ['A','B','C','E'],
  ['S','F','C','S'],
  ['A','D','E','E']
]
```
word = "ABCCED", -> returns true,
word = "SEE", -> returns true,
word = "ABCB", -> returns false.

给一张2维字符表，给定字符串。字符串中各个字符要满足表中的路线，不能重复走某一点。

用Depth-First-Search优先深度搜索法寻找某点的4个临近点。

#### 125. Valid Palindrome
Given a string, determine if it is a palindrome, considering only alphanumeric characters and ignoring cases.
For example,
"A man, a plan, a canal: Panama" is a palindrome.
"race a car" is not a palindrome.
Note:Have you consider that the string might be empty? This is a good question to ask during an interview.
For the purpose of this problem, we define empty string as valid palindrome.
判断字符串是否符合回文要求。忽略掉所有的标点符号和空格。设立左右2个游标来遍历。
当输入为空字符串""，返回true。

#### 242. Valid Anagram
Given two strings s and t, write a function to determine if t is an anagram of s.
For example,
s = "anagram", t = "nagaram", return true.
s = "rat", t = "car", return false.
Note: You may assume the string contains only lowercase alphabets.
Follow up:
What if the inputs contain unicode characters? How would you adapt your solution to such case?
判断两个字符串是否含有相同个数和种类的字母。
遍历两个字符串，将字符串中的字母按26个字母顺序为序号存入map中。最后遍历map。

#### 301. Remove Invalid Parentheses
Remove the minimum number of invalid parentheses in order to make the input string valid. Return all possible results.
Note: The input string may contain letters other than the parentheses ( and ).
Examples:
"()())()" -> ["()()()", "(())()"]
"(a)())()" -> ["(a)()()", "(a())()"]
")(" -> [""]
删除错误的括号。需要判断括号是否正确的方法。
LeetCode上讨论区有一个解法很快：

```java
    public List<String> removeInvalidParenthesesFaster(String s) {
        List<String> ans = new ArrayList<>();
        remove(s, ans, 0, 0, new char[]{'(', ')'});
        return ans;
    }

    public void remove(String s, List<String> ans, int last_i, int last_j,  char[] par) {
        int stack = 0, i;
        for (i = last_i; i < s.length(); ++i) {
            if (s.charAt(i) == par[0]) stack++;
            if (s.charAt(i) == par[1]) stack--;
            if (stack < 0) {
                for (int j = last_j; j <= i; ++j) {
                    if (s.charAt(j) == par[1] && (j == last_j || s.charAt(j - 1) != par[1]))
                        remove(s.substring(0, j) + s.substring(j + 1, s.length()), ans, i, j, par);
                }
                return;
            }
        }
        String reversed = new StringBuilder(s).reverse().toString();
        if (par[0] == '(')
            remove(reversed, ans, 0, 0, new char[]{')', '('});
        else
            ans.add(reversed);
    }
```
这个方法用计数器记录括号是否对称。当右括号多了一个，在0到当前位置这个区间，遍历找出可删除的右括号。
找到后把字符串反转一下，再递归一次。输入的括号顺序反转为{')', '('}。反转后的字符串检查通过后，再反转回来。
但此时par是{')', '('}，直接将字符串添加进ans中。
得到一个符号条件的字符串后，原来的循环继续检查。

#### 273. Integer to English Words

Convert a non-negative integer to its english words representation.   
Given input is guaranteed to be less than 231 - 1.

For example,

123 -> "One Hundred Twenty Three"

12345 -> "Twelve Thousand Three Hundred Forty Five"

1234567 -> "One Million Two Hundred Thirty Four Thousand Five Hundred Sixty Seven"

http://www.cnblogs.com/rustfisher/p/4784156.html

观察数字2 147 483 647，可以看出由4段组成；每段都是0到999的数字
尝试将数字分段处理；截取每段数字，写专门的函数处理0~999的数字；最后将它们连接起来
编制String数组存放需要的数字；需要时从数组中取用
