---
title: QQbot油管开播推送API编写逻辑
date: 2022-01-30 13:33:05
tags: python
---

### 前言

如前所述，前段时间写完B站开播推送后，又陆陆续续修了一些bug加了几个功能，不过都比较无聊，最近又想写个404开播推送用来看holo，才发现这个项目相当有意思，和B站的推送完全不同。而且就我所知nonebot2没有推送404开播信息的插件，所以写下来给后来者参考。当然致命的问题仍然是**没用异步**，很容易阻塞。

## 基本逻辑和关键源码

F12监听网络找了半天，终于找到了直播状态相关的url接口，也就是https://www.youtube.com/youtubei/v1/updated_metadata?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8
油管的直播页面与B站一样是Ajax动态页面，不过直播信息的XHR文件并非是GET请求，而是POST请求方式，所以自然也无法通过改变url获取不同管人的直播信息。
没办法，只能通过对比不同页面内以POST方式发送的JSON文件，来找到底是通过哪个参数确定特定管人了。

油管的管人与B站UP主有UID类似，频道主页也有一个唯一固定的参数，即频道ID，因此我一开始以为多半是依据这个确定管人。然而从HTTP请求头的referer到JSON文件内的具体参数，改了发现都对响应毫无影响，更麻烦的是**同一管人不同直播，在页面内对api发起请求获取的响应居然也不同**。

直播页面(当然进入直播页面的来源不同，发起请求也会有区别)对API接口发起POST请求发送的JSON文件为：

```json
{
    "context": {
        "client": {
            "hl": "zh-CN",
            "gl": "US",
            "remoteHost": "104.238.183.19",
            "deviceMake": "",
            "deviceModel": "",
            "visitorData": "CgtvMXpSUVRfTllXVSje7L6PBg%3D%3D",
            "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:96.0) Gecko/20100101 Firefox/96.0,gzip(gfe)",
            "clientName": "WEB",
            "clientVersion": "2.20220124.01.00",
            "osName": "Windows",
            "osVersion": "10.0",
            "originalUrl": "https://www.youtube.com/watch?v=PVCEhD6zyXs",
            "screenPixelDensity": 1,
            "platform": "DESKTOP",
            "clientFormFactor": "UNKNOWN_FORM_FACTOR",
            "configInfo": {
                "appInstallData": "CN7svo8GELvH_RIQt8utBRCA6q0FEJjqrQUQveutBRDYvq0FEJH4_BI%3D"
            },
            "screenDensityFloat": 1.25,
            "userInterfaceTheme": "USER_INTERFACE_THEME_DARK",
            "timeZone": "Asia/Shanghai",
            "browserName": "Firefox",
            "browserVersion": "96.0",
            "screenWidthPoints": 1536,
            "screenHeightPoints": 26,
            "utcOffsetMinutes": 480,
            "mainAppWebInfo": {
                "graftUrl": "https://www.youtube.com/watch?v=PVCEhD6zyXs",
                "webDisplayMode": "WEB_DISPLAY_MODE_BROWSER",
                "isWebNativeShareAvailable": False
            }
        },
        "user": {
            "lockedSafetyMode": False
        },
        "request": {
            "useSsl": True,
            "consistencyTokenJars": [{
                "encryptedTokenJarContents": "AGDxDePLfe_Lq5NyjA1C5nhEksdINB4VL5EcmFaVNVkqUw-0KdV0PXj-PJef54WriipjpEy-gey1ewetVkOf35qV8ET_YapXqWrpXpvD0Trxq9f4Mg35UouxGk92w1gNkDmmgIbgmaUQRlaGW1uEj384"
            }],
            "internalExperimentFlags": []
        },
        "clickTracking": {
            "clickTrackingParams": "CLkCEMyrARgAIhMI_NrTw7_M9QIVVEhMCB2ACgrN"
        },
        "adSignalsInfo": {
            "params": [{
                "key": "dt",
                "value": "1643099758577"
            }, {
                "key": "flash",
                "value": "0"
            }, {
                "key": "frm",
                "value": "0"
            }, {
                "key": "u_tz",
                "value": "480"
            }, {
                "key": "u_his",
                "value": "2"
            }, {
                "key": "u_h",
                "value": "864"
            }, {
                "key": "u_w",
                "value": "1536"
            }, {
                "key": "u_ah",
                "value": "864"
            }, {
                "key": "u_aw",
                "value": "1536"
            }, {
                "key": "u_cd",
                "value": "24"
            }, {
                "key": "bc",
                "value": "31"
            }, {
                "key": "bih",
                "value": "26"
            }, {
                "key": "biw",
                "value": "1519"
            }, {
                "key": "brdim",
                "value": "-7,-7,-7,-7,1536,0,1550,878,1536,26"
            }, {
                "key": "vis",
                "value": "2"
            }, {
                "key": "wgl",
                "value": "true"
            }, {
                "key": "ca_type",
                "value": "image"
            }]
        }
    },
    "videoId": "19bPJuW3hlc"
}
```

测试了半天后才发现真正的决定特定管人的参数是JSON文件的"videoId"，404直播页面的直播流推送与B站不同，并非flash video格式即时推送，而是每次直播新建一次正常的视频页面，视频页面每次随机分配或者通过某种对时间戳的加密获取唯一确定的视频ID，json文件最后的"videoId"参数就是当前直播所分配视频ID。

所以问题就转化为如何**循环发起请求获取每次直播的视频ID**，这是个麻烦活，似乎只能再找个人主页内的XHR，不过我查了下发现404一个有意思的**重定向**：如果当前频道正在直播或者有预约直播(即新建了一个视频并获取了视频ID)，**在频道主页URL后加\'/live\'会重定向至直播页面**，若非则反向代理回当前页面。

这下就好办了，只要不断对url+/live发起请求，并获取重定向后的url，就能获取当前直播的视频ID。而获取重定向后的url可以通过requests的属性获取。

```python
import requests
 
url0 = input('Please input the channel url:')
url = url0 + '/live'
r = requests.get(url)
url_re = r.url
```

不过奇怪的是居然还是只能获取/live的url，用`r.history`对象也没成功，不过看`r.text`却确实是重定向之后的直播页面。

当然也有办法，虽然直播页面是动态页面，但也有基本的html结构，其中一般也会有当前页面的url，用**BeautifulSoup**库解析即可:

```python
import requets
from bs4 import BeautifulSoup
 
url0 = input('Please input the channel url:')
url = url0 + '/live'
r = requests.get(url)
html = r.content.decode("utf-8")
soup = BeautifulSoup(html, "lxml")
links = soup.find_all('link', rel="canonical")
# 查找所有含url的link元素
url_re = links[0]['href']
```

然后操作字符串传参给data字典，再用json库解析，再用requests库发送json文件即可:

```python
import json
import requests
 
apiurl = 'https://www.youtube.com/youtubei/v1/updated_metadata?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8'
r = requests.post(apiurl, headers=h, data=json.dumps(data))
```

然后就是再加个操作字符串的判断，来确定是否是直播预告。

至此就大功告成了，再加上操作数据库和nonebot2框架引入的所需包，完整源码如下：

```python
from email import message
from nonebot import require, get_bot
import requests
import json
from bs4 import BeautifulSoup
import sqlite3
scheduler = require('nonebot_plugin_apscheduler').scheduler
 
 
@scheduler.scheduled_job('interval', minutes=4, id='ytb404')
async def azuma_ytb_live_pusher():
    h = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:96.0) Gecko/20100101 Firefox/96.0',
        'Origin': 'https://www.youtube.com',
        'Content-Type': 'application/json',
        'host': 'www.youtube.com',
    }
    bot = get_bot()
 
    url = 'https://www.youtube.com/channel/UCEuqN76-F2rl1-08aGt8siA'
    # Seren Azuma
    con = sqlite3.connect(r"/root/nonebot/Seren/seren/plugins/times.db")
    cur = con.cursor()
    cur.execute('SELECT * FROM times')
    data = cur.fetchone()
    push_time = data[0]
 
    r = requests.get(url + '/live')
    html = r.content.decode("utf-8")
    soup = BeautifulSoup(html, "lxml")
    links = soup.find_all('link', rel="canonical")
    url0 = links[0]['href']
    if url == url0:
        cur.execute("UPDATE times SET id=0 WHERE name='times'")
        con.commit()
    else:
        if push_time == 1:
            cur.close()
            con.close()
        else:
            cur.execute("UPDATE times SET id=1 WHERE name='times'")
            con.commit()
            vid = format(url0.replace('https://www.youtube.com/watch?v=', ''))
            data = {
                "context": {
                    "client": {
                        "hl": "zh-CN",
                        "gl": "US",
                        "remoteHost": "104.238.183.19",
                        "deviceMake": "",
                        "deviceModel": "",
                        "visitorData": "CgtvMXpSUVRfTllXVSje7L6PBg%3D%3D",
                        "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:96.0) Gecko/20100101 Firefox/96.0,gzip(gfe)",
                        "clientName": "WEB",
                        "clientVersion": "2.20220124.01.00",
                        "osName": "Windows",
                        "osVersion": "10.0",
                        "originalUrl": "https://www.youtube.com/watch?v=PVCEhD6zyXs",
                        "screenPixelDensity": 1,
                        "platform": "DESKTOP",
                        "clientFormFactor": "UNKNOWN_FORM_FACTOR",
                        "configInfo": {
                            "appInstallData": "CN7svo8GELvH_RIQt8utBRCA6q0FEJjqrQUQveutBRDYvq0FEJH4_BI%3D"
                        },
                        "screenDensityFloat": 1.25,
                        "userInterfaceTheme": "USER_INTERFACE_THEME_DARK",
                        "timeZone": "Asia/Shanghai",
                        "browserName": "Firefox",
                        "browserVersion": "96.0",
                        "screenWidthPoints": 1536,
                        "screenHeightPoints": 26,
                        "utcOffsetMinutes": 480,
                        "mainAppWebInfo": {
                            "graftUrl": "https://www.youtube.com/watch?v=PVCEhD6zyXs",
                            "webDisplayMode": "WEB_DISPLAY_MODE_BROWSER",
                            "isWebNativeShareAvailable": False
                        }
                    },
                    "user": {
                        "lockedSafetyMode": False
                    },
                    "request": {
                        "useSsl": True,
                        "consistencyTokenJars": [{
                            "encryptedTokenJarContents": "AGDxDePLfe_Lq5NyjA1C5nhEksdINB4VL5EcmFaVNVkqUw-0KdV0PXj-PJef54WriipjpEy-gey1ewetVkOf35qV8ET_YapXqWrpXpvD0Trxq9f4Mg35UouxGk92w1gNkDmmgIbgmaUQRlaGW1uEj384"
                        }],
                        "internalExperimentFlags": []
                    },
                    "clickTracking": {
                        "clickTrackingParams": "CLkCEMyrARgAIhMI_NrTw7_M9QIVVEhMCB2ACgrN"
                    },
                    "adSignalsInfo": {
                        "params": [{
                            "key": "dt",
                            "value": "1643099758577"
                        }, {
                            "key": "flash",
                            "value": "0"
                        }, {
                            "key": "frm",
                            "value": "0"
                        }, {
                            "key": "u_tz",
                            "value": "480"
                        }, {
                            "key": "u_his",
                            "value": "2"
                        }, {
                            "key": "u_h",
                            "value": "864"
                        }, {
                            "key": "u_w",
                            "value": "1536"
                        }, {
                            "key": "u_ah",
                            "value": "864"
                        }, {
                            "key": "u_aw",
                            "value": "1536"
                        }, {
                            "key": "u_cd",
                            "value": "24"
                        }, {
                            "key": "bc",
                            "value": "31"
                        }, {
                            "key": "bih",
                            "value": "26"
                        }, {
                            "key": "biw",
                            "value": "1519"
                        }, {
                            "key": "brdim",
                            "value": "-7,-7,-7,-7,1536,0,1550,878,1536,26"
                        }, {
                            "key": "vis",
                            "value": "2"
                        }, {
                            "key": "wgl",
                            "value": "true"
                        }, {
                            "key": "ca_type",
                            "value": "image"
                        }]
                    }
                },
                "videoId": vid
            }
 
            apiurl = 'https://www.youtube.com/youtubei/v1/updated_metadata?key=AIzaSyAO_FJ2SlqU8Q4STEHLGCilw_Y9_11qcW8'
            r = requests.post(apiurl, headers=h, data=json.dumps(data))
            r_json = json.loads(r.text)
            title = r_json["actions"][3]['updateTitleAction']['title']['runs'][0]['text']
            last_live = r_json['actions'][2]['updateDateTextAction']['dateText']['simpleText']
            img_url = str('https://i.ytimg.com/vi/'+vid+'/hqdefault_live.jpg')
            cq = "[CQ:image,file="+ img_url + ",id=40000]"
            userid = ***********
            try:
                person = r_json['actions'][0]['updateViewershipAction']['viewCount']['videoViewCountRenderer']['viewCount']['simpleText']
                if '预定发布' in last_live:
                    cur.close()
                    con.close()
                else:
                    cur.execute("UPDATE times SET id=1 WHERE name='times'")
                    con.commit()
                    cur.execute("SELECT * FROM users")
                    objj = cur.fetchall()
                    u_num = len(objj)
                    for i in range(0,u_num):
                        userid = objj[i][1]
                        await bot.send_private_msg(user_id=userid,message=cq)
                        await bot.send_private_msg(user_id=userid, message=f"莲宝在404开播啦！有兴趣可以去看哦\n直播标题：{title}\n直播链接：{url}\n{last_live}\n当前同接：{person}")
            except:
                if '预定发布' in last_live:
                    cur.close()
                    con.close()
                else:
                    cur.execute("UPDATE times SET id=1 WHERE name='times'")
                    con.commit()
                    cur.execute("SELECT * FROM users")
                    objj = cur.fetchall()
                    u_num = len(objj)
                    for i in range(0,u_num):
                        userid = objj[i][1]
                        await bot.send_private_msg(user_id=userid,message=cq)
                        await bot.send_private_msg(user_id=userid, message=f"莲宝在404开播啦！有兴趣可以去看哦\n直播标题：{title}\n直播链接：{url}\n{last_live}")
```
