---
title: Docker入门
date: 2023-01-30 20:03:16
tags: web
---

## 0x00 基本概念

Docker的意义是让搭环境更方便。

Docker 是一个应用打包、分发、部署的工具。

你也可以把它理解为一个轻量的虚拟机，但它只虚拟你软件需要的运行环境，而不虚拟硬件。一方面可以很方便的复制整个环境，一方面也可以防止污染本机环境。

复现漏洞时，部署环境用Docker会高效很多。实际上常用的漏洞平台Vulhub就是基于docker，kali中搭建Vulhub[参见](https://blog.csdn.net/weixin_45744814/article/details/120185420)。

### Container - 容器

**容器**是一个独立于系统内其他所有进程的进程，相当于一台运行起来的虚拟机，即你的软件或Web应用运行的环境。容器与镜像的关系类似于对象和类。

![Snipaste 2023 01 31 16 18 38](https://s1.ax1x.com/2023/01/31/pS085fH.md.png)

### Image - 镜像

镜像相当于一个虚拟机快照，其中包含了你要部署的应用程序和它所依赖的所有库，一个镜像可以创建多个容器。

一般情况下，你所运行的软件都依赖于某种解释器或容器，例如node，python，tomcat，nginx，redis等，因此Docker有大部分解释器的官方镜像，在Dockerfile中需要指定并安装该环境。

Docker在制作镜像时会缓存所有用到的环境，因此部署一次之后会快很多，这种操作成为**分层**。

### Dockerfile

将镜像创建为容器时，需要**安装各种环境并做各种配置**，Docker根据Dockerfile中指定的命令完成这个操作。[官方文档](https://docs.docker.com/engine/reference/builder/#run)

```dockerfile
# 基础镜像依赖
FROM python:3.8-slim-buster
# 指定后面命令的工作目录，如不存在则自动创建
WORKDIR /app
# 将本地所有文件拷贝进Docker镜像
COPY . .
# 安装依赖（Linux镜像中可用各种shell命令）,此时镜像已经为容器
RUN pip3 install requirements.txt
# 容器运行起来之后，需要执行的命令，即程序执行的入口
CMD ["python3","app.py"]
```

*实用技巧：
如果你写 Dockerfile 时经常遇到一些运行错误，依赖错误等，你可以直接运行一个依赖的底，然后进入终端进行配置环境，成功后再把做过的步骤命令写道 Dockerfile 文件中，这样编写调试会快很多。
例如环境为`node:11`，我们可以运行`docker run -it -d node:11 bash`，跑起来后进入容器终端配置依赖的软件，然后尝试跑起来自己的软件，最后把所有做过的步骤写入到 Dockerfile 就好了。
掌握好这个技巧，你的 Dockerfile 文件编写起来就非常的得心应手了。*

## 0x01 运行容器

以本博客的平台hexo为例，使用node:latest依赖，编写Dockerfile：

```dockerfile
# *****************************************************************************
# File Name: Dockerfile
# Auther: Kizureina
# Email: tsukionmito@mailfence.com
# Created Time: Jan 31 23:08:07 2023
# Description:
#
#     This bases on node:latest image
#
# *****************************************************************************
# 基础镜像
FROM node:latest
# 维护者信息
LABEL Kizureina tsukionmito@mailfence.com
# 复制代码
ADD . /app
# 设置容器启动后的默认运行目录
WORKDIR /app

# 安装hexo
RUN \ 
npm config set registry https://registry.npm.taobao.org \
&&npm install \
&&npm install hexo-cli -g \
&& npm install hexo-server --save \
&& npm install hexo-asset-image --save \
&& npm install hexo-wordcount --save \
&& npm install hexo-generator-sitemap --save \
&& npm install hexo-generator-baidu-sitemap --save \
&& npm install hexo-deployer-git --save

EXPOSE 4000

# 运行命令
CMD ["hexo","s"]
```



写好Dockerfile之后就可以运行容器了，先创建镜像：

```bash
docker build -t test:v1 .
```

再运行：

```bash
docker run -p 80:5000 -d test:v1
```

-p是映像端口，80为本机端口，即本机占用的端口；5000为容器端口。

-d是不让日志输出在控制台，即后台运行。

此时即可在80端口访问此应用了。

但注意，如果此时删除容器，会将所有数据删除。而且使用 Docker 运行后，我们改了项目代码不会立刻生效，需要重新`build`和`run`，很是麻烦。要解决需要**目录挂载**。

## 0x02 Docker常用命令

`docker ps` 查看当前运行中的容器
`docker images` 查看镜像列表
`docker rm container-id` 删除指定 id 的容器
`docker stop/start container-id` 停止/启动指定 id 的容器
`docker rmi image-id` 删除指定 id 的镜像
`docker volume ls` 查看 volume 列表
`docker network ls` 查看网络列表

## 0x03 目录挂载

![img](https://sjwx.easydoc.xyz/46901064/files/kv96dc4q.png)

目录挂载有三种方式：

1. `bind mount` 直接把宿主机目录映射到容器内，适合挂代码目录和配置文件。可挂到多个容器上
2. `volume` 由容器创建和管理，相当于一个**共享文件夹**，创建在宿主机，所以删除容器不会丢失，官方推荐，更高效，Linux 文件系统，适合存储数据库数据。可挂到多个容器上。（√）
3. `tmpfs mount` 适合存储临时文件，存宿主机内存中。不可多容器共享。

挂载到数据卷volume：

```bash
docker run -dp 80:5000 -v test-data:/etc/test test:v1
```

-v 后为挂载到数据卷的参数，/etc/test为数据卷目录，即将test-data挂载到了/etc/test这个目录下，此时向容器这个路径中**写入的任何数据都可以持久储存在数据卷中**。

*注意！
因为挂载后，容器里的代码就会替换为你本机的代码了，如果你代码目录没有`node_modules`目录，你需要在代码目录执行下`npm install --registry=https://registry.npm.taobao.org`确保依赖库都已经安装，否则可能会提示“Error: Cannot find module ‘koa’”
如果你的电脑没有安装 [nodejs](https://nodejs.org/en/)，你需要安装一下才能执行上面的命令。*

## 0x04 多容器通信

许多时候需要创建多个容器，例如Web项目和数据库，此时需要用到**容器间通信**。

通信需要用到虚拟网路，创建一个名为test-net的虚拟网络:

```bash
docker network create test-net
```

运行 Redis 在 `test-net` 网络中，别名`redis`:

```bash
docker run -d --name redis --network test-net --network-alias redis redis:latest
```

将连接redis的配置改为如下：

![img](https://sjwx.easydoc.xyz/46901064/files/kv98rfvb.png)

运行 Web 项目，使用同个网络:

```bash
docker run -p 8080:8080 --name test -v D:/test:/app --network test-net -d test:v1
```

此时就可以通信了。

## 0x05 Docker-Compose

实际上运行多个容器时，很少用到虚拟网络，而是用**Docker-compose**。

docker-compose能够把项目的多个服务集合到一起，一键运行。实际上前面提到的Vulhub也是用到docker-compose复现环境的。

使用dc需要用到`docker-compose.yml`配置文件，例如：

```yml
version: "3.7"

services:
  app:
    build: ./
    ports:
      - 80:8080
    volumes:
      - ./:/app
    environment:
      - TZ=Asia/Shanghai
  redis:
    image: redis:5.0.13
    volumes:
      - redis:/data
    environment:
      - TZ=Asia/Shanghai

volumes:
  redis:

```

这里用到了两个容器，即web应用和redis。

在配置文件所在目录运行：

```bash
docker-compose up -d
```

vulhub就是用这一命令完成环境搭建的。

### Docker-compose常用命令

查看运行状态：`docker-compose ps`
停止运行：`docker-compose stop`
重启：`docker-compose restart`
重启单个服务：`docker-compose restart service-name`
进入容器命令行：`docker-compose exec service-name sh`
查看容器运行log：`docker-compose logs [service-name]`
