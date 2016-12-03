---
title: 使用Cygwin问题汇总
date: 2016-06-25 09:17:33
category: Tools
tag: [Tools,Git]
toc: true
---

##### Windows下Cygwin使用git遇到的`^M`问题。

因Linux(LF)系统与Windows(CRLF)换行符不一样。可为项目增加`.gitattributes`来解决
```
# Set the default behavior, in case people don't have core.autocrlf set.
* text=auto

# Explicitly declare text files you want to always be normalized and converted
# to native line endings on checkout.
*.c text
*.h text

# Declare files that will always have CRLF line endings on checkout.
*.sln text eol=crlf

# Denote all files that are truly binary and should not be modified.
*.png binary
*.jpg binary
```

这样git会忽略换行符，仅仅提出警告。

或者修改Cygwin下的Git配置
```
[core]
autocrlf = true
```

#### Cygwin download site
Choose http://mirrors.neusoft.edu.cn
