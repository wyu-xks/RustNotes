---
title: Quiz
date: 2015-03-06 19:41:46
category: Tools
toc: true
---

## Quiz
记录一些常见问题，并给出分析和解答

要求：通顺，简洁，有重点，专业

### Java
#### Java Object类有哪些方法？
_2分钟_

Object类中的方法有：getClass()，hashCode()，equals(Object obj)，protected Object clone()，toString()，
notify()，notifyAll()，wait(long millis)，wait(long millis, int nanos)，wait()，protected void finalize()

* getClass()返回Runtime中这个对象的类
* hashCode()计算出这个对象的hash值
* equals(Object obj)判断2个对象是否相同
* clone()得到当前对象的副本
* toString()类的string表示，可复写并输出自己感兴趣的信息
* wait()让当前线程进入等待状态，直到被唤醒或是达到预定的一段时间
* notify()唤醒1个在等待的线程，去竞争对象的锁；如果有多个线程都在这个对象中等待，选择其中一个线程唤醒；被选中的线程由具体实现方式决定
* notifyAll()唤醒所有在这个对象中等待的线程，去竞争对象的锁
* finalize()由垃圾回收器调用，回收资源

#### HashMap与HashTable的区别
_2分钟_

相同点：  
HashMap是基于哈希表实现的，每一个元素是一个key-value对，其内部通过单链表解决冲突问题，容量不足（超过了阀值）时，同样会自动增长。
HashMap是非线程安全的，多线程环境下可以采用concurrent并发包下的concurrentHashMap。
HashMap 实现了Serializable接口，支持序列化；也实现了Cloneable接口，能被克隆。

Hashtable同样是基于哈希表实现的，同样每个元素是一个key-value对，其内部也是通过单链表解决冲突问题，容量不足（超过了阀值）时，同样会自动增长。
Hashtable也是JDK1.0引入的类，是线程安全的，能用于多线程环境中。
Hashtable同样实现了Serializable接口，它支持序列化，实现了Cloneable接口，能被克隆。

区别：  
1、继承的父类不同  
Hashtable继承自Dictionary类，而HashMap继承自AbstractMap类。但二者都实现了Map接口。

2、线程安全性不同  
javadoc中关于hashmap的一段描述如下：此实现不是同步的。如果多个线程同时访问一个哈希映射，而其中至少一个线程从结构上修改了该映射，则它必须保持外部同步。
Hashtable 中的方法是Synchronize的，而HashMap中的方法在缺省情况下是非Synchronize的。
在多线程并发的环境下，可以直接使用Hashtable，不需要自己为它的方法实现同步，但使用HashMap时就必须要自己增加同步处理。

#### HashMap与HashTable的key能否为null？
_30秒_
HashMap对象的key、value值均可为null。
HahTable对象的key、value值均不可为null。

HahTable对为空的key和value做了处理，会抛出NullPointerException

#### HashMap是如何存储null key的？
_30秒_

hashMap是根据key的hashCode来寻找存放位置的。若key为null，hash值记为0；然后继续插入方法。

#### Object类notify和notifyAll的区别？
_30秒_

notify会根据JVM具体实现，唤醒多个线程中的其中一个；
notifyAll会唤醒在锁的等待池中的所有线程，继续执行.

#### ArrayList扩容策略
_1分钟_

java.util.ArrayList是个固定大小的对象，自身并不直接存储元素内容，而是持有一个引用指向一个数组，真正负责存储元素内容的正是这个数组。
当需要扩容时，扩容的是这个数组，而不是ArrayList对象自身。

* 1.计算的到新的容量capacity，新创建一个大小更大的数组
* 2.把原数组的内容拷贝到新数组去
* 3.把新数组的引用赋值到ArrayList对象的elementData字段上，完成扩容

#### JVM内存模型有哪几种？
_5分钟_

Java虚拟机运行时数据区，分为以下5种：方法区，虚拟机栈（VM Stack），本地方法栈（Native Method Stack），堆（Heap），程序计数器（Program Counter Register）

![JVM_memory](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Java_note/pics/JVM_runtime_memory.jpg)  

线程共有：Heap(Java堆) 和 Method Area(方法区)
##### Heap(Java堆)
**几乎所有对象实例和数组都要在堆上分配(栈上分配、标量替换除外)**, 因此是VM管理的最大一块内存, 也是垃圾收集器的主要活动区域. 由于现代VM采用分代收集算法, 因此Java堆从GC的角度还可以细分为: 新生代(Eden区、From Survivor区和To Survivor区)和老年代; 而从内存分配的角度来看, 线程共享的Java堆还还可以划分出多个线程私有的分配缓冲区(TLAB). 而进一步划分的目的是为了更好地回收内存和更快地分配内存.

##### Method Area(方法区)
即我们常说的永久代(Permanent Generation), 用于存储被JVM加载的类信息、常量、静态变量、即时编译器编译后的代码等数据

其中包括运行常量池。Class文件中除了有类的版本、字段、方法、接口等描述信息外,还有一项常量池(Constant Pool Table)用于存放编译期生成的各种字面量和符号引用, 这部分内容会存放到方法区的运行时常量池中(如前面从test方法中读到的signature信息). 但Java语言并不要求常量一定只能在编译期产生, 即并非预置入Class文件中常量池的内容才能进入方法区运行时常量池, 运行期间也可能将新的常量放入池中, 如String的intern()方法.

“线程私有”，线程级：程序计数器，Java Stack(虚拟机栈)，Native Method Stack(本地方法栈)
##### 程序计数器
一块较小的内存空间（“线程私有”内存）, 作用是**当前线程所执行字节码的行号指示器**(类似于传统CPU模型中的PC), PC在每次指令执行后自增, 维护下一个将要执行指令的地址. 
在JVM模型中, 字节码解释器就是通过改变PC值来选取下一条需要执行的字节码指令,分支、循环、跳转、异常处理、线程恢复等基础功能都需要依赖PC完成(仅限于Java方法, Native方法该计数器值为undefined). 

不同于OS以进程为单位调度, JVM中的并发是通过线程切换并分配时间片执行来实现的. 在任何一个时刻, 一个处理器内核只会执行一条线程中的指令.
因此, 为了线程切换后能恢复到正确的执行位置, 每条线程都需要有一个独立的程序计数器, 这类内存被称为“线程私有”内存.

##### Java虚拟机栈（Java Virtual Machine Stacks）
线程私有的，它的生命周期与线程相同。描述的是**Java方法执行的内存模型**: 每个方法被执行时会创建一个栈帧(Stack Frame)用于存储局部变量表、操作数栈、动态链接、方法出口等信息。
每个方法被调用至返回的过程，就对应着一个栈帧在虚拟机栈中从入栈到出栈的过程(VM提供了-Xss来指定线程的最大栈空间, 该参数也直接决定了函数调用的最大深度).

##### Native Method Stack(本地方法栈)
与Java Stack作用类似, 区别是Java Stack为执行Java方法服务, 而本地方法栈则为Native方法服务, 如果一个VM实现使用C-linkage模型来支持Native调用, 那么该栈将会是一个C栈, 但HotSpot VM直接就把本地方法栈和虚拟机栈合二为一.

* 《深入理解Java虚拟机》

#### Java引用类型有哪几种？

Java中提供了4个级别的引用：强应用、软引用、弱引用和虚引用

##### 强应用  
直接持有对象的实例

特点：
* 1. 强引用可以直接访问目标对象；
* 2. 强引用锁指向的对象在任何时候都不会被系统回收。JVM宁愿抛出OOM异常也不回收强引用所指向的对象； 
* 3. 强应用可能导致内存泄露；

##### 软引用（Soft Reference)
用来描述一些还有用但并非必须的对象。对于软引用关联着的对象，在系统将要发生内存溢出异常之前，将会把这些对象列进回收范围之中进行第二次回收。

##### 弱引用（Weak Reference)
用来描述非必须的对象，但是它的强度比软引用更弱一些，被弱引用关联的对象只能生存到下一次垃圾收集之前。
当垃圾收集器工作时，无论当前内存是否足够，都会回收掉只被弱引用关联的对象。一旦一个弱引用对象被垃圾回收器回收，便会加入到一个注册引用队列中。

软引用、弱引用都非常适合来保存缓存数据。如果这么做，当系统内存不足时，这些缓存数据会被回收，不会导致内存溢出。
而当内存资源充足时，这些缓存数据又可以存在相当长的时间，从而起来加速系统的作用。

##### 虚引用（Phantom Reference)
虚引用也称为幽灵引用或者幻影引用，它是最弱的一种引用关系。一个持有虚引用的对象，和没有引用几乎是一样的，随时都有可能被垃圾回收器回收。
当试图通过虚引用的get()方法取得强引用时，总是会失败。并且，虚引用必须和引用队列一起使用，它的作用在于跟踪垃圾回收过程。

* [Java引用类型 - 朱小厮的博客](http://blog.csdn.net/u013256816/article/details/50907595)

#### Java集合类的继承结构
可以分为两大类，一类是继承或实现Collection接口，这类集合包含List、Set和Queue等集合类。另一类是继承或实现Map接口，这主要包含了哈希表相关的集合类。

与Collection接口有关  
![collection pic](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Java_note/pics/collection_pic.png)

Map接口有关
![map pic](https://raw.githubusercontent.com/RustFisher/RustNotes/master/Java_note/pics/map_pic.png)

* [Java集合：整体结构 - liuxiaopeng](https://www.cnblogs.com/paddix/p/5539326.html)

#### StringBuilder和StringBuffer对比
_1min_

StringBuffer 字符串变量（线程安全）

StringBuilder 字符串变量（非线程安全）

单线程环境下，推荐使用StringBuilder，比StringBuffer快

* [Java面试题全集（上） CSDN](http://blog.csdn.net/jackfrued/article/details/44921941)
* [Java面试题全集（中） CSDN](http://blog.csdn.net/jackfrued/article/details/44931137)
* https://github.com/lietoumai/Hunter

#### Java垃圾回收机制
回收针对的是动态分配出来的内存，我们关注的是堆内存。

##### 一，如何确定某个对象是“垃圾”？
判定对象是否存活都与“引用”有关

引用计数算法  
给对象中添加一个引用计数器，每当有一个地方引用它时，计数器就加1；当引用失效时，计数器值就减1；任何时刻计数器都为0的对象就是不可能再被使用的。
Java语言没有选用引用计数法来管理内存，因为引用计数法不能很好的解决循环引用的问题。

可达性分析法  
该方法的基本思想是通过一系列的“GC Roots”对象作为起点进行搜索，如果在“GC Roots”和一个对象之间没有可达路径（成为引用链 Reference Chain），则称该对象是不可达的，不过要注意的是被判定为不可达的对象不一定就会成为可回收对象。被判定为不可达的对象要成为可回收对象必须至少经历两次标记过程，如果在这两次标记过程中仍然没有逃脱成为可回收对象的可能性，则基本上就真的成为可回收对象了。

哪些对象可以作为GC Roots？  
* 虚拟机栈（栈帧中的本地变量表）中的引用的对象
* 方法区中的类静态属性引用的对象
* 方法区中的常量引用的对象
* 本地方法栈中JNI（Native方法）的引用对象

##### 二，典型的垃圾收集算法
1.Mark-Sweep（标记-清除）算法

这是最基础的垃圾回收算法，之所以说它是最基础的是因为它最容易实现，思想也是最简单的。标记-清除算法分为两个阶段：标记阶段和清除阶段。标记阶段的任务是标记出所有需要被回收的对象，清除阶段就是回收被标记的对象所占用的空间。

标记-清除算法实现起来比较容易，但是有一个比较严重的问题就是容易产生内存碎片，碎片太多可能会导致后续过程中需要为大对象分配空间时无法找到足够的空间而提前触发新的一次垃圾收集动作。

2.Copying（复制）算法

为了解决Mark-Sweep算法的缺陷，Copying算法就被提了出来。它将可用内存按容量划分为大小相等的两块，每次只使用其中的一块。当这一块的内存用完了，就将还存活着的对象复制到另外一块上面，然后再把已使用的内存空间一次清理掉，这样一来就不容易出现内存碎片的问题。

这种算法虽然实现简单，运行高效且不容易产生内存碎片，但是却对内存空间的使用做出了高昂的代价，因为能够使用的内存缩减到原来的一半。
很显然，Copying算法的效率跟存活对象的数目多少有很大的关系，如果存活对象很多，那么Copying算法的效率将会大大降低。

3.Mark-Compact（标记-整理）算法

为了解决Copying算法的缺陷，充分利用内存空间，提出了Mark-Compact算法。该算法标记阶段和Mark-Sweep一样，但是在完成标记之后，它不是直接清理可回收对象，而是将存活对象都向一端移动，然后清理掉端边界以外的内存。

4.Generational Collection（分代收集）算法

分代收集算法是目前大部分JVM的垃圾收集器采用的算法。它的核心思想是根据对象存活的生命周期将内存划分为若干个不同的区域。一般情况下将堆区划分为老年代（Tenured Generation）和新生代（Young Generation），老年代的特点是每次垃圾收集时只有少量对象需要被回收，而新生代的特点是每次垃圾回收时都有大量的对象需要被回收，那么就可以根据不同代的特点采取最适合的收集算法。

目前大部分垃圾收集器对于新生代都采取Copying算法，因为新生代中每次垃圾回收都要回收大部分对象，也就是说需要复制的操作次数较少，但是实际中并不是按照1：1的比例来划分新生代的空间的，一般来说是将新生代划分为一块较大的Eden空间和两块较小的Survivor空间，每次使用Eden空间和其中的一块Survivor空间，当进行回收时，将Eden和Survivor中还存活的对象复制到另一块Survivor空间中，然后清理掉Eden和刚才使用过的Survivor空间。

而由于老年代的特点是每次回收都只回收少量对象，一般使用的是Mark-Compact算法。

注意，在堆区之外还有一个代就是永久代（Permanet Generation），它用来存储class类、常量、方法描述等。对永久代的回收主要回收两部分内容：废弃常量和无用的类。

##### 三，典型的垃圾收集器
* 1.Serial/Serial Old
    * Serial/Serial Old收集器是最基本最古老的收集器，它是一个单线程收集器，并且在它进行垃圾收集时，必须暂停所有用户线程。
    * Serial收集器是针对新生代的收集器，采用的是Copying算法，Serial Old收集器是针对老年代的收集器，采用的是Mark-Compact算法。
    * 它的优点是实现简单高效，但是缺点是会给用户带来停顿。
* 2.ParNew
    * ParNew收集器是Serial收集器的多线程版本，使用多个线程进行垃圾收集。
* 3.Parallel Scavenge
    * Parallel Scavenge收集器是一个新生代的多线程收集器（并行收集器），它在回收期间不需要暂停其他用户线程，其采用的是Copying算法，该收集器与前两个收集器有所不同，它主要是为了达到一个可控的吞吐量。
* 4.Parallel Old
    * Parallel Old是Parallel Scavenge收集器的老年代版本（并行收集器），使用多线程和Mark-Compact算法。
* 5.CMS
    * CMS（Current Mark Sweep）收集器是一种以获取最短回收停顿时间为目标的收集器，它是一种并发收集器，采用的是Mark-Sweep算法。
    * 运作过程分为4个阶段
        * 初始标记（CMS initial mark） - stop the world
        * 并发标记（CMS concurrent mark） - stop the world
        * 重新标记（CMS remark）
        * 并发清除（CMS concurrent sweep）
* 6.G1收集器
    * 面向服务端应用的收集器，它能充分利用多CPU、多核环境。因此它是一款并行与并发收集器，并且它能建立可预测的停顿时间模型。

### Android
#### Android ListView性能优化方式

* 在adapter中的getView方法中减少耗时操作
* item的布局层级越少越好
    * getView()方法中是否有大量对象存在 
    * 检查ListView的布局属性
* 使用ViewHolder

#### Android中的Loop是死循环吗？
是死循环

死循环确保代码能够一直执行下去。

#### 主线程是死循环，为什么界面不会卡死？
我们不希望主线程自己退出，要保证它能一直存活呢。简单做法就是可执行代码是能一直执行下去的，死循环便能保证不会被退出。

主线程的死循环一直运行是不是特别消耗CPU资源呢？ 其实不然，这里就涉及到Linux pipe/epoll机制，简单说就是在主线程的MessageQueue没有消息时，便阻塞在loop的queue.next()中的nativePollOnce()方法里，此时主线程会释放CPU资源进入休眠状态，直到下个消息到达或者有事务发生，通过往pipe管道写端写入数据来唤醒主线程工作。
这里采用的epoll机制，是一种IO多路复用机制，可以同时监控多个描述符，当某个描述符就绪(读或写就绪)，则立刻通知相应程序进行读或写操作，本质同步I/O，即读写是阻塞的。 
所以说，主线程大多数时候都是处于休眠状态，并不会消耗大量CPU资源。

#### Android内存泄露有哪几种？
内存泄漏：简单说来就是内存无法被回收。我们所讨论的内存泄漏，主要讨论堆内存，他存放的就是引用指向的对象实体。

* 单例模式引起的内存泄露
    * 由于单例模式的静态特性，它的生命周期可能和进程一样长，如果让单例无限制的持有Activity的强引用就会导致内存泄漏
* 非静态内部类引起内存泄露
* 未移除已不需要的回调发生内存泄露
* 资源未关闭引起的内存泄露情况 
    * 比如：BroadCastReceiver、Cursor、Bitmap、IO流、自定义属性attribute attr.recycle()回收。 
    * 当不需要使用的时候，要记得及时释放资源。否则就会内存泄露。
* 无限循环动画 
    * 没有在onDestroy中停止动画，否则Activity就会变成泄露对象。 
    * 比如：轮播图效果。
* 集合引发的内存泄漏
    * 存放了太多对象
* 循环引用，A持有B，B持有C，C持有A，这样的设计谁都得不到释放

#### 自定义控件中，自定义类的成员变量能否与父类的同名？
可以

由此可见，父类和子类的变量是同时存在的，即使是同名。
子类中看到的是子类的变量，父类中看到的是父类中的变量。

#### Android动画有哪几种？
帧动画，属性动画，补间动画

* 帧动画 - Frame Animation
    * 一帧帧的播放图片，利用人眼视觉残留原理，给我们带来动画的感觉。它的原理的GIF图片、电影播放原理一样。

* 补间动画 - Tween Animation
    * 补间动画就是我们只需指定开始、结束的“关键帧“，而变化中的其他帧由系统来计算，不必自己一帧帧的去定义。
    * Android使用Animation代表抽象动画，包括四种子类：AlphaAnimation(透明度动画)、ScaleAnimation(缩放动画)、TranslateAnimation(位移动画)、RotateAnimation(旋转动画)
    * 一般都会采用动画资源文件来定义动画，把界面与逻辑分离
    * 定义好anim文件后，我们可以通过AnimationUtils工具类来加载它们，加载成功后返回一个Animation。然后就可以通过View的startAnimation(anim)开始执行动画了

* 属性动画 - Property Animation
    * 直接更改我们对象的属性。在上面提到的Tween Animation中，只是更改View的绘画效果而View的真实属性是不改变的
    * 常用`Animator`类，`ValueAnimator`等
        * `Animator`可加载动画资源文件
        * `ValueAnimator`可使用内置估值器，添加监听`AnimatorUpdateListener`，在每次变化时修改view的属性

#### Android View绘制流程

measure、layout、draw

在onMeasure方法中View会对其所有的子元素执行measure过程，此时measure过程就从父容器"传递"到了子元素中，接着子元素会递归的对其子元素进行measure过程，如此反复完成对整个View树的遍历。
onLayout与onDraw过程的执行流程与此类似。

measure过程决定了View的测量宽高，这个过程结束后，就可以通过getMeasuredHeight和getMeasuredWidth获得View的测量宽高了；

layout过程决定了View在父容器中的位置和View的最终显示宽高，getTop等方法可获取View的top等四个位置参数（View的左上角顶点的坐标为(left, top), 右下角顶点坐标为(right, bottom)），
getWidth和getHeight可获得View的最终显示宽高（width = right - left；height = bottom - top）。 

draw过程决定了View最终显示出来的样子，此过程完成后，View才会在屏幕上显示出来。

https://www.cnblogs.com/absfree/p/5097239.html

#### Android 图形显示流程 - 一张图片是怎么显示出来的

* 第一步，得到位图（Bitmap）的内存数据，即从相应的图片文件解码，得到数据放并放到内存。 
* 第二步，使用某种2D引擎，将位图内存按一定方式，渲染到可用于显示的图形内存（GraphicBuffer）上。 
* 第三步，由一个中心显示控制器（Surfaceflinger），将相应的图形内存投放到显示屏（例如LCD）。

#### Android 计算bitmap占用内存大小

* 色彩格式，如果是 ARGB8888 那么就是一个像素4个字节，如果是 RGB565 那就是2个字节
* 原始文件存放的资源目录类别（是 hdpi 还是 xxhdpi）；原始资源的 density 取决于资源存放的目录
* 目标屏幕的密度

例如：一张522*686的PNG 图片，放到 drawable-xxhdpi 目录下，在三星s6上加载，占用内存2547360B。
其中 density 对应 xxhdpi 为480，targetDensity 对应三星s6的密度为640：
```
scaledWidth = int( 522 * 640 / 480f + 0.5) = int(696.5) = 696
scaledHeight = int( 686 * 640 / 480f + 0.5) = int(915.16666…) = 915
所占内存为 915 * 696 * 4 = 2547360
```

#### Android 触摸事件描述
触摸事件分发：
由根视图向子view分发。onInterceptTouchEvent 方法（ViewGroup才有）的返回值决定是否拦截触摸事件（true：拦截，false：不拦截）。如果 ViewGroup 拦截了触摸事件，那么其 onTouchEvent 就会被调用用来处理触摸事件。 

触摸事件消费：
onTouchEvent 方法的返回值决定是否处理完成触摸事件（true：已经处理完成，不需要给父 ViewGroup 处理，false：还没处理完成 ，需要传递给父 ViewGroup 处理）。

#### MVC，MVP和MVVM简介

MVC
* View 接受用户交互请求
* View 将请求转交给Controller
* Controller 操作Model进行数据更新
* 数据更新之后，Model通知View更新数据变化
* View 更新变化数据

方式：所有方式都是单向通信

结构实现
* View ：使用 Composite模式 
* View和Controller：使用 Strategy模式 
* Model和 View：使用 Observer模式同步信息

使用  
MVC中的View是可以直接访问Model的！从而，View里会包含Model信息，不可避免的还要包括一些业务逻辑。在MVC模型里，更关注的Model的不变，而同时有多个对Model的不同显示，及View。所以，在MVC模型里，Model不依赖于View，但是 View是依赖于Model的。不仅如此，因为有一些业务逻辑在View里实现了，导致要更改View也是比较困难的，至少那些业务逻辑是无法重用的。

MVP  
* View 接收用户交互请求
* View 将请求转交给 Presenter
* Presenter 操作Model进行数据更新
* Model 通知Presenter数据发生变化
* Presenter 更新View数据
MVP的优势  
* Model与View完全分离，修改互不影响
* 更高效地使用，因为所有的逻辑交互都发生在一个地方 —— Presenter内部
* 一个Preseter可用于多个View，而不需要改变Presenter的逻辑（因为View的变化总是比Model的变化频繁）。
* 更便于测试。把逻辑放在Presenter中，就可以脱离用户接口来测试逻辑（单元测试）

方式:各部分之间都是双向通信

结构实现
* View ：使用 Composite模式
* View和Presenter：使用 Mediator模式
* Model和Presenter：使用 Command模式同步信息

MVC和MVP区别 MVP与MVC最大的一个区别就是：Model与View层之间倒底该不该通信（甚至双向通信）

MVVM  
* View 接收用户交互请求
* View 将请求转交给ViewModel
* ViewModel 操作Model数据更新
* Model 更新完数据，通知ViewModel数据发生变化
* ViewModel 更新View数据

方式： 双向绑定。View/Model的变动，自动反映在 ViewModel，反之亦然。

使用
* 可以兼容你当下使用的 MVC/MVP 框架。
* 增加你的应用的可测试性。
* 配合一个绑定机制效果最好。

MVVM模式和MVC模式一样，主要目的是分离视图（View）和模型（Model），有几大优点: 
* 低耦合。View可以独立于Model变化和修改，一个ViewModel可以绑定到不同的”View”上，当View变化的时候Model可以不变，当Model变化的时候View也可以不变。 
* 可重用性。你可以把一些视图逻辑放在一个ViewModel里面，让很多view重用这段视图逻辑。 
* 独立开发。开发人员可以专注于业务逻辑和数据的开发（ViewModel），设计人员可以专注于页面设计，生成xml代码。 
* 可测试。界面素来是比较难于测试的，而现在测试可以针对ViewModel来写。

#### Andorid 子线程更新UI为什么会崩溃

子线程更新UI能抛出`CalledFromWrongThreadException`异常。
View的`invalidate()`方法会触发ViewParent接口的invalidateChildInParent方法。
而实现类ViewRootImpl的这个invalidateChildInParent方法中会检查当前线程是否UI线程。

在onResume之前用非UI线程更新能UI，而onResume之后就不行了。这是因为onResume之前还没有创建ViewRootImpl示例

#### for循环1000次，和循环10万次，怎么组合，1000在外循环，还是10万在外循环
#### synchronize 同步关键字加在静态方法和非静态方法上的区别

synchronized关键字加到static静态方法上是给那个Class类上锁 
而加到非static静态方法是给类的对象加锁 

#### rxbus有啥缺点
