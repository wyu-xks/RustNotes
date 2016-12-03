---
title: Android Init进程 详解
date: 2015-05-14 08:09:44
category: Android_note
tag: [Android]
---

主要内容
* Init概述
* Init进程工作内容
* init.rc脚本介绍
* 解析init.rc配置文件
* 如何触发和启动Action和Service
* Init进程对属性服务的处理
* Init一些主要守护进程介绍

## Init进程概述
Android是一个基于Linux内核的操作系统，目前Linux有很多通讯机制可以在用户空间和内核空
间之间交互，例如设备驱动文件（位于/dev目录中）、内存文件（ /proc、/sys目录等）。
当linux内核启动之后，运行的第一个进程是init，这个进程是一个守护进程。
Init是一个命令行程序。其主要工作之一就是建立这些与内核空间交互的文件所在的目录。
也就是说， init是用户空间执行的第一个进程,它的生命周期贯穿整个linux 内核运行的始终，
Android很多重要工作都是从它开始的。

## Init进程
- 首先需要在源码中找到main函数入口，它位于/system/core/init/init.c中，可以将init
的执行过程分为以下几个阶段：
- 创建文件系统目录并挂载相关的文件系统，为之后的执行阶段做准备。在init
初始化过程中， Android分别挂载了tmpfs， devpts， proc， sysfs 4类文件系统。
- tmpfs是一种虚拟内存的文件系统，典型的tmpfs文件系统完全驻留在RAM中，读
写速度远快于内存或硬盘文件系统。
- /dev目录保存着硬件设备访问所需要的设备驱动程序。在Android中，将相关目录
作用于tmpfs，可以大幅度提高设备访问的速度。
- devpts是一种虚拟终端文件系统。
- proc是一种虚拟文件系统，只存在于内存中，不占用外存空间。借助此文件系统，
应用程序可以与内核内部数据结构进行交互。
- sysfs是一种特殊的文件系统，在Linux 2.6中引入，用于将系统中的设备组织成层
次结构，并向用户模式程序提供详细的内核数据结构信息，
将proc、 devpts、devfs三种文件系统统一起来。
- 第二步：初始化内核log系统。
- 第三步：解析 init.rc和init.<hardware>.rc初始化文件。
- 第四步：触发需要执行的Action和Service。
- 第五步： init循环监听处理事件。 init触发所有Action后，进入一个无限循环，执行
在可执行队列中的命令，重启异常退出的Service，并循环处理来自property
service（属性服务）、 signal和keychord的事件。
- 第六步：处理android属性服务，启动系统属性服务。

## init.rc文件解析过程

Android初始化脚本语言包含四种类型的语句：
* 动作（ Actions）
* 指令（ Commands）
* 服务（ Services）
* 选项（ Options）

关键字on是用来声明一个Action  
Command指令是一个命令或者方法，用来修饰Action  
Trigger是Action的触发器，用来触发Action的执行，也被称为Action的名称  
关键字Service是用来声明一个service  
Options主要用来修饰services

Android初始化脚本语言有三大模块：
- 1) import 导入其他的init.xx.rc文件。
- 2) 以action动作为触发点的一系列命令
- 3) 带有各种Options的一系列services的定义

### Import(引入)
import的语法其实和代码中的import十分类似，就是包含其它的rc文件， 类似include，
它 可以以init.xx.rc方式引入。

例如：
```
import /init.usb.rc
import /init.trace.rc
```
大多数配置文件都直接使用了确定的文件名，还有一种方式是：
```
init.${ro.hardware}.rc
```
ro.hardware是系统属性，可以通过`adb shell getprop ro.hardware`去查看  
这个属性是在init.c的main方法中的get_hardware_name(hardware, &revision);
获得然后设置到ro.hardware中的。

另外还有一种类似于init_charger.rc 这种形式的rc文件，它不是被包含在init.rc文件中，
它是在判断ro.bootmode属性为“ charger”时，直接在代码中进行解析和处理，
在层次上和init.rc文件属于并列关系。

rc文件可以根据不同的要求，定义多个init.xx.rc文件，例如init_charger.rc。
实际项目中同一个init.xx.rc中有重名的action，也可以正常使用。
多个init.xx.rc中action也允许有重名， 比如 boot， init 等在多个rc文件中出现。

### Action(动作)
Action具体定义在文档上是这样的：是有名字的一系列的命令。  
Action有一个tirgger（触发器），用于决定该Action应在何时执行。  
当一个事件发生并匹配了一个Action的trigger， 相应的Action将被添加到即将执行（ to-be-executed） 队列的尾部（除非她已经在队列上了）。

每个action在队列中顺序排列，每个action中的command将会顺序执行  
Init执行command的过程都是在子进程进行的，所以command执行中不能被中断。
说的白一点Action就是一大堆命令的集合，按照顺序依次执行。

Action具有以下格式：
```
on <trigger>
<command>
<command>
```

脚本片段：
```
on boot
mkdir /dev
mkdir /proc
mount tmpfs tmpfs /dev
mkdir /dev/pts
write /proc/cpu/alignment 4
```
这里的Trigger（ 触发器）就是boot, boot这个触发器是在系统被加载后触发。  
第一个command命令就是mkdir, 这个命令定义的规范是这样的
```
mkdir <path> [mode] [owner] [group]
```
创建一个目录<path>， 可以选择性地指定mode、 owner以及group。  
如果没有指定，默认的权限为755，并属于root用户和root组。  
所以第一行的意思就是创建一个默认权限为755用户为root的目录。

第三行命令的语法规范是这样：
```
mount <type> <device> <dir> [ <mountoption> ]*
```
这行代码意思就是在/dev目录下挂载一个类型为tmpfs的设备tmpfs。

实例：在根目录下创建一个目录
• 根目录下创建一个storage的目录
• Owner权限：读、写、执行
• 用户为 root用户，权限为可读、可执行，不能写
• 用户组为sdcard_r
• 其他用户只能有执行权限

那么我们看看这个如何配置呢？
```
on init
mkdir /storage 0751 root sdcard_r
```
上面的配置信息满足我们的要求，首先我们用mkdir创建了一个/storage目录，然后根
据要求添加权限为0751 ，然后设置用户为root,用户组为sdcard_r。
另外注意的地方就是放置的位置， init.rc配置文件有很多子阶段  
什么叫子阶段呢？ init将action按照执行时间段的不同分为early-init、 init、 early-boot、 boot他们的执行顺序是在代码中指定的，
进行这样的划分是由于有些动作之间具有依赖关系，某些动作只有在其他动作完成后才能执行；
所以就有了先后的区别，例如early-init的执行要比init 子阶段提前执行，
至于这个配置文件要放置到哪个子阶段，
这要根据需求和逻辑来决定他们放到init.rc的中的哪个子阶段
我们在看一下下面配置文件，设置方式和我前面举的例子是一样的。
```
on early-init
mkdir /mnt 0775 root system
on init
mkdir /mnt/shell 0700 shell shell
mkdir /mnt/media_rw 0700 media_rw media_rw
```

### Service（ 服务）
service类型的section表示一个可执行程序，每一个Service都是init进程的子进程，
由关键字service、 服务名、服务对应的命令的路径、命令的参数和Option组成。
它的语法结构如下所示:
```
service <name> <pathname> [ <argument> ]*
<option>
<option>
```
```
<name>代表Service的名字，必须指定
<pathname>代表所要执行的服务的路径，必选项
[ <argument> ]*代表传给服务的参数，可有0到多个
<option>可以有1到多个，主要是服务的启动配置参数
```

#### service的例子
##### 实例1
一般在手机启动后，应用程序启动之前，往往需要在Android启动过程中经常
会调用一些shell脚本，那么如何在在init.rc中调用shell脚本呢？
```
service test_shell /system/bin/test_shell.sh
user root
class main
oneshot
```
第一行的配置意思就是定义一个名字叫test_shell的service,这个test_shell名字可以随
便起，只有你愿意，你可以起任何名字，然后这个test_shell名字指向一个它的执行
路径，一般执行文件都会放在system/bin目录下。

后面3行配置信息就是这个service的执行规则了。

user root就是执行时要以root用户执行。

service服务启动方式可以在action的特定子阶段启动，也可以通过在代码中设定
“ ctl.start ”方式来启动。
系统属性“ctrl.start ”和“ctrl.stop ”是用来启动和停止服务。
前提是要启动的这个服务必须在/init.rc中定义。系统启动时， init守护进程将解析
init.rc和启动属性服务。一旦收到设置“ctrl.start ”或者“ ctrl.stop ”属性的请求，属
性服务将使用该属性值作为服务名找到该服务，启动或者停止该服务。

这个系统属性一般都是在代码进行设置的，例如：  
property_set("ctl.start"," test_shell ");

class main 意思是设置服务类型，那么当启动这个main类别的时候，就会启动
test_shell这个服务，如何启动这个main类别的服务？

这就需要配置一个action来启动这个main类别的服务。在init.rc文件中有很多main类
型的服务，一般情况下启动shell脚本一般都是在设置属性时来启动的。我们看配置
示例：  
(注：这里的属性值是自己定义的)
```
on property:test_pro =trigger_test
class_start main
```
这样，当属性test_pro的值等于“ trigger_test”就会触发这个服务。

oneshot 的意思就是只运行一次，退出后不会重新启动，对于shell这样的执行脚本一
般都会设置这个属性，因为只需要执行一次。同类型的比如bootanim(开机动画)等。

另外service有一个特殊的选项disabled。 disabled 就是现在不启动这个服务，也就是
无法通过init.rc中通过启动一类服务来启动，比如上面说的class_start main来启动，
那么什么时候启动这个服务呢？怎么启动呢？

一般设置了disabled选项一般有2种方法来启动服务：
1、通过在代码中设置properties 来启动这个service, 例如：  
```
property_set("ctl.start", " test_shell ");
```
2、在init.rc同样通过设定属性值来启动，例如：
```
on property:test2_pro =2
start test_shell
```
通过特定属性来启动service是比较常见的  
start test_shell 只是针对特定的一个service。

##### 实例2：我们想在service中添加一个socket
同样我们分析一段init.rc的代码片段：
```
service myserver-daemon /system/bin/server
socket server stream 666
socket dnsproxyd stream 0660 root inet
oneshot
```
上面的代码的意思是我们定义了一个名称为myserver-daemon的service, 路径是
/system/bin/server

第二行配置表示我们建立一个名字为server，类别为stream访问权限为0660的sokcet.

第一行代码是主要是为要打开或者使用色socket指出路径。

如果不指定路径，那么开启的socket就是/dev/socket/路径下的socket。第三行的配置
就是这样的。

最后是oneshot选项， oneshot选项表示该服务只启动一次，而如果没有oneshot选项，
这个可执行程序会一直存在--如果可执行程序被杀死，则会重新启动。

我们可以通过socket为/system/bin/server这个守护进程分配一个名为“ server”的
socket资源, 这样我们就可以在system/bin/server这里面通过下面的代码来获得一个
socket，并建立一个服务端。
```
s_fdListen = android_get_control_socket(“server”);
ret = listen(s_fdListen, n);
s_fdCommand = accept(s_fdListen, (sockaddr *) &peeraddr, &socklen);
```
这样java层在通过“ server”这个标志符建立一个客户端，就可以进行socket通信了。

### Properties（属性）
属性（ property）是一对键/值（ key/value）组合，键和值都是字符串类型。
Androd中非常多的应用程序和库直接或者间接的依赖于属性系统，并由此决定其
运行期的行为。它的处理流程同android的其他模块一样，也分为服务端和客户端，
property设置必须在服务端，读取直接在客户端。

这些属性多数是开机启动时预先设定的，也有一些是动态加载的。

系统启动时以下面的次序加载预先设定属性：
```
/default.prop
/system/build.prop
/system/default.prop
/data/local.prop
/data/property/*
/default.prop 一般存的是“ ro.”的只读属性。
```

#### 1、 android 系统属性特性
property可以通过命令adb shell查看或者设置属性

getprop查看手机上所有属性状态值。

或者 getprop init.svc.bootanim制定查看某个属性状态

使用setprop init.svc.bootanim start 设置某个属性的状态

##### property特别属性
如果属性名称以“ ro.”开头，那么这个属性被视为只读属性。一旦设置，属性值不能改变。

如果属性名称以“ persist.”开头，当设置这个属性时，其值也将写入/data/property。

如果属性名称以“ net.”开头，当设置这个属性时，“ net.change”属性将会
自动设置，以加入到最后修改的属性名。

属性“ctrl.start”和“ctrl.stop”是用来启动和停止服务。每一项服务必须在/init.rc中定义.

#### 2、启动脚本中属性使用方法
properties是系统中使用的一些值，可以进行设置和读取
```
setprop ro.FOREGROUND_APP_MEM 1536
setprop ro.VISIBLE_APP_MEM 2048
on property:ro.kernel.qemu=1
start adbd
```
properties属性在init.rc中的配置，一般都是在action去处理的， setprop 用于设置属
性， on property可以用于判断属性，这里的属性在整个Android系统运行中都是一致
的。

一般property启动应该加在init.<your hardware>.rc或者是init.rc里。下面是一个init.rc
里的例子：
```
# adbd on at boot in emulator
on property:ro.kernel.qemu=1
start adbd
```
在init.rc中设置的系统属性Property可以通过上面说的一些方式去调用，也可以通过
代码中设置来激活init.rc设置特定服务。

## 解析init.rc配置文件

解析init.rc的代码在system/core/init/init.c的main方法中：
```
init_parse_config_file("/init.rc");
```
上面的代码首先进行文件读取，然后进行解析文件，主要负责解析是init_parser.c，  
在rc文件中还有许多类似init.xxx.rc的文件， init.rc 和 init.xxx.rc的执行顺序，两个
脚本文件可以包含相同的sction，但是对每一个section，都是先执行完init.rc，再
去执行init.xxx.rc

init_parse_config_file的函数代码如下：
```
int init_parse_config_file(const char *fn)
{
char *data;
data = read_file(fn, 0);
if (!data) return -1;
parse_config(fn, data);
DUMP();
return 0;
}
```

先用read_file()把脚本内容读入一块内存，而后调用parse_config()解析这块内存。

parse_config()的代码截选如下：
```
static void parse_config(const char *fn, char *s)
{
. . . . . .
for (;;) {
switch (next_token(&state)) {
. . . . . .
case T_NEWLINE: // 遇到折行
state.line++;
if (nargs) {
int kw = lookup_keyword(args[0]);
if (kw_is(kw, SECTION)) {
state.parse_line(&state, 0, 0); // 不同section的parse_line也不同
parse_new_section(&state, kw, nargs, args);
} else {
state.parse_line(&state, nargs, args);
}
nargs = 0;
}
break;
```

### keyword关键字及映射
解析过程是按行对init.rc脚本解析，并根据关键字匹配
类型为SECTION的关键字有:on和sevice也就是action或service类型，还有一个import类型；
parse_state定义在parser.h中，
lookup_keyword和parse_new_section定义在init_parser.c中，

next_token() 解析完init.rc中一行之后，会返回T_NEWLINE，
这时调用lookup_keyword函数来找出这一行的关键字。
lookup_keyword的方法按26个字母顺序（关键字首字母）进行处理。


### 解析section小节
如果遇到Section，便调用parse_new_section函数，进入Section的解析过程。
一旦分析出某句脚本是以on或者service或者import开始，就说明一个新的setction了，
此时，会调用到parse_new_section()

- 1、 Action解析，调用了parse_action和parse_line_action
- 2、 Service解析，调用了parse_service和parse_line_action
- 3、 import解析， 调用了parse_import

核心的部分是service和action，具体解析的地方在上面代码中的parse_service()和
parse_action()函数里。至于import， parse_import()函数只是把脚本中的所有import语
句先汇总成一个链表，记入state结构中，待回到parse_config()后再做处理。

### 解析service小节
根据关键字来判断，如果是service则调用parse_service方法进行解析。  
parse_service()方法位于system/core/init/Init_parser.c。下面用图示来表示这个流程：

有几个基本概念
- 1、 service_list：声明了一个双向链表，存储了前向和后向指针。
- 2、 list_init和list_add_tail：提供了基本的双向链表操作，
list_init和list_add_tail的实现代码位于/system/core/libcutils/list.c中， list_add_tail只是将item加入到双向链表的尾部。这里注意的是onrestart域，因为它本身又是个action节点，可携带若干个子command。

解析service段时，会用calloc()申请一个service节点，初始化services，将service放入
service_list总表中。注意，此时该service节点的onrestart.commands部分还是个空链表

service是parse_service中的一个比较重要的数据类型，它存储了service这个Section
的内容， service结构体定义在 /system/core/init/init.h:
```
struct service {
/* list of all services */
struct listnode slist;
const char *name;
const char *classname;
...
struct action onrestart; /* Actions to execute on restart. */
...
```
从上面的代码中，我们可以看到Service需要填充的内容很多， parse_service函数只
是初始化了Service的基本信息，详细信息需要由parse_line_service填充。

parse_new_section()中为service明确指定了解析后续行的函数parse_line_service()
```
static void parse_line_service(struct parse_state *state, int nargs, char **args)
{
struct service *svc = state->context;
struct command *cmd;
......
kw = lookup_keyword(args[0]);
switch (kw) {
case K_capability:
.......
```

### 解析action小节
解析action小节时的动作也很简单，首先从parse_action开始的，会调用calloc()开辟
出一个内存空间给action节点，将aciton的指针放入到action_list表中。这时候，
action的commands部分为空。

上面是Action的存储形式，接着分析Action的解析过程。定位到parse_line_action函
数，该函数位于init_parser.c中，与service类似，我们对action指定了不同的解析后续
行的函数，也就是parse_line_action()。该函数位于init_parser.c中:

## 触发和启动Action和Service
### 触发Action和service
经过解析init.rc，脚本中的actions和services被整理成双向链表，但是这些actions和
services并没有被实际执行。现在我们就来看下一步具体执行action的流程。下面的代
码片段是init.c的main方法：
```
action_for_each_trigger("early-init", action_add_queue_tail);
queue_builtin_action(wait_for_coldboot_done_action, "wait_for_coldboot_done");
queue_builtin_action(mix_hwrng_into_linux_rng_action, "mix_hwrng_into_linux_rng");
queue_builtin_action(keychord_init_action, "keychord_init");
queue_builtin_action(console_init_action, "console_init");
/* execute all the boot actions to get us started */
action_for_each_trigger("init", action_add_queue_tail);
```

init进程希望把系统初始化过程分割成若干“子阶段”， action_for_each_trigger()
的意思就是“触发某个子阶段里的所有action”。代码中显式使用的Trigger，它们并
没有列入Android初始化语言定义的Trigger中。
比如可以在init.rc中搜索到early-init、init、 charger、 nonencrypted、 post-fs-data、 post-fs、 fs等Trigger，这些Trigger其实是当作Action名字使用。这些子阶段必须是按一定的顺序来执行的。

init解析完init.rc后，接着执行了action_for_each_trigger和queue_builtin_action。

首先定位到action_for_each_trigger，其实现代码位于init_parser.c中，代码如下：
```
void action_for_each_trigger(const char *trigger,
void (*func)(struct action *act))
{
    struct listnode *node;
    struct action *act;
    list_for_each(node, &action_list) {
        act = node_to_item(node, struct action, alist);
        if (!strcmp(act->name, trigger)) {
            func(act); // 只要匹配，就回调func
        }
    }
}
```
action_for_each_trigger函数首先遍历action_list链表，找寻所有“ action名”和“参
数trigger”匹配的节点，并回调“参数func所指的回调函数”。在前面的代码中，回
调函数就是action_add_queue_tail()。
```
void action_add_queue_tail(struct action *act)
{
    if (list_empty(&act->qlist)) {
        list_add_tail(&action_queue, &act->qlist);
    }
}
```
init进程里主要分割的“子阶段”

子阶段也可是说是一个action，一般在*.rc文件配置的大多数都
为下面的子阶段init， boot，early-init,early-boot,boot,
有些子阶段并没有体现在init.rc脚本里，而是写在具体代码里的，
这些action（子阶段）可以被称为“内建action”，我们可以
通过调用queue_builtin_action()将“内建action”添加进
action_list列表和action_queue队列中action_queue队列！
它和action_list列表有什么关系？

action_list可以被理解成一个来自init.rc的“临时列表”，由于是从init.rc中解析出来
的，所以列表中节点顺序和init.rc文件中的section时的顺序是一致的，但是，我们在
运行的时候，就不一定按照这个顺序来运行，所以需要重新对action_queue进行排序，
以适应系统运行的顺序，这个序列就是action_queue队列。另外，有些action并没有
写在init.rc文件中，而是写在具体代码里的，这些action可以被称为“内建action”，
这些action的共同点是没有参数，类似这样的action我们可以通过调用
queue_builtin_action()将“内建action”添加进action_list列表和action_queue队列中，
并追加到action_queue的队尾。
```
void queue_builtin_action(int (*func)(int nargs, char **args), char *name)
{
struct action *act;
struct command *cmd;
......

list_add_tail(&act->commands, &cmd->clist);
list_add_tail(&action_list, &act->alist);
action_add_queue_tail(act);
```
### 启动Action和service
action_for_each_trigger和queue_builtin_action都没有实际执行Service和Action。那
么Action和service是如何启动的呢？其位于init.c中，代码如下：
```
for(;;) {
int nr, i, timeout = -1;
execute_one_command();
restart_processes();
if (!property_set_fd_init && get_property_set_fd() > 0) {
```
init进程最终会进入一个for(;;)无限循环，在这个循环中，每次都会尝试执行一个
command建立init的子进程(init是所有进程的父进程)
这里主要的函数就是execute_one_command（） ,它主要就是按顺序执行每一个
command命令。

有些service的启动是通过action的command命令，例如下面
```
on boot
......
......
class_start core
class_start main
```
这是action的一个子阶段的配置过程， core和main是service的分类名，上面的配置脚
本的意思就是这里将启动所有在option中配置了class core和class main的Service。
例如下面的service在触发boot 子阶段时就会被启动。
```
service netd /system/bin/netd
class main
```

所以当execute_one_command（）在执行command命令时，就会启动这个service了。

上面提到 core和main ,那么什么是类型为“ core”的服务和类型为“ main”的服务？

core类型的服务有ueventd healthd console adbd servicemanager vold

main类型的服务有netd debuggerd ril-daemon surfaceflinger zygote drm media bootanim

installd flash_recovery raccoon mtpd keystore dumpstate sshd mdnsd

## init进程对属性服务的处理

系统启动时，由init初始化并开启属性服务， init对属性的处理分为3个部分

1、共享内存区的分配  
property_init 方法通过init_property_area方法来申请共享内存，以便于所有用户来
使用这块内存。
2、加载默认属性  
通过property_load_boot_defaults（）来初始化默认属性

3、触发属性服务相关的Action：
main()函数在设置好属性内存块之后，会调用queue_builtin_action()函数向内部的
action_list列表添加action节点。
```
queue_builtin_action(mix_hwrng_into_linux_rng_action,
"mix_hwrng_into_linux_rng");
queue_builtin_action(property_service_init_action, "property_service_init");
queue_builtin_action(queue_property_triggers_action,
"queue_property_triggers");
```
property_service_init_action 是触发属性的第一个方法代码位于init.c中。  
property_service_init_action()函数只是在简单调用start_property_service()而已，
后者的代码位于： core/init/Property_service.c

```
void start_property_service(void)
{
    int fd;
    load_properties_from_file(PROP_PATH_SYSTEM_BUILD);
    load_properties_from_file(PROP_PATH_SYSTEM_DEFAULT);
    /* Read vendor-specific property runtime overrides. */
    vendor_load_properties();
    load_override_properties();
    /* Read persistent properties after all default values have been loaded. */
    load_persistent_properties();
    fd = create_socket(PROP_SERVICE_NAME, SOCK_STREAM, 0666, 0, 0);
    if(fd < 0) return;
    fcntl(fd, F_SETFD, FD_CLOEXEC);
    fcntl(fd, F_SETFL, O_NONBLOCK);
    listen(fd, 8);
    property_set_fd = fd;
    }
```

tart_property_service()函数首先会调用load_properties_from_file()函数，尝试加载
一些属性脚本文件，并将其中的内容写入属性内存块里。从代码里可以看到，主要
加载的文件有：
```
/system/build.prop
/system/default.prop
/data/local.prop
/data/property目录里的若干脚本
```
property_service_init_action()动作中，系统已经把必要的属性都加载好了，那么
现在就可以遍历刚生成的action_list，进一步触发动作。
```
static int queue_property_triggers_action(int nargs, char **args)
{
    queue_all_property_triggers();
    /* enable property triggers */
    property_triggers_enabled = 1;
    return 0;
}
```
这样queue_property_triggers_action 就通过调用queue_all_property_triggers方法
来触发属性服务了，代码位于system/core/init/init_parser.c

当获取的属性名和属性值，与当初init.rc里记录的某action的激发条件匹配时，也就
是匹配以on property 开头的action.就把该action插入执行队列的尾部

（ action_add_queue_tail(act)），这样一个属性特征在action就被执行了。

### init进程之zygote

zyogte是android系统中一个重要的守护进程（Ｄaemon service）， android的app应
用都是java编写的，每一个应用都运行在自己的虚拟机中， android在最初启动时，会
首先创建一个zygote虚拟机，然后通过它fork 出其他的虚拟机进程，共享虚拟机内存
和框架层资源，这样提供应用程序的启动和运行速度

那么zygote的如何配置和启动的呢？

我们知道在android环境下的linux中，所有的进程都是init进程的子进程，也就是说，
所有的进程都是直接或者间接地由init进程fork出来的。 Zygote进程是在系统启动的过
程，由init进程创建的。在系统启动脚本system/core/rootdir/init.rc文件中，我们可以看
到启动Zygote进程的脚本命令（ android5.0一般会单独放在一个init.zygotexx_xx.rc文
件中）：
```
service zygote /system/bin/app_process64 -Xzygote /system/bin --zygote --startsystem-server
class main
socket zygote stream 660 root system
onrestart write /sys/android_power/request_state wake
onrestart write /sys/power/state on
onrestart restart media
onrestart restart netd
```

在前面的章节中，我们已经比较详细的介绍了init.rc的语法了，那么这里只做简单的
说明：
这里定义了一个service,名称为zygote.服务程序的路径是/system/bin/app_process64，
后面有４个参数，接下来的语句就是zygote需要一个socket资源,这个socket是用作本
地进程间通信的．
后面onrestart表示zygote进程重启时要执行的命令．
由于前面我们已经详细的介绍了service和action的加载和执行， zygote也是init.rc的
一个配置的service，所以这里就不做介绍，我们下面来分析一下zygote这个服务的
如何被执行的．
它的源代码位于frameworks/base/cmds/app_process/app_main.cpp文件中，入口
函数是main：
```
int main(int argc, char* const argv[])
{
    while (i < argc) {
        const char* arg = argv[i++];
        if (strcmp(arg, "--zygote") == 0) {
        zygote = true;
        niceName = ZYGOTE_NICE_NAME;
        } else if (strcmp(arg, "--start-system-server") == 0) {
        startSystemServer = true;
    .....
    if (zygote) {
        runtime.start("com.android.internal.os.ZygoteInit", args);
        } else if (className) {
        runtime.start("com.android.internal.os.RuntimeInit", args);
        } else {
    .....
}
```

app_main.cpp的main函数根据传入的参数－Xzygote设置虚拟机的选项，根据参数＂
--zygote＂来修改进程名称为zygote

我们在init.rc文件中，设置了app_process启动参数--zygote和--start-system-server

因此，在main函数里面，最终会执行下面语句：

runtime.start("com.android.internal.os.ZygoteInit", args);

这里的参数start-system-server为true，表示要启动Systemserver组件。由于
AppRuntime继承了父类AndroidRuntime,所以它的start函数其实是调用父类的方法，
因此，下面会执行AndroidRuntime类的start函数

AndroidRuntime.start这个函数定义frameworks/base/core/jni/AndroidRuntime.cpp
文件中：  
这个函数的作用是启动Android系统运行时库，它主要做了三件事情  
一是调用函数startVM启动虚拟机，  
二是调用函数startReg注册JNI方法，  
三是调用了com.android.internal.os.ZygoteInit类的main函数。

这样当ZygoteInit的main函数主要做了几件事情，完成了zygote的socket注册，预
加载class资源，预加载Resource资源，启动system_server．这样上层的java世界就
开启了

### Ueventd和watchdogd进程

ueventd进程是作什么用的呢？  
ueventd主要是负责设备节点的创建、权限设定等一些列工作。
服务通过使用uevent，监控驱动发送的消息，做进一步处理。
也就是说在某个时刻触发某个事件并通知给用户空间。

watchdogd进程是一个看门狗程序，它的任务就是定期向看门狗设备文件执行写操作，
以判断系统是否正常运行。

ueventd实际和init是同一个binary，走了不同分支,我们看一下mk文件
```
system/core/init/android.mk
SYMLINKS := \
$(TARGET_ROOT_OUT)/sbin/ueventd \
$(TARGET_ROOT_OUT)/sbin/watchdogd
```
我们可以看到可执行文件/sbin/ueventd和sbin/watchdogd是可执行文件/init的一个符
号链接文件。

我们来看一下init.rc中的配置文件：
```
on early-init
start ueventd
```
init在解析脚本的时候又启动了一个自己的进程，只是进程名变成了ueventd.  

```
int main(int argc, char **argv)
{
if (!strcmp(basename(argv[0]), "ueventd"))
return ueventd_main(argc, argv);
if (!strcmp(basename(argv[0]), "watchdogd"))
return watchdogd_main(argc, argv);
```
在init.c的main函数的参数argv的第一个， argv[0]为自身运行目录路径和程序名，这里
就根据这个条件来判断代码走的路径 。

当argv[0]为” ueventd”它真正的入口函数为ueventd_main，实现在
system/core/init/ueventd.c中。 ueventd进程会通过一个socket接口来和内核通信，以
便可以监控系统设备事件。

当argv[0] 为“watchdogd”，它真正的入口函数为watchdogd_main。这样在通过argv[0]
的参数就能判断后面到底是执行哪个进程。

Init的进程除了管理设备、解析并处理启动脚本init.rc、实时维护这个init.rc中的服务还
提供了性能统计分析功能，这就是bootchart， bootchart是一个性能统计工具，用于
搜集硬件和系统的信息，并将其写入磁盘，以便其分析性能。这里不详细分析。

至此， init的进程就分析完了。
