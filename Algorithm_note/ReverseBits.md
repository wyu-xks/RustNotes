---
title: 按位反转一个int型数字
date: 2015-08-24 15:08:15
category: Algorithm
tag: [algorithm]
---


Reverse bits of a given 32 bits unsigned integer.  
For example, given input 43261596 (represented in binary as 00000010100101000001111010011100),

return 964176192 (represented in binary as00111001011110000010100101000000).

把一个无符号int数字，按二进制位反转过来

通过移位操作，一位一位来处理。目的是反转，所以先处理最右位。最右位（末端）一个一个地往result的左边推

```java

package com.rust.cal;

public class ReverseBits {

   public static void main(String args[]) {
       System.out.print(solution(43261596));

   }

   // &：当两边操作数的位同时为1时，结果为1，否则为0。如1100&1010=1000
   // 按位反转一个int
   private static int solution(int input) {
       int result = 0;
       for (int i = 0; i < 32; i++) {      // 一共32位
           if (((input >> i) & 1) == 1) {  // 如果移位后最右位为1
               int j = 31 - i;             // 判断当前是第几位，并换算成反转后的位数
               result |= 1 << j;           // 得知是反转后第几位，存入结果result中
           }
       }
       return result;
   }
}
```

输出：
```c
964176192
```
