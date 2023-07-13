---
title: 简单的JS插件编写——检索Bilibili评论并举办
date: 2022-03-01 20:55:19
tags: JavaScript
---
### 前言

最近刚开学比较闲，想写个简单的js插件练练手，刚好看某些评论区低能评论太多，举办侠又有限，就想写个脚本匹配关键字批量举办

### 基本思路

通过B站页面的**INITAL_STATE**方法获取视频av号，再通过Ajax对api接口发起请求获取评论列表，遍历后将评论aid存到数组，最后循环举办。

关键功能函数为获取评论列表和批量举办，都是发起Ajax请求的函数。

懒得具体写函数的编写过程了，都是很清楚的思路，也就用了JQuery的$.ajax()函数和异步执行的sleep()函数比较新鲜吧。

### 具体源码

```javascript
console.log("运行中，请保持网络通畅及时间充足，运行时可切到其他页面")
var av = window.__INITIAL_STATE__.aid;
//获取视频av号
var csrf = getCookie("bili_jct");
//获取csrf token
var kill_list = new Array();
 
var str = prompt('请输入匹配的关键字','罕见');
 
function sleep (time) {
    return new Promise((resolve) => setTimeout(resolve, time));
  }
//定义sleep函数
 
function getCookie(name){
    var arr,reg=new RegExp("(^| )"+name+"=([^;]*)(;|$)");
    if(arr=document.cookie.match(reg)){
        return arr[2];}
    else{
    return null;}
  }
 
function find_reply (av,pn) {
    kill_list[pn] = new Array();
    var api = 'https://api.bilibili.com/x/v2/reply?type=1&oid=' + av + '&ps=49&pn=' + pn + '&sort=1&nohot=1';
    $.ajax({
        url: api,
        type: 'GET',
        contentType:false,
        processData:false,
        xhrFields: {
        withCredentials: true
        },
        success: function (data) {
            if (data.code == 0){            
                for (i = 0, j = 0; i < 48; i++){
                    try{
                        var r = data.data.replies[i].content.message;                        
                        var find1 = r.search(str);
                        //var find2 = r.search("大佐");
                        if (find1 !== -1 || find2 !==-1 ) {
                            kill_list[pn][j] = data.data.replies[i].rpid;
                            j++;
                            //console.log(json.data.replies[i].rpid);
                            console.log(data.data.replies[i].content.message);
                        }
                        else{
                            continue;
                        }
                    }
                    catch(e){
                        console.log("是友善的评论捏🥰");
                        logMyErrors(e);
                    }
                    finally{
                        continue;
                    }
            }
            console.log("\n已找到" + kill_list[pn].length + "条呃呃评论\n");
        }
            else {
                console.log("失败，原因:"+data.message);
            }
        }
    })
}
 
 
for (pn = 1; pn < 10; pn++)
{
    await sleep(7000);
    console.log("\n第" + pn + "页已检索完成\n");
    find_reply(av, pn);
}
 
 
for (pn = 1; pn<kill_list.length; pn++){
    console.log("开始举办第"+pn+"页呃呃评论");
    for (i = 0 ; i < kill_list[pn].length; i++){
        try{
            await sleep(100000);
            url = 'https://api.bilibili.com/x/v2/reply/report?type=1&reason=4&oid=' + av + '&rpid=';
            url_a = url + kill_list[pn][i];
            var formdata =new FormData();
            formdata.append("oid",av);
            formdata.append("type",1);
            formdata.append("rpid",kill_list[pn][i]);
            formdata.append("content","");
            formdata.append("reason",4); 
            formdata.append("ordering","heat");  
            formdata.append("jsonp","jsonp");
            formdata.append("csrf",csrf);
            $.ajax({
                url: url_a,
                type: 'POST',
                data: formdata,
                contentType:false,
                processData:false,
                xhrFields: {
                withCredentials: true
                },
                success: function (data) {
                    if (data.code == 0){
                        console.log("已成功举办第" + i + "条评论");
                    }
                    else{
                        console.log("第"+i+"条评论举办失败，原因:"+data.message);
                    }
                    if ( i == kill_list[pn].length){
                        console.log("已全部举办完成，辛苦了🥰部分评论没有举办成功，果咩😥");
                    }
                },
                error: function (data) {
                    console.log("果咩，出错了😢，原因:\n");
                    console.log(data);
                }
            })
        }
        catch(e){
            console.log("出错了😥");
            logMyErrors(e);
        }
        finally{
            continue;
        }
    }
}
 
console.log("END");
```

就是这么简单的思路，直接在视频页面F12找到浏览器控制台，再粘过去跑就行。值得一提的是举办的请求是POST，并且有CSRF token，因此频繁请求容易出错。因此举办间的间隔非常长，闲得无聊可以挂在后台一直跑。

简单说下CSRF，相当于别人用**你的权限越权完成操作**，例如利用你的cookie完成你的账户操作，精心构造的攻击是可以做到从一个安全的网站点进url就能越权的。而为了防止这种攻击，在某些请求时的鉴权除了cookie外还有POST一个特定的CSRF token，这个token一般是cookie里的其中一个键值对，而越权的攻击者只能利用cookie却无法像XSS那样盗取cookie，因此无法得到token在鉴权时请求失败，从而完成对CSRF的防御。B站cookie里的CSRF token就是"bili_jct"这个key的value。
