---
title: Win7 Ubuntu 双系统折腾记
date: 2016-11-13 15:52:01
category: Tools
tag: [Linux]
---

新买了电脑，想要装个双系统。128G的SSD作为系统盘。先把Win7安装好。确认无误后，安装Ubuntu。

配置：NVIDIA 750Ti ，CPU i5 6500， 华硕B150M， Dell P2414

使用U盘安装Ubuntu16.04，这里不表。

这里遇到一个问题。开机进入系统引导后，选择ubuntu，启动后黑屏。而进入win7没问题。
原来以为和BIOS有关系。后来测试发现其实是Ubuntu显卡驱动的问题。

显示器接的是独显DP口。如果拔掉DP线，用VGA接到核显上，两个系统都能正确进入。如果双DP线，只能
进win7。

解决办法很简单。显示器用VGA接核显，启动Ubuntu。在“附加驱动”里面选择“使用NVIDIA binary driver....”
应用更改然后关机。显示器要接到独显上。两个系统都能正常使用。


遇到问题，列出可能性，一步步排查。

### 2016-11-18 更新
今天突然发现Ubuntu的空间不够。于是着手重装Ubuntu。

重新用U盘制作了安装盘。安装时总是遇到`input output ERROR`这个错误。网上一查，说是安装盘数据损坏。
重新做了一次安装盘，能顺利安装了。

这次安装这机械硬盘上。机械硬盘上压缩出150G的压缩卷。安装的时候给`/boot`分配了800M的空间。
装好Ubuntu后在win7下用EasyBCD做了一个新的引导。开机时可以选择启动的系统。