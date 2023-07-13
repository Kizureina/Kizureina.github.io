---
title: SSTI——flask模板注入漏洞入门
date: 2022-02-14 20:53:14
tags: 
- SSTI
- python
---

最近一直在和python打交道，就想顺便学点Flask漏洞，也算打打python后端框架基础吧。

## Flask搭建后端服务

众所周知python也可用用来写后端，最简单的框架就是Flask，例如:

```python
from flask import Flask
app = Flask(__name__)
 
@app.route('/')
# route装饰器将url与下面的函数链接起来
def hello_world():
    return 'helloworld!'
if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000,debug=True)
    # host为0.0.0.0则为暴露在公网，可从任意IP访问
```

上面的python文件运行时会在5000端口**跑web服务**，访问https://IP:5000/ 返回hello world!的字符串。

上面的例子为返回简单的字符串，也可用模板渲染html源码在浏览器显示:

```python
from flask import Flask,render_template,render_template_string
app = Flask(__name__)
@app.route('/')
 
def hello_world():
    html = '<h1>hello world!</h1>'
    return render_template_string(html)
if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000,debug=True)
```

在浏览器中访问显示如下:

[![img](https://view.moezx.cc/images/2018/05/13/image-404.png)](https://kusarinoshojo.space/wp-content/uploads/2022/02/wp_editor_md_79164fa43a7eaba03eb9f3637fa91e47.jpg)

即html字符串中的**标签被模板渲染**并显示在浏览器中。

## Flask模板注入漏洞原理

而当字符串中的具体**参数可控**时，就可能存在模板注入漏洞:

```python
from flask import Flask,request,url_for,redirect,render_template,render_template_string
app = Flask(__name__)
@app.route('/',methods=['GET'])
 
def code():
    code = request.args.get('id')
    # 获取get传参的参数
    html = '''
    <h2>%s</h2>
    '''%(code)
    # 三引号作用与引号没区别，常用于大段字符串
    return render_template_string(html)
if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000,debug=True)
```

而构造**js代码**就可能造成XSS攻击

[![img](https://view.moezx.cc/images/2018/05/13/image-404.png)](https://kusarinoshojo.space/wp-content/uploads/2022/02/wp_editor_md_275d35a8c19ba1c7c44a9ae6d7e849c9.jpg)

此时传参的code直接插入字符串中，并被render_template_string渲染而触发SSTI。

只要换种写法就能避免:

```python
from flask import Flask,request,url_for,redirect,render_template,render_template_string
app = Flask(__name__)
@app.route('/',methods=['GET'])
 
def code():
    code = request.args.get('id')
    return render_template_string('<h2>{{code}}</h2>',code=code)
    # {{}}为Jinja2模板引擎中的变量包裹标识符
if __name__ == '__main__':
    app.run(host='0.0.0.0',port=5000,debug=True)
```

[![img](https://view.moezx.cc/images/2018/05/13/image-404.png)](https://kusarinoshojo.space/wp-content/uploads/2022/02/wp_editor_md_0f83095f0a522087532d31544656e292.jpg)
这是因为模板引擎一般都默认**对渲染的变量值进行编码转义**，因此用户控制的不是模板而是变量，并不会得到渲染产生SSTI。

## 基于SSTI的攻击

jinja2模板引擎会对{{}}内的内容进行渲染，也可执行一些表达式：
[![img](https://view.moezx.cc/images/2018/05/13/image-404.png)](https://kusarinoshojo.space/wp-content/uploads/2022/02/wp_editor_md_4e12a4cf38e92e7e4cf3c5fca8430a05.jpg)
或查看全局常量:
[![img](https://view.moezx.cc/images/2018/05/13/image-404.png)](https://kusarinoshojo.space/wp-content/uploads/2022/02/wp_editor_md_b5ce7555ff169652e3b7d79070c7ab2f.jpg)
可见表达式和命令都被执行了，由此可**构造文件包含漏洞**

与反序列化类似，同样需要利用魔术方法构造漏洞链，常用魔术方法：
\- __class__ 返回类型所属的对象
\- __mro__ 返回一个包含对象所继承的基类元组，方法在解析时按照元组的顺序解析。
\- __base__ 返回该对象所继承的基类
\- __base__和__mro__都是用来寻找基类的
\- __subclasses__ 每个新类都保留了子类的引用，这个方法返回一个类中仍然可用的的引用的列表
\- __init__ 类的初始化方法
\- __globals__ 对包含函数全局变量的字典的引用

思路一般为先用{{''.__**class__**}}(注：此处不是双引号而是两个单引号)找类型所属对象，然后{{''.__**class__**.__**mro__**}}查找所有基类
[![img](https://view.moezx.cc/images/2018/05/13/image-404.png)](https://kusarinoshojo.space/wp-content/uploads/2022/02/wp_editor_md_2b8ab4707f90b433d1b2112a814c3d12.jpg)
然后即可查找所有可用的类
