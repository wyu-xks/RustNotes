---
title: 迭代器 Iterator
date: 2015-04-25 22:11:40
category: Design_pattern
tag: [Java]
---

可以这样说，迭代器统一了对容器的访问方式。

考虑这样的情景：原本是对着List编码，但是后来发现需要把相同的代码用于Set。我们需要一种不关心容器类型
而能够通用的容器访问方法。

Iterator模式是用于遍历集合类的标准访问方法。
它可以把访问逻辑从不同类型的集合类中抽象出来，从而避免向客户端暴露集合的内部结构。  
迭代器是一个对象，它的工作是遍历并选中序列中的对象，而客户端程序员不必知道或关心该序列底层的结构。
能将遍历序列的操作与序列底层的机构分离。而且，创建迭代器的代价很小。

```java
List<Integer> list = new LinkedList<>();
for (int i = 1; i < 6; i++) {
    list.add(i);
}
Iterator iterator = list.iterator();
System.out.println("iterator 本身： " + iterator);
System.out.println(iterator.next());
while (iterator.hasNext()) {
    System.out.print(iterator.next() + " ");
}
```

输出：
```
iterator 本身： java.util.LinkedList$ListItr@1540e19d
1
2 3 4 5
```

尽量使用Java中提供的Iterator。
