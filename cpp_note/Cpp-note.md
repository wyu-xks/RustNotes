---
title: C++ primer note
date: 2016-12-15 19:36:20
category: Cpp_note
tag: [C++]
---

*C++ Primer* 第五版

## 基础

命名空间    `namespace`

作用域运算符  `::`  ; 例如`std::cout`

如果一条表达式中已经有了size()函数就不要再使用int了，这样可以避免混用int和unsigned
可能带来的问题。

### string对象上的操作

标准输入的内容读取时，string对象会自动忽略空白的开头（即空格符、换行符、
制表符等）并从第一个真正的字符开始读起，直到遇见下一处空白为止。

getline函数的参数是一个输入流和一个string对象，函数从给定的输入流中读入
内容，直到遇到换行符（并不保存换行符）为止。getline只要一遇到换行符就结束
读取操作并返回结果，哪怕输入的一开始就是换行符。如果输入一开始就是换行符，
那么所得结果是个空的string。

字符串字面值和string是不同的类型。

## 标准库类型vector
vector是一个类模板。vector表示对象的集合，即容器container。集合中每个对象
都有一个索引。

vector是模板而非类型，由vector生成的类型必须包含vector中元素的类型，例如vector<int>

通常情况下，可以只提供vector对象容纳的元素数量而不写初始值。此时库会创建一个值初始化
的元素初值，并赋给容器中的每个元素。

vector对象的下标运算符可用于访问已存在的元素，但不能用于添加元素。

### vector初始化
#### 使用数组来初始化vector

int数组初始化vector<int>

需要数组提供2个地址，[begin,end)

```Cpp
static const int DATA_LEN = 10;
int datas[DATA_LEN] = {1,2,3,4,5,6,7,8,9,0};
vector<int> dataVec(datas,&datas[DATA_LEN]);
vector<int>::iterator dataIt = dataVec.begin();
for(;dataIt != dataVec.end();dataIt++) {
    cout << *dataIt << " ";/*输出vector中的元素*/
}
```
输出：`1 2 3 4 5 6 7 8 9 0`

## 迭代器介绍

```Cpp
vector<int>::iterator it;   // it能读写vector<int>的元素
string::iterator it2;       // it2能读写string对象中的字符

vector<int>::const_iterator it3;  // it3只能读元素，不能写元素
string::const_iterator it4;       // it4只能读字符，不能写字符
```

解引用迭代器可获得迭代器所指的对象。

#### 箭头运算符`->`
把解引用和成员访问两个操作结合在一起。

输出string元素直到遇到第一个空string为止
```Cpp
vector<string> svec;
svec.push_back("a");
svec.push_back("two");
svec.push_back("");
svec.push_back("three");
vector<string>::iterator sit;

for(sit = svec.begin();
        sit != svec.end() && !sit->empty(); ++sit) {
    cout << *sit << "\t";/*输出符合要求的结果*/
}

```
输出 `a       two` 遇到空string后循环就结束了

## 多维数组
严格来说，C++中并没有多维数组，通常所说的多维数组其实是数组的数组。
