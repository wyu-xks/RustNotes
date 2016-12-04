---
title: Generate Parentheses
date: 2015-07-14 15:08:13
category: Algorithm
tag: [algorithm]
---


给定一个数字n，生成符合要求的n对括号；这n对括号涵括了所有的情况

Given n pairs of parentheses, write a function to generate all combinations of well-formed parentheses.
For example, given n = 3, a solution set is:
"((()))", "(()())", "(())()", "()(())", "()()()"

使用递归的方法处理。第一次添加的必须是左括弧“(”；然后可以添加左括弧“(”或者右括弧“)”。
变成这样“((”或“()”。递归方法不反回值，只是在满足条件后将字符串添加到结果中。
因此在一次递归中，传递的参数并不影响下一次递归调用。

```java

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
        }// 每次递归进来，根据现有情况，还会分割成不同的情况；先加左括号
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
        List<String> out = output.generateParenthesis(3);
        System.out.println(out.size());
        for (int i = 0; i < out.size(); i++) {
            System.out.println(out.get(i));
        }
    }
}
```

output:

```c
5
((()))
(()())
(())()
()(())
()()()
```
从输出可以看出，最先输出的是左括号最多的。这个和递归条件是相符的。
