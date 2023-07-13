---
title: 基于nonebot2框架的插件编写——开播信息推送
date: 2022-01-18 20:46:43
tags: python
---

之前写爬虫的时候想找B站的直播流接口抓源，结果发现了个人主页有个监听直播间状态的XHR，就心血来潮想写个开播提醒的QQ机器人，顺便研究了下现有的机器人框架。

## go-cqhttp协议层和nonebot2框架层搭建

查了下才发现之前大名鼎鼎的酷Q已经是昨日黄花了，不过现在也有较为完整的QQbot协议onebot了，综合考虑了下决定用比较简单的GO-CQhttp搭建，具体的搭建很容易，查文档就行，具体就是找相应的下下来再**改个yml配置文件**，为了方便下面api文件的编写，最好用websocket反向代理。

Websocket是与http不同的另一种协议，优势是可以做到双向的通信，在推送上比用HTTP更高效，不过websocket不能用一般的Flask编写后端，再加上直接写后端api可扩展性不好，因此就用[nonebot2](https://github.com/nonebot/nonebot2)的框架好了，具体的搭建参考文档即可，其实就是pip下依赖和修改配置文件，之后的插件调用在bot.py修改。

简单解释下cqhttp与nonebot2的关系，cqhttp是onebotQQ机器人协议的具体Go实现，运行在服务器的端口，将QQ服务器发送至机器人QQ号的内容进行符合onebot协议的**封装处理**，处理后的数据经反向代理发送至后端，nonebot2是后端的机器人框架，可以利用cqhttp协议中的对象完成数据处理和实现具体的api操作，经过处理后再将内容返回CQhttp并发送给QQ服务器。

## 基于python的具体api插件编写

如前所述，**QQ机器人的协议层和框架层已经搭建好了**，之后才是真正的api插件编写。为了性能更好，nonebot2的api编写用的**python异步编程**，我对异步不了解，但并不影响具体的api实现，只是性能差点。方便起见，先写个自动同意加好友和加群请求的插件:

```python
from nonebot import on_request
from nonebot.adapters.cqhttp import Bot, FriendRequestEvent, GroupRequestEvent
# 查cqhttp和nonebot2文档得知请求是这两个对象
from nonebot.typing import T_State
# import实现该api所需的对象和包
 
friend_req = on_request(priority=5)
# 定义事件响应器，priority表示响应次序，1-5递增
@friend_req.handle()
async def friend_agree(bot: Bot, event: FriendRequestEvent, state: T_State):
    # 实例化Bot等对象
    await bot.set_friend_add_request(flag=event.flag, approve=True)
    # 调用bot对象中的set_friend_add_request()方法，并赋值相应参数(查文档得)为同意
group_invite = on_request(priority=5)
@group_invite.handle()
async def group_agree(bot: Bot, event: GroupRequestEvent, state: T_State):
    await bot.set_group_add_request(flag=event.flag, sub_type='invite', approve=True)
```

async def定义异步函数，await异步执行操作，具体的框架编写标准写在注释里了。事件响应器，响应规则，时间处理器之类的概念**查文档**即可，框架官方文档永远是最重要的参考资料。

之后就开播信息推送api的编写了，先想思路: **首先得找到B站推送开播信息的api接口，然后每隔一段时间对这个接口发起请求，判断是否开播，开播即推送开播信息，未开播则结束程序等待下一次请求。**

思路很清晰，先找api接口，直播时会在个人主页页面将置顶视频换为直播间链接，找了下果然在一个XHR里有个json是直播间数据，liveStatus为0时未开播，为1时在直播中。这个接口直链为https://api.bilibili.com/x/space/acc/info?mid=1265680561&jsonp=jsonp 其中mid的参数是uid。

然后是定时执行任务的插件，用nonebot_plugin_apscheduler即可，跨插件访问可以参考[nonebot2文档](https://v2.nonebot.dev/api/nonebot.html)的教程。然后就是**requests**和**json**库请求和处理json数据，并返回相应的结果。

```python
from nonebot import on_command, require, get_bot
import requests
import json
import sqlite3
import _thread
scheduler = require('nonebot_plugin_apscheduler').scheduler
 
@scheduler.scheduled_job('interval', minutes=2, id='live')
# 每隔两分钟请求一次该接口
async def lives_pusher():
    bot = get_bot()
    # 实例化bot对象，否则无法主动发送信息
    v_id = 1111111111
    group_id = 659332197
    # 群号
    url0 = 'https://api.bilibili.com/x/space/acc/info?mid='
    url = url0 + str(v_id) + '&jsonp=jsonp'
    r = requests.get(url)
    r_json = json.loads(r.text)
    # 将json数据转化为python对象
    live_status = r_json['data']['live_room']['liveStatus']
    if live_status == 1:
        title = r_json['data']['live_room']['title']
        live_url = r_json['data']['live_room']['url']
        img_url = r_json['data']['live_room']['cover']
        cq = "[CQ:image,file=" + img_url + ",id=40000]"
        name = r_json['data']['name']
        await bot.send_group_msg(group_id=group_id, message=cq)
        await bot.send_group_msg(group_id=group_id, message=(f"你推的{name}开播啦!\n直播标题:{title}\n链接:{live_url}"))
    else:
        continue
```

思路很清晰，写起来也容易，但测试了下发现明显有个麻烦的问题，**推送后无法终止**，只会在下一次启动时再推送，倒是可以用sleep(6000)，不过就无法在终止时间内监听直播状态了。而且这样写也只能推送一个V的直播。

想了想，因为在这个python文件内的变量在程序终止后都会清除，应该只能用数据库了，方便起见用的**sqlite3**，[sqlite3增删改查操作](https://www.cnblogs.com/desireyang/p/12102143.html)。

既然用了数据库，干脆也加个**前端加数据**的api插件好了，顺便熟悉下python操作sqlite3数据库:
先在shell用`python3`进入命令行操作python，在目标目录用sql新建个库和表，再插入一条简单事例记录

```python
import sqlite3
con = sqlite3.connect('vtb.db')
# 若不存在会自动在当前目录新建
cur = con.cursor()
sql = "CREATE TABLE IF NOT EXISTS uid(id INTEGER PRIMARY KEY,uid TEXT,push_times INTEGER)"
cur.execute(sql)
# 创建表，表中三个列分别是序号，uid，是否推送过(只有0和1两个值)
cur.execute('INSERT INTO uid VALUES(?,?,?)', (128,11111111,0))
con.commit()
# 插入数据，序号128是为方便后面逆序插入
```

然后就是编写具体api插件

```python
import sqlite3
add = on_command("add", aliases={"add","添加推送"}, priority=5, rule=to_me())
# 命令的事件响应器为add，事件响应规则to_me()是只有@bot才会响应
async def add_pusher(bot: Bot, event: Event, state: T_State):
    con = sqlite3.connect('/root/nonebot/Seren/seren/plugins/vtb.db')
    # 新建数据库连接
    cur = con.cursor()
    # 新建操作数据库的游标
```

从**cqhttp对象内获取发送信息内的uid**(查文档得知具体的对象名)，并将其插入数据库

```python
    uid = str(event.get_message())
    cur.execute("SELECT * FROM uid")
    data = cur.fetchall()
    num = data[1][0] - 1
    # 从表内查找最近一条记录的序号并减一作为插入数据的序号
    cur.execute('INSERT INTO uid VALUES(?,?,?)', (num,uid,0))
    con.commit()
    cur.close()
    con.close()
    await add.send(Message(str(uid))+"已添加至推送列表")
```

然后再用try-except加个简单的异常处理，防止前端添加的数据不是int在之后遍历时报错:

```python
from nonebot import on_command
from nonebot.typing import T_State
from nonebot.rule import to_me
from nonebot.adapters import Bot, Event
from nonebot.adapters.cqhttp.message import Message
import sqlite3
add = on_command("add", aliases={"add","添加推送"}, priority=5, rule=to_me())
 
@add.handle()
async def add_pusher(bot: Bot, event: Event, state: T_State):
    con = sqlite3.connect('/root/nonebot/Seren/seren/plugins/vtb.db')
    cur = con.cursor()
    try:
        message = str(event.get_message())
        uid = int(message)
        # 如果message内不是数字，会在这一步报错并执行except内的操作
        cur.execute("SELECT * FROM uid")
        data = cur.fetchall()
        num = data[1][0] - 1
        cur.execute('INSERT INTO uid VALUES(?,?,?)', (num,uid,0))
        con.commit()
        cur.close()
        con.close()
        await add.send(Message(str(uid))+"已添加至推送列表")
    except:
        cur.close()
        con.close()
        await add.send("请输入UID😅")
```

之后就是推送api的编写，其实就是加上数据库操作和循环遍历，完整插件源码:

```python
from nonebot import on_command, require, get_bot
import requests
import json
import sqlite3
import _thread
scheduler = require('nonebot_plugin_apscheduler').scheduler
 
@scheduler.scheduled_job('interval', minutes=2, id='live')
async def lives_pusher():
    bot = get_bot()
    # u_id = **********
    group_id = *************
 
    con = sqlite3.connect(r"/root/nonebot/Seren/seren/plugins/vtb.db")
    cur = con.cursor()
    cur.execute("SELECT * FROM uid")
    obj = cur.fetchall()
    v_num = len(obj)
    # 获取表内有多少条记录，以确定循环次数
    for i in range(1, v_num):
        v_id = obj[i][1]
        url0 = 'https://api.bilibili.com/x/space/acc/info?mid='
        url = url0 + str(v_id) + '&jsonp=jsonp'
        r = requests.get(url)
        r_json = json.loads(r.text)
        live_status = r_json['data']['live_room']['liveStatus']
        v_id = obj[i][1]
        push_times = obj[i][2]
        if live_status == 1:
            if push_times == 0:
                cur.execute("UPDATE uid SET pusht=1 WHERE uid='%d'"%v_id)
                con.commit()
                title = r_json['data']['live_room']['title']
                live_url = r_json['data']['live_room']['url']
                img_url = r_json['data']['live_room']['cover']
                cq = "[CQ:image,file=" + img_url + ",id=40000]"
                name = r_json['data']['name']
                await bot.send_group_msg(group_id=group_id, message=cq)
                await bot.send_group_msg(group_id=group_id, message=(f"你推的{name}开播啦!\n直播标题:{title}\n链接:{live_url}"))
                await bot.send_private_msg(user_id=user_id, message=cq)
                await bot.send_private_msg(user_id=user_id, message=(f"你推的{name}开播啦!\n直播标题:{title}\n链接:{live_url}"))
            else:
                continue
        else:
            cur.execute("UPDATE uid SET pusht=0 WHERE uid='%d'"%v_id)
            con.commit()
```

测试下，效果如下图：
[![img](https://view.moezx.cc/images/2018/05/13/image-404.png)](https://kusarinoshojo.space/wp-content/uploads/2022/01/wp_editor_md_cbe12b4a919366ada1e5dc50e06d620d.jpg)
[![img](https://view.moezx.cc/images/2018/05/13/image-404.png)](https://kusarinoshojo.space/wp-content/uploads/2022/01/wp_editor_md_3c0c3bae0bf4a479daae62351777b152.jpg)
大功告成咯。

------

本来想自己用，不过前几天看有人说开播提醒群之类的，就想稍微改改能批量发送推从信息:
添加推送的用户：

```python
from nonebot import on_command
from nonebot.typing import T_State
from nonebot.rule import to_me
from nonebot.adapters import Bot, Event
from nonebot.adapters.cqhttp.message import Message
import sqlite3
adduser = on_command("add_user", aliases={"adduser","添加用户"}, priority=5, rule=to_me())
 
@adduser.handle()
async def add_user(bot: Bot, event: Event, state: T_State):
        con = sqlite3.connect('/root/nonebot/Seren/seren/plugins/times.db')
        cur = con.cursor()
        try:
            message = str(event.get_message())
            qqid = int(message)
            cur.execute("SELECT * FROM users")
            data = cur.fetchall()
            num = data[0][0] - 1
            cur.execute('INSERT INTO users VALUES(?,?)', (num,qqid))
            con.commit()
            cur.close()
            con.close()
            await adduser.send(Message(str(qqid))+"已添加至推送列表")
        except:
            await adduser.send("格式错误!请输入QQ号捏~")
~
```

推送api：

```python
from nonebot import on_command, require, get_bot
from nonebot.typing import T_State
from nonebot.adapters import Bot, Event
from nonebot.adapters.cqhttp.message import Message
import nonebot.adapters.cqhttp
import requests
import json
import time
import sqlite3
import _thread
 
scheduler = require('nonebot_plugin_apscheduler').scheduler
 
@scheduler.scheduled_job('interval', minutes=2, id='Seren')
async def live_pusher():
    bot = get_bot()
    con = sqlite3.connect(r"/root/nonebot/Seren/seren/plugins/times.db")
    cur = con.cursor()
    cur.execute('SELECT * FROM times')
    data = cur.fetchone()
    push_times = data[0]
 
    v_id = 1437582453
    # 莲宝B站uid
    url0 = 'https://api.bilibili.com/x/space/acc/info?mid='
    url = url0 + str(v_id) + '&jsonp=jsonp'
    r = requests.get(url)
    r_json = json.loads(r.text)
    live_status = r_json['data']['live_room']['liveStatus']
    if live_status == 1:
        if push_times == 0:
            cur.execute("UPDATE times SET id=1 WHERE name='times'")
            con.commit()
            cur.execute("SELECT * FROM users")
            objj = cur.fetchall()
            u_num = len(objj)
            title = r_json['data']['live_room']['title']
            live_url = r_json['data']['live_room']['url']
            img_url = r_json['data']['live_room']['cover']
            cq = "[CQ:image,file="+ img_url + ",id=40000]"
            for i in range(0,u_num):
                userid = objj[i][1]
                await bot.send_private_msg(user_id=userid, message=cq)
                await bot.send_private_msg(user_id=userid, message=(f"莲宝开播啦!\n直播标题:{title}\n链接:{live_url}"))
            cur.close()
            con.close()
        else:
            cur.close()
            con.close()
    else:
        cur.execute("UPDATE times SET id=0 WHERE name='times'")
        con.commit()
        cur.close()
        con.close()
```

第一次因为没测试出了个麻烦的bug，不过现在已经解决了。

------

没想到这么快就要更新下了，因为nonebot2在前段时间的更新，所以本博客内的大部分源码都不能跑了，不过修改下几个具体的包名称也不算很麻烦，具体改动参见https://github.com/nonebot/discussions/discussions/74。
