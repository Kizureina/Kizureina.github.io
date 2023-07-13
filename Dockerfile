# *****************************************************************************
# File Name: Dockerfile
# Auther: Kizureina
# Email: houchangkun@gmail.com
# Created Time: Jan 25 23:08:07 2023
# Description:
#
#     This bases on node:10 image
#
# *****************************************************************************


# 基础镜像
FROM node:latest

# 维护者信息
LABEL Kizureina houchangkun@gmail.com
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