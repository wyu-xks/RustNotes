---
title: 环绕遍历“方形”2维数组
date: 2018-02-24 21:35:28
category: Algorithm
---

### 问题描述
 环绕遍历“方形”2维数组。假设数组中存的都是正整数，子数组中的元素个数一致，例如：
 ```
    [1, 2, 3, 4, 5],
    [16, 17, 18, 19, 6],
    [15, 24, 25, 20, 7],
    [14, 23, 22, 21, 8],
    [13, 12, 11, 10, 9]
 ```
从第一个元素开始顺时针遍历，上面的数组会输出
```
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
```

### 思路
顺时针一直在“右转”，方向有4个：右-下-左-上。就像画一个不断缩小的圈，边界在一圈圈地缩小。

计算出元素总个数。定义4个方向和4个边界下标，当触及边界时，按顺时针变换方向。

python实现
```python
def travel_around(source):
    dir_right = 0
    dir_down = 1
    dir_left = 2
    dir_up = 3
    ver_up_limit = 1
    hor_left_limit = 0
    ver_down_limit = len(source) - 1
    hor_right_limit = len(source[0]) - 1
    total_ele = (ver_down_limit + 1) * (hor_right_limit + 1)
    print("verBoundIndex:%d, horBoundIndex:%d, total:%d" % (ver_down_limit, hor_right_limit, total_ele))
    index_x = 0
    index_y = 0
    direction = dir_right
    res = []
    for i in range(0, total_ele):
        res.append(source[index_y][index_x])
        if dir_right == direction:
            if index_x < hor_right_limit:
                index_x += 1
            elif index_x == hor_right_limit:
                hor_right_limit -= 1
                direction = dir_down
                index_y += 1
        elif dir_down == direction:
            if index_y < ver_down_limit:
                index_y += 1
            elif index_y == ver_down_limit:
                ver_down_limit -= 1
                direction = dir_left
                index_x -= 1
        elif dir_left == direction:
            if index_x > hor_left_limit:
                index_x -= 1
            else:
                hor_left_limit += 1
                direction = dir_up
                index_y -= 1
        elif dir_up == direction:
            if index_y > ver_up_limit:
                index_y -= 1
            elif index_y == ver_up_limit:
                ver_up_limit += 1
                direction = dir_right
                index_x += 1
    print(res)
```

测试与输出
```python
list1 = [
    [1, 2, 3, 4, 5],
    [16, 17, 18, 19, 6],
    [15, 24, 25, 20, 7],
    [14, 23, 22, 21, 8],
    [13, 12, 11, 10, 9]
]

list2 = [
    [1, 2, 3, 4, 5, 6],
    [18, 19, 20, 21, 22, 7],
    [17, 28, 29, 30, 23, 8],
    [16, 27, 26, 25, 24, 9],
    [15, 14, 13, 12, 11, 10]
]

list3 = [
    [1, 2],
    [6, 3],
    [5, 4]
]

list4 = [[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]]
list5 = [[1]]
list6 = [[1], [2], [3], [4], [5], [6], [7]]

# -------- output --------
# verBoundIndex:4, horBoundIndex:4, total:25
# [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25]
# verBoundIndex:4, horBoundIndex:5, total:30
# [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30]
# verBoundIndex:2, horBoundIndex:1, total:6
# [1, 2, 3, 4, 5, 6]
# verBoundIndex:0, horBoundIndex:9, total:10
# [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
# verBoundIndex:0, horBoundIndex:0, total:1
# [1]
# verBoundIndex:6, horBoundIndex:0, total:7
# [1, 2, 3, 4, 5, 6, 7]
```

*这里定义了4个方向和4个边界，有没有更简单的方法？*
