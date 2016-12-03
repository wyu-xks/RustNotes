---
title: git 操作记录
date: 2016-02-19 22:11:36
category: Tools
tag: [Git]
toc: true
---
创建时间：2016-02-19

[TOC]

## git 创建一个新的空分支
```
git checkout --orphan newbranch
# 创建一个newbranch的分支，这个分支是独立的

git rm -rf .
```
此时得到的是一个空的分支，里面啥也没有

------
## 合并几个commit

http://hlee.iteye.com/blog/1897628
网上搜到的。

我用的是ubuntu14.04  git version 1.9.1

git log看一下想从哪个提交开始rebase，比如是xxstart00；这个commit xxstart00不会受影响

git rebase -i xxstart00

出现编辑界面，下面注释写的很清楚。

第一个commit不能改为squash，否则出现以下提示：

Cannot 'squash' without a previous commit

接下来想合并谁就合并谁，把pick改成squash

保存退出编辑后，自动切换到commit的编辑界面；这就是合并的那几个commit

------
## 设置git commit模板
创建模板文件，比如abc_template；编辑模板文件
```
Summary:

Module:
Modified:
```
命令行设置git：
```bash
$ git config --global commit.template $HOME/abc_template
```
设置的时候，要带上文件位置，否则会出现git找不到模板文件的错误  
--global表示全局设置

------
## git 设置远程分支
Ubuntu14.04 git version 1.9.1
对于用户来说，git给人提交到本地的机会。我们可以在自己的机器上创建不同的branch，来测试和存放不同的代码。
对于代码管理员而言，git有许多优良的特性。管理着不同的分支，同一套源代码可以出不一样的版本。

### 未跟踪远程分支
远程代码库新增了一个目录，repo sync下来后，在新增目录里新建一个分支
git pull时出现如下错误
```
Please specify which branch you want to merge with.
See git-pull(1) for details
    git pull <remote> <branch>
If you wish to set tracking information for this branch you can do so with:
    git branch --set-upstream-to=origin/<branch> project-dev
```

那么按照提示，先找到远程分支
```
$ git branch -a
* project-dev
  remotes/m/Project-dev -> origin/Project-dev
  remotes/origin/Project-dev
  remotes/origin/master
```

当前分支为project-dev；想要跟踪origin/Project-dev，输入以下命令：
```
$ git branch --set-upstream-to=origin/Project-dev project-dev
```
分支 project-dev 设置为跟踪来自 origin 的远程分支 Project-dev

设置后，git pull试一试
对于Github，新建一个仓库后会有提示
```
git remote add origin https://github.com/RustFisher/test.git
git push -u origin master
```
### 远程分支的操作
```
# 查看远程分支，会显示出远程分支名与url
$ git remote -v
origin    ssh://RustFisher@192.168.1.1:29418/workspace/product1 (fetch)
origin    ssh://RustFisher@192.168.1.1:29418/workspace/product1 (push)
```
这里采用gerrit来进行代码审核，用默认的29418端口

#### 如何添加远程分支？

使用git remote add指令，例如：
```
$ git remote add r1 ssh://RustFisher@192.168.1.1:29418/work
# 添加一个远程分支，url为ssh://RustFisher@192.168.1.1:29418/work；分支别名为r1
# 查看已有的远程分支
$ git remote -v
r1    ssh://RustFisher@192.168.1.1:29418/work (fetch)
r1    ssh://RustFisher@192.168.1.1:29418/work (push)
# 这时使用git pull同步代码，git会问你要分支名
$ git pull
fatal: 未指定远程版本库。请通过一个URL或远程版本库名指定，用以获取新提交。
# 我们可以选择从r1库同步代码
$ git pull r1
# 如果不想每次git pull都写上分支名，那么可以把远程分支命名为origin，git会默认从这里pull
$ git remote rm r1
# 看看还有没有远程分支r1
$ git remote -v
# 开始添加
$ git remote add origin ssh://RustFisher@192.168.1.1:29418/work
$ git remote -v
origin    ssh://RustFisher@192.168.1.1:29418/work (fetch)
origin    ssh://RustFisher@192.168.1.1:29418/work (push)
# 添加成功，pull一次试试
$ git pull
```

另一个工程里，查看所有分支，包括远程分支
```
$ git branch -a
* working
  remotes/origin/demo1
  remotes/origin/HEAD -> origin/master
  remotes/origin/demo2
  remotes/origin/demo3
  remotes/origin/working
  remotes/origin/master
  remotes/origin/tab1
```
#### 列出所有分支中，倒数5个
`$ git branch -a | head -5 `

#### 强制切换到分支
`$ git checkout -f [branch name] `

### 附录

用法：git remote [-v | --verbose]
   或：git remote add [-t <分支>] [-m <master>] [-f] [--tag|--no-tag] [--mirror=<fetch|push>] <名称> <url>
   或：git remote rename <旧名称> <新名称>
   或：git remote remove <名称>
   或：git remote set-head <名称> (-a | --auto | -d | --delete |<分支>)
   或：git remote [-v | --verbose] show [-n] <名称>
   或：git remote prune [-n | --dry-run] <名称>
   或：git remote [-v | --verbose] update [-p | --prune] [(<组> | <远程>)...]
   或：git remote set-branches [--add] <名称> <分支>...
   或：git remote set-url [--push] <名称> <新的地址> [<旧的地址>]
   或：git remote set-url --add <名称> <新的地址>
   或：git remote set-url --delete <名称> <地址>
    -v, --verbose         冗长输出；必须置于子命令之前

市面上有非常多的相关书籍和教程。我个人比较喜欢的是：
ProGit（中文版）    http://git.oschina.net/progit/  
关于git的master和origin    http://lishicongli.blog.163.com/blog/static/1468259020132125247302/
刚开始的时候我没注意master和origin这两个名称，直到操作远程分支的时候，我才有了比较多的了解

------

## git patch 使用方法
git提供了两种简单的patch方案。一是用git diff生成的标准patch，二是git format-patch生成的Git专用Patch。

### 1.git diff 生成的标准patch
有2个分支`master`与`other_branch`；切换到`other_branch`分支，做出修改后提交；
使用git diff命令生成patch文件，大于号后面那个即是patch文件名
切换到`master`分支，使用git apply命令打上patch001；即可看到文件被修改

```
rust@rust-pc:~/wd/TestPatch$ git commit -a -m "make change in other_branch"
rust@rust-pc:~/wd/TestPatch$ git diff master > patch001
rust@rust-pc:~/wd/TestPatch$ ls
a.txt  b.txt  patch001

rust@rust-pc:~/wd/TestPatch$ git checkout master
切换到分支 'master'

rust@rust-pc:~/wd/TestPatch$ git apply patch001

rust@rust-pc:~/wd/TestPatch$ git diff
diff --git a/a.txt b/a.txt
index e69de29..f335d6f 100644
--- a/a.txt
+++ b/a.txt
@@ -0,0 +1 @@
+change in patch
```
### 2.git format-patch 生成的git专用补丁
与前一种方法类似，在`other_branch`分支中产生提交后，使用git format-patch命令产生patch文件
回到`master`分支后用git am 命令打上patch
`other_branch`领先`master`几个commit，就会产生几个patch文件；这几个patch是相互独立的，可以单独打上

```
rust@rust-pc:~/wd/TestPatch$ git format-patch -M master
0001-make-change-in-other_branch.patch
0002-change2-in-other_branch.patch

rust@rust-pc:~/wd/TestPatch$ git checkout master
切换到分支 'master'

rust@rust-pc:~/wd/TestPatch$ git am 0001-make-change-in-other_branch.patch
正应用：make change in other_branch
```
要注意提交的顺序；如果跳过了某个提交，打后面的patch可能会产生错误
下面的patch 0002 和 0003 改的是同一个文件；应该按照顺序打patch
```
rust@rust-pc:~/wd/TestPatch$ git format-patch -M master
0001-make-change-in-other_branch.patch
0002-change2-in-other_branch.patch
0003-change3-in-other_branch-b.txt.patch

rust@rust-pc:~/wd/TestPatch$ git am 0003-change3-in-other_branch-b.txt.patch
正应用：change3 in other_branch : b.txt
error: 打补丁失败：b.txt:1
error: b.txt：补丁未应用
补丁失败于 0001 change3 in other_branch : b.txt
失败的补丁文件副本位于：
   /home/rust/wd/TestPatch/.git/rebase-apply/patch
当您解决了此问题后，执行 "git am --continue"。
如果您想跳过此补丁，则执行 "git am --skip"。
要恢复原分支并停止打补丁，执行 "git am --abort"。
```

以上两种方法中的`master`，都可以用提交hash值来代替。这样就不用另外开分支了。只要记住从哪个提交开始打patch
甚至是用远程分支名也可以
```
git format-patch -M origin/master
git format-patch origin/master
```

## git reset到上一个提交
git reset --hard HEAD

## git log 输出个性化
`git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative`
将其设置为快捷键 git lg
`git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"`
