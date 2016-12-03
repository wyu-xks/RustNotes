---
title: Android LMK - low memory killer
date: 2015-11-01 15:09:45
category: Android_note
tag: [Android]
---

##### 机器应对lmk问题
1.  增加系统“内存”
    * 划出一块内存作为swap space，用zram机制
    * T卡加上swap space

2. 直接关闭lmk
    * 由init启动，继承init的adj（-1000/-17），如slog

3. 根据用户习惯，调整minfree和adj值

4. 提高进程优先级
    * 设置persistent属性，如phone
    * 后台操作尽可能用service来实现，而不用线程实现
    * 重载系统back按键事件，使activity在后台运行，而不是被destory
    * 依赖于其它优先级高的进程

##### app如何降低被kill概率
进程要做到完全不被kill,基本也不可能。除非进程是系统进程，由init启动，
那么就可以继承init的adj(-17)，

这样即使system_server进程被kill了，也不会被kill。

不过可以做到尽可能不被lmk选中。

1) 提供进程优先级

后台操作尽可能用service来实现，而不用线程实现，因为包含service的进程优先级比普通进程高。  
重载系统back按键事件，使activity在后台运行，而不是被destory。  
依赖于其他优先级高的进程。

2) 修改进程属性

如phone进程，设置persistent属性。
