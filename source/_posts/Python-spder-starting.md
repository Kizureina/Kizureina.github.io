---
title: Python爬虫入门
date: 2022-01-04 13:19:14
tags: python
---
#### 无聊的前言
前几天溜阿松有点多，心血来潮想到一个有意思的炒作点子。但要实现需要几十个视频封面，虽然F12找图片直链很容易，但一个一个下实在有点麻烦，刚好在学python的requests库，就想写个爬虫全爬下来。

## 爬虫基本思路
爬虫有很多写法，Java，JavaScript，Python都可以，但python的requests库很方便，最常用的明显是python爬虫。在具体代码实现层面，大多数爬虫都有非常相似的结构:
1. 分析网页结构，找出有规律的接口
2. 利用requests库发起请求

这两个过程是通用的，但对下面的操作，静态网页与动态网页不同:

对静态网页，利用beautifulsoup库解析页面抓取内容
对动态网页，利用json库解析得到的json数据
静态网页即在浏览网页过程中没有浏览器与服务器交互的网页，此时Ctrl+u与F12审查元素得到的源码相同，直接发起请求，再用bs4库解析网页源码内容即可.

bs4库也是非常好用的python解析库，对于爬虫，找到需要爬取部分的网页源码，然后注意其周围唯一的元素名或class名再用find_all()具体解析即可。

例如:
```python
def find(url):
    web = requests.get(url, headers=headers)
    # 发起请求
    html = web.content.decode("utf-8")
    # 取得網頁內容
    soup = BeautifulSoup(html, "lxml")
    # 轉換成標籤樹 找頁面内DOM參數
    lis = soup.find_all('li', class_="small-item fakeDanmu-item")
    # class为python保留字，故需要用class_
    # small-item fakeDanmu-item为页面内唯一的class名
    url0 = lis[1].a.img['src']
    img_url = 'http://'+url0
    return img_url
```

但静态网页没有网页交互，且需要一次性加载出所有内容，较为不便。动态网页则没有这种劣势，动态网页利用Ajax不断发起对服务器的请求，无需刷新页面即可完成内容更新。

## 实战:爬取B站个人主页视频封面
本来准备用bs4解析页面，结果发现请求后找不到内容😓，才发现B站个人主页是Ajax动态网页

主页里的投稿列表是通过一个XHR(即Ajax的json请求)获取的，因此动态页面爬取反而更简单，只需要分析页面找到对应的api，对这个api发起请求获取json数据，再用json库转成python字典，就能轻松找到封面直链url。

```python
def find_url(url0, num0):
    web = requests.get(url0)
    data = json.loads(web.text)
    # 处理json数据
    pic_url = data["data"]["list"]["vlist"][num0]["pic"]
    return pic_url
```

上面这个函数的参数num0为变量，可以利用这个循环爬取内容，这样就取得了封面图片直链，下一步是将其下载至指定目录

```python
def download(url1, download_num):
    jpg = requests.get(url1, headers=headers)
    # 請求頁面
    f = open("azusa" + str(download_num) + ".jpg", 'wb')
    # 新建一个.jpg文件，文件名为azusa+数字(str函数将数组转为字符串)
    f.write(jpg.content)
    # 写入页面内容
    f.close()
    print('Pic saved!')

```

再在主函数里写入循环调用这两个函数即可，完整爬虫源码如下:

```python
# -*- coding:utf-8 -*-
# MyfirstPyScript
# coded by Yo1uk0
 
import requests
# from bs4 import BeautifulSoup
import json
 
path = "/mnt/c/workplace"
# 写入文件的目录
url = "https://api.bilibili.com/x/space/arc/search?mid=231590&ps=30&tid=0&pn=1&keyword=&order=click&jsonp=jsonp"
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
                  'Chrome/96.0.4664.110 Safari/537.36',
    'referer': 'https://space.bilibili.com/231590/video'}
# 有些页面有反爬措施，加正常浏览器的请求头可以一定程度反反爬
 
 
def find_url(url0, num0):
    web = requests.get(url0,headers=headers)
    data = json.loads(web.text)
    pic_url = data["data"]["list"]["vlist"][num0]["pic"]
    return pic_url
 
 
def download(url1, download_num):
    jpg = requests.get(url1, headers=headers)
    f = open("azusa" + str(download_num) + ".jpg", 'wb')
    f.write(jpg.content)
    f.close()
    print('Pic saved!')
 
 
def main():
    for num in range(30):
        url1 = find_url(url, num)
        download(url1, num)
    print('all pics are saved!')
 
 
if __name__ == '__main__':
    main()
```
![img](https://files.catbox.moe/3xpren.jpg)
大功告成。