---
title: Java Math
date: 2017-05-10 21:57:02
category: Java_note
tag: [Java]
---

Java中关于数值的一些问题

### Math.round()的进位问题
`Math.round()`函数对于正数和负数有不同的效果  
对于正数是四舍五入，对于负数是“五舍六入”

```
Math.round(9.4):9, Math.round(9.5):10, Math.round(9.6):10
Math.round(-9.4):-9, Math.round(-9.5):-9, Math.round(-9.6):-10
```

### 移位操作符示例
Java 右移操作符`>>`和`>>>`
* `>>`  右移，按原来数字最高位来补充
* `>>>` 右移，补零

```java
    private static void testFunc(int num) {
        int m2Bit = num >> 2;
        int m3Bit = num >>> 2;
        System.out.println("input: " + num + ", 0x" + Integer.toHexString(num));
        System.out.println(num + " >> 2   ==  " + m2Bit + ", 0x" + Integer.toHexString(m2Bit));
        System.out.println(num + " >>> 2  ==  " + m3Bit + ", 0x" + Integer.toHexString(m3Bit));
    }

/* output
input: 20, 0x14
20 >> 2   ==  5, 0x5
20 >>> 2  ==  5, 0x5
input: 5, 0x5
5 >> 2   ==  1, 0x1
5 >>> 2  ==  1, 0x1
input: -20, 0xffffffec
-20 >> 2   ==  -5, 0xfffffffb
-20 >>> 2  ==  1073741819, 0x3ffffffb
input: -5, 0xfffffffb
-5 >> 2   ==  -2, 0xfffffffe
-5 >>> 2  ==  1073741822, 0x3ffffffe
*/
```
