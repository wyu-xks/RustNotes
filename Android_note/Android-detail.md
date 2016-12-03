---
title: Android 串口结点
date: 2015-10-01 15:09:38
category: Android_note
tag: [Android]
---

adb shell 查看路径 /dev ttyHS0  串口 ttyHS1 ttyHSL0

SELINUX 有[disabled]、[permissive]、[enforcing]3种选择。

* disabled：不启用SELINUX功能

* permissive：SELINUX有效，但是即使你违反了策略，它让你继续操作，但是把你的违反的内容记录下来。在我们开发策略的时候非常的有用。相当于Debug模式。

* enforcing：当你违反了策略，你就无法继续操作下去。

````bash
root@device0001:/ # getenforce
Enforcing
root@device0001:/ # setenforce 0
root@device0001:/ # getenforce
Permissive
root@device0001:/ # setenforce 1
root@device0001:/ # getenforce
Enforcing
```
