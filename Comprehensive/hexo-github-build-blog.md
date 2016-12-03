---
title: 使用hexo搭建github博客
date: 2016-12-03 11:12:33
category: Tools
tag: [Tools,Hexo,Github]
---
github 博客实际上是一个静态页面。

参考：
http://www.ruanyifeng.com/blog/2012/08/blogging_with_jekyll.html  
hexo工具 http://www.jianshu.com/p/465830080ea9  
下载 node.js https://nodejs.org/en/  
Hexo搭建博客过程 http://www.cnblogs.com/zhcncn/p/4097881.html  

win10系统下载安装了nodejs后，使用git bash尝试npm没反应。  
原因：nodeJs没有安装在默认的C盘目录下，而是装在了D盘。  
解决办法：  
修改系统环境变量path中关于npm的路径`D:\nodeJS\node_modules\npm`

在git bash中运行`npm install -g hexo`后，hexo工具装在了  
`C:\Users\Administrator\AppData\Roaming\npm`

在F盘初始化一个hexo
```
Administrator@Rust MINGW32 /f/Hexo$ hexo init
// output sth...
INFO  Start blogging with Hexo!  
Administrator@Rust MINGW32 /f/Hexo
$ hexo server
INFO  Start processing
INFO  Hexo is running at http://localhost:4000/. Press Ctrl+C to stop.  
```

重启电脑之后，hexo找不到命令。到系统环境变量path，添加hexo的路径。  
然后重启`git bash`

在hexo new文章时，需要stop server。可以这样增加一篇博客：
```
Administrator@Rust MINGW32 /f/Hexo
$ hexo new "My rust blog"
INFO  Created: F:\Hexo\source\_posts\My-rust-blog.md  
```
执行下面的命令，将markdown文件生成静态网页。生成css，png等等文件。
```
Administrator@Rust MINGW32 /f/Hexo
$ hexo generate  
```
配置`_config.yml`文件；我用的是https，没有使用ssh：
```
# Deployment
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type: git
  repository: https://github.com/RustFisher/rustfisher.github.io.git
  branch: master
```
配置完毕，在`git bash`输入：
```
Administrator@Rust MINGW32 /f/Hexo
$ hexo deploy
```
会弹出open SSH窗口问你要github的账户和密码  
输入账户和密码后，即可看到
```
To https://github.com/RustFisher/rustfisher.github.io.git
 * [new branch]      HEAD -> master
INFO  Deploy done: git
```
访问博客：http://rustfisher.github.io/ 可以看到效果  
每次在本地部署和生成都要输入github账户和密码。

自己下载主题Theme和hexo是配合起来使用的。  
比如主题中有一个链接是`about`，那么我们要自己弄一个界面给它
```
Administrator@Rust MINGW32 /f/Hexo
$ hexo new page 'about'
INFO  Created: F:\Hexo\source\about\index.md
```
然后去修改`Hexo\source\about\index.md` 即可

文章可以用git管理起来。

#### Use git bash instead of Cygwin

Cygwin would post error when I try to use hexo
```
$ hexo
module.js:327
    throw err;
    ^

Error: Cannot find module 'D:\cygdrive\c\Users\Administrator\AppData\Roaming\npm\node_modules\hexo\bin\hexo'
    at Function.Module._resolveFilename (module.js:325:15)
    at Function.Module._load (module.js:276:25)
    at Function.Module.runMain (module.js:441:10)
    at startup (node.js:139:18)
    at node.js:968:3
```
But git bash is OK

#### 使用ssh免输入账户和密码
前面设置的时候使用的是http，每次部署都要输入账户和密码，非常麻烦。
换成ssh比较方便一些。

本机是win10，使用git bash。  
在本机生成一个ssh key，在 ~/.ssh里面；复制公钥并添加到github上。

修改本地Hexo博客目录下的`_config.xml`

```
# ......
# Deployment
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type: git
  repository: git@github.com:UserName/UserName.github.io.git
  branch: master
```

这样就不会每次部署都要输入账户和密码了

### 2016-11-12 update
Hexo in Ubuntu is faster!!!
