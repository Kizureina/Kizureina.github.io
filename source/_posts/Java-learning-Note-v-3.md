---
title: Java学习笔记
date: 2022-09-08 20:53:14
tags: 
- java
---

# Java leraning Note v.3

## 多线程

创建线程

```java
public class threadDemo {
    public static void main(String[] args) {
        Thread t = new MyThread();
        **t.start();
				// 启动线程执行**
        for (int i = 0; i < 5; i++) {
            System.out.println("主线程执行" + i);
        }
    }
}
class MyThread extends Thread{
    @Override
    public void run() {
        for (int i = 0; i <5; i++) {
            System.out.println("子线程执行输出" + i);
        }
    }
}
```

多线程同时执行，输出先后不确定。

注1：不能用t.run()执行，否则会把对象当成一般方法，不能创建线程，**t.start()方法内有线程注册机制。**

注2：不能把主线程程序放在子线程前面，否则会永远导致主线程先跑，不能同时执行。

### 创建线程方法二：实现Runnable接口

```java
public class threadDemo {
    public static void main(String[] args) {
        Runnable target = new MyThread();
        Thread t = new Thread(target);
        t.start();
        for (int i = 0; i < 5; i++) {
            System.out.println("主线程执行" + i);
        }
    }
}
class MyThread implements Runnable{
    @Override
    public void run() {
        for (int i = 0; i <5; i++) {
            System.out.println("子线程执行输出" + i);
        }
    }
```

此时MyThread类可继承其他父类，也可实现其他接口。**但不能有返回值。**

也可用匿名内部类或lambda表达式写法：

```java
public class threadDemo {
    public static void main(String[] args) {
        Runnable target = new Runnable() {
            @Override
            public void run() {
                for (int i = 0; i <5; i++) {
                    System.out.println("子线程执行输出" + i);
                }
            }
        };
        Thread t = new Thread(target);
        t.start();
        for (int i = 0; i < 5; i++) {
            System.out.println("主线程执行" + i);
        }
    }
}
```

或：

```java
public static void main(String[] args) {
        Runnable target = () -> {
            for (int i = 0; i <5; i++) {
                System.out.println("子线程执行输出" + i);
            }
        };
        Thread t = new Thread(target);
        t.start();
        for (int i = 0; i < 5; i++) {
            System.out.println("主线程执行" + i);
        }
    }
```

### 创建线程方法三：定义任务类实现Callable接口

优势：可获取返回值，即Callable为泛型

```java
import java.util.concurrent.Callable;
import java.util.concurrent.FutureTask;

public class threadDemo {
    public static void main(String[] args) {
        Callable<String> call = new MyThread(100);

        FutureTask<String> ft = new FutureTask<>(call);
				// 可通过get方法得到执行结果
				// 可将Callable传给Thread
        Thread t = new Thread(ft);
        t.start();
        try {
            // 若ft未执行完，此处会等待
            String s = ft.get();
            System.out.println("第一个结果" + s);
        } catch (Exception e){
            e.printStackTrace();
        }
        Callable<String> call2 = new MyThread(200);
        FutureTask<String> ft2 = new FutureTask<>(call2);
        Thread t2 = new Thread(ft2);
        t2.start();
        try {
            String s2 = ft2.get();
	            System.out.println("第二个结果" + s2);
        } catch (Exception e){
            e.printStackTrace();
        }
        for (int i = 0; i < 5; i++) {
            System.out.println("主线程执行" + i);
        }
    }
}
class MyThread implements Callable<String> {
    private int n;

    public MyThread(int n) {
        this.n = n;
    }
    @Override
    public String call() throws Exception{
        int sum = 0;
        for (int i = 0; i < n; i++) {
            sum += i;
        }
        return "所求的和为" + sum;
    }
}
```

## Thread常用方法

利用Thread.*`currentThread*()`.getName()区分线程名：

```java
public class MyThread1 extends Thread{
    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            System.out.println(Thread.currentThread().getName() + "执行" + i);
        }
    }
}
```

```java
public class api {
    public static void main(String[] args) {
        Thread t1 = new MyThread1();
        t1.setName("NO.1");
        t1.start();
        System.out.println(t1.getName());
        Thread t2 = new MyThread1();
        t2.setName("No.2");
        t2.start();
        System.out.println(t2.getName());
        Thread m = Thread.currentThread();
        System.out.println(m.getName());

        for (int i = 0; i < 5; i++) {
            System.out.println("主线程执行" + i);
        }
    }
}
```

也可用构造器，但要重写构造方法。

## 线程安全

```java
public void drawMoney(double money) {
        String name = Thread.currentThread().getName();
        if (this.money >= money){
            System.out.println(name + "取钱成功！");
            this.money -= money;
            System.out.println(name + "剩余" + this.money);
        } else {
            System.out.println(name + "余额不足！");
        }
    }
```

```java
public class ThreadSecurity {
    public static void main(String[] args) {
        Account acc = new Account("ICBC-1011",10000);

        new DrawThread(acc,"小明").start();
        new DrawThread(acc,"小红").start();
    }
}
```

若有两个线程同时调用该方法，可能再A线程完成判断，但还未对资源进行写入时，B线程也已完成判断，造成同时完成两次修改：

```java
"C:\Program Files (x86)\Java\jdk1.8.0_333\bin\java.exe" "-javaagent:E:\IntelliJ IDEA 2022.1\lib\idea_rt.jar=60352:E:\IntelliJ IDEA 2022.1\bin" -Dfile.encoding=UTF-8 -classpath "C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\charsets.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\deploy.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\access-bridge-32.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\cldrdata.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\dnsns.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\jaccess.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\jfxrt.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\localedata.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\nashorn.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunec.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunjce_provider.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunmscapi.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunpkcs11.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\zipfs.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\javaws.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jce.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jfr.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jfxswt.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jsse.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\management-agent.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\plugin.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\resources.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\rt.jar;E:\Java_IDEA\Java_lerannig_v3\out\production\Java_lerannig_v3" hit.com.d1_thread.ThreadSecurity
小明取钱成功！
小红取钱成功！
小明剩余0.0
小红剩余-10000.0
```

## 线程同步-线程锁

**利用同步对线程进行加锁，以解决安全问题。**

### 1.同步代码块

```java
public void drawMoney(double money) {
        String name = Thread.currentThread().getName();
        **synchronized ("heima") {
				// 锁对象为任意唯一对象，随机分配先后**
            if (this.money >= money){
                System.out.println(name + "取钱成功！");
                this.money -= money;
                System.out.println(name + "剩余" + this.money);
            } else {
                System.out.println(name + "余额不足！");
            }
        }
    }
```

但用任意无关对象会导致锁所有线程，因此**多用共享资源作为锁对象。**

```java
synchronized (this) {
      if (this.money >= money){
          System.out.println(name + "取钱成功！");
          this.money -= money;
          System.out.println(name + "剩余" + this.money);
      } else {
          System.out.println(name + "余额不足！");
      }
  }
```

1. 对于**实例方法**，共享资源对象为***this***
2. 对于**静态方法**，共享资源对象为***类名.class***

### 2.同步方法

```java
public synchronized void drawMoney(double money) {
        String name = Thread.currentThread().getName();
        
        if (this.money >= money){
            System.out.println(name + "取钱成功！");
            this.money -= money;
            System.out.println(name + "剩余" + this.money);
        } else {
            System.out.println(name + "余额不足！");
        }
   
    }
```

```java
private final Lock lock = new ReentrantLock();

public void drawMoney(double money) {
    String name = Thread.currentThread().getName();
    lock.lock();
    try {
        if (this.money >= money){
            System.out.println(name + "取钱成功！");
            this.money -= money;
            System.out.println(name + "剩余" + this.money);
        } else {
            System.out.println(name + "余额不足！");
        }
    } catch (Exception e) {
        throw new RuntimeException(e);
    } finally {
        lock.unlock();
    }
}
```

## 线程通信

生成-消费-生成-消费—————

不断有序运行如上任务，需要用线程通信。

利用Object类如下两个方法完成线程间的唤醒与等待，实现线程依次运行。

```java
this.notifyAll();//唤醒所有线程
this.wait();// 等待自己
```

```java
public synchronized void saveMoney(double money){
	  String name = Thread.currentThread().getName();
	  if(this.money == 0){
	      this.money += money;
	      System.out.println(name + "存钱成功" + "余" + this.money);
	      try {
	          this.notifyAll();
	          this.wait();
	      } catch (InterruptedException e) {
	          throw new RuntimeException(e);
	      }
	  } else{
	      System.out.println("有钱");
	  }
	}
public synchronized void drawMoney(double money){
  try {
      String name = Thread.currentThread().getName();
      if (this.money >= money){
          //可取
          this.money -= money;
          System.out.println(name + "来取钱" + money + "余额" + this.money);
          this.notifyAll();
          this.wait();
      } else{
          this.notifyAll();//唤醒所有线程
          this.wait();// 等待自己**
      }
  } catch (InterruptedException e) {
      throw new RuntimeException(e);
  }
}
/*
*有钱
小红来取钱10000.0余额0.0
岳父存钱成功余10000.0
有钱
小明来取钱10000.0余额0.0
干爹存钱成功余10000.0
有钱
有钱
小明来取钱10000.0余额0.0
...
*/
```

```java
public class ThreadDemo {
    public static void main(String[] args) {
        Account acc = new Account("IDC-88",0);

        // 创建两个取钱线程代表小红小明
        new DrawThread(acc,"小明").start();
        new DrawThread(acc,"小红").start();

        // 创建三个爸爸做存钱线程
        new SaveThread(acc, "亲爹").start();
        new SaveThread(acc, "干爹").start();
        new SaveThread(acc, "岳父").start();

    }
}
```

如上存钱方法与取钱方法可实现线程通信。

用到该方法的方法需要用**synchronized修饰。**

## ★线程池

### 线程池处理Runnable任务

线程池构造器的参数：

临时线程创建：核心线程正在忙，且任务队列也满了

拒绝任务时：核心线程和临时线程都在忙，任务队列也满了，此时开始拒绝新的任务。

```java
public class threadPoolDemo {
    public static void main(String[] args) {
        /*public ThreadPoolExecutor(int corePoolSize,
                              int maximumPoolSize,
                              long keepAliveTime,
                              TimeUnit unit,
                              BlockingQueue<Runnable> workQueue,
                              ThreadFactory threadFactory,
                              RejectedExecutionHandler handler)
        * */
        ExecutorService pool = new ThreadPoolExecutor(3, 5, 6,
                TimeUnit.SECONDS,
                new ArrayBlockingQueue<>(5), Executors.defaultThreadFactory(),
                new ThreadPoolExecutor.AbortPolicy());
        // 将任务交给线程池

        Runnable target = new MyRunnable();
        pool.execute(target);
        pool.execute(target);
        pool.execute(target);
        pool.execute(target);
        pool.execute(target);
    }
}
```

```java
public class MyRunnable implements Runnable{
    @Override
    public void run() {
        for (int i = 0; i < 5; i++) {
            System.out.println(Thread.currentThread().getName() + "打印了" + i);

        }
        try {
            System.out.println(Thread.currentThread().getName() + "本任务与线程绑定，进入休眠了~~");
            Thread.sleep(1000000);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
```

正常有三个线程在跑，在超过五个任务时会创建临时线程，最多有两个临时线程。

### 线程池处理Callable任务

```java
public class threadPoolDemo {
    public static void main(String[] args) throws ExecutionException, InterruptedException {
        /*public ThreadPoolExecutor(int corePoolSize,
                              int maximumPoolSize,
                              long keepAliveTime,
                              TimeUnit unit,
                              BlockingQueue<Runnable> workQueue,
                              ThreadFactory threadFactory,
                              RejectedExecutionHandler handler)
        * */
        ExecutorService pool = new ThreadPoolExecutor(3, 5, 6,
                TimeUnit.SECONDS,
                new ArrayBlockingQueue<>(5), Executors.defaultThreadFactory(),
                new ThreadPoolExecutor.AbortPolicy());
        // 将任务交给线程池

        Future<String> f = pool.submit(new MyCallable(100));
        Future<String> f2 = pool.submit(new MyCallable(200));
        Future<String> f3 = pool.submit(new MyCallable(300));
        Future<String> f4 = pool.submit(new MyCallable(400));
        // 提取结果

        System.out.println(f.get());
        System.out.println(f2.get());
        System.out.println(f3.get());
        System.out.println(f4.get());

    }
}
```

```java
public class MyCallable implements Callable<String> {
    private int n;

    public MyCallable(int n) {
        this.n = n;
    }

    public MyCallable() {
    }

    @Override
    public String call() throws Exception {
        int sum = 0;
        for (int i = 0; i <= n; i++) {
            sum += i;
        }
        return Thread.currentThread().getName() + "结果为" +  sum;
    }
}
```

运行同样是三个线程:

```java
pool-1-thread-1结果为5050
pool-1-thread-2结果为20100
pool-1-thread-3结果为45150
pool-1-thread-2结果为80200
```

## 定时器

实际多用线程池工具类完成定时器

# 网络编程

### 网络通信三要素：IP地址，端口，协议

## InetAddress

```java
public class InetAddressDemo {
    public static void main(String[] args) throws Exception{
        InetAddress ip1 = InetAddress.getLocalHost();
        System.out.println(ip1.getHostName());
        System.out.println(ip1.getHostAddress());

        InetAddress ip2 = InetAddress.getByName("baidu.com");
        System.out.println(ip2.getHostAddress());
        System.out.println(ip2.getHostName());

        InetAddress ip3 = InetAddress.getByName("39.156.66.10");
        System.out.println(ip2.getHostAddress());
        System.out.println(ip2.getHostName());
        System.out.println(ip3.isReachable(3000));
    }
}
```

### 端口号

端口用于标记计算机上运行的进程。

端口号不能重复。

## 协议

传输层两个常见协议：**UDP，TCP**

### TCP

双方先建立链接再通信 是一种**可靠通信。可进行大数据量的通信，但效率较低。**

三次握手：

四次挥手断开链接：

## UDP

无连接，不可靠的传输协议

速度块，资源开销小，无法确认是否收到数据，可广播发送。

有大小限制，一次最多发送64KB信息

## UDP通信

数据包对象：

发送端接收端对象（管道）：

客户端：

```java
public class ClientDemo {
    public static void main(String[] args) throws Exception{
        // 创建发送端对象
        DatagramSocket socket = new DatagramSocket();
        // 创建数据包对象
        /*public DatagramPacket(byte buf[], int offset, int length, SocketAddress address) {
        setData(buf, offset, length);
        setSocketAddress(address);
    }
    **参数一：封装要发送的数据 二：数据大小 三：服务的IP 四：服务端端口**
        * */
        byte[] buffer = "我是中国人".getBytes(StandardCharsets.UTF_8);
        DatagramPacket packet = new DatagramPacket(buffer, buffer.length, InetAddress.getLocalHost(), 8888);

        socket.send(packet);
        socket.close();
    }
}
```

服务端：

```java
public class ServerDemo {
    public static void main(String[] args) throws Exception {
        DatagramSocket socket = new DatagramSocket(8888);

        byte[] buffer = new byte[1024 * 64];
        DatagramPacket packet = new DatagramPacket(buffer, buffer.length);

        socket.receive(packet);
        int len = packet.getLength();
        // 取数据
        System.out.println("收到了" + new String(buffer, 0, len));

        socket.close();
    }
}

```

可用packet内的方法获取客户端IP和端口。

### UDP**多发多收**

```java
public class ServerDemo {
    public static void main(String[] args) throws Exception {
        DatagramSocket socket = new DatagramSocket(8888);

        byte[] buffer = new byte[1024 * 64];
        DatagramPacket packet = new DatagramPacket(buffer, buffer.length);

        while (true) {
            socket.receive(packet);
            int len = packet.getLength();
            // 取数据
            System.out.println("收到了" + packet.getAddress() + "的" + packet.getPort() + "的" + new String(buffer, 0, len));
				
        }
				// 注：未接受多次不能用scoket.close()

    }
}
```

```java
public class ClientDemo {
    public static void main(String[] args) throws Exception{
        Scanner sc = new Scanner(System.in);
        // 创建发送端对象
        DatagramSocket socket = new DatagramSocket();
        // 创建数据包对象
        /*public DatagramPacket(byte buf[], int offset, int length, SocketAddress address) {
        setData(buf, offset, length);
        setSocketAddress(address);
    }
    参数一：封装要发送的数据 二：数据大小 三：服务的IP 四：服务端端口
        * */
        while (true) {
            System.out.println("请您输入：");

            String msg = sc.nextLine();

            if("exit".equals(msg)){
                System.out.println("已退出");
                socket.close();
                break;
            }
            byte[] buffer = msg.getBytes(StandardCharsets.UTF_8);
            DatagramPacket packet = new DatagramPacket(buffer, buffer.length, InetAddress.getLocalHost(), 8888);

            socket.send(packet);
        }
    }
}
```

## UDP广播 组播

```java
DatagramPacket packet = new DatagramPacket(buffer, buffer.length,
                    InetAddress.getByName("**255.255.255.255**"), 9999);
```

客户端修改为如上，同时服务端修改端口为9999，此时服务端可接受所有广播信息。

```java
MulticastSocket socket = new MulticastSocket(9999);

socket.joinGroup(InetAddress.getByName("224.0.0.1"));
```

# TCP通信

Java Socket底层是TCP协议。

```java
public class ServerDemo {
    public static void main(String[] args) {
        try {
            // 注册端口
            System.out.println("======服务端启动成功========");
            ServerSocket serverSocket = new ServerSocket(7777);
            // 等待客户端链接请求，建立socket通信管道
            Socket socket = serverSocket.accept();
            // 从管道中得到字节输入流
            InputStream is = socket.getInputStream();
            //包装
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            // 先转字符输入流，再转缓冲字符输入流
            String msg;
            while((msg = br.readLine())!=null){
                System.out.println(socket.getRemoteSocketAddress() + "说了" + msg);
            }
            //不能关闭

        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
```

```java
public class ClientDemo {
    public static void main(String[] args) throws IOException {
        Socket socket = new Socket("127.0.0.1", 7777);
        // 利用IO流在管道发送数据
        OutputStream os = socket.getOutputStream();

        PrintStream ps = new PrintStream(os);
        **ps.println("我是TCP客户端，已对接，发出邀请");**
        ps.flush();

        // ps.close();
        //不能直接关闭！可能导致服务器数据收不到
    }
}
```

注意：应该先运行服务端再运行客户端！

注意：发送消息必须为一行，要有换行符，否则无法收到消息，会断开链接!

**通信面向链接，一端挂了另一端也必挂**

### 实现多收多发

```java
public static void main(String[] args) throws IOException {
        Socket socket = new Socket("127.0.0.1", 7777);
        // 利用IO流在管道发送数据
        OutputStream os = socket.getOutputStream();

        PrintStream ps = new PrintStream(os);

        Scanner sc = new Scanner(System.in);
        **while(true){
            String msg = sc.nextLine();
            ps.println(msg);
            ps.flush();
        }**

        // ps.close();
        //不能直接关闭！可能导致服务器数据收不到
    }
```

但无法完成多个客户端与服务端通信，因为**一个线程只能用一个死循环接收socket对象。**

## 实现同时接受多个客户端

```java
public class ClientDemo {
    public static void main(String[] args) throws IOException {
        Socket socket = new Socket("127.0.0.1", 7777);
        // 利用IO流在管道发送数据
        OutputStream os = socket.getOutputStream();

        PrintStream ps = new PrintStream(os);

        Scanner sc = new Scanner(System.in);
        while(true){
            String msg = sc.nextLine();
            ps.println(msg);
            ps.flush();
        }
    }
}
```

服务端需要用多线程实现：

```java
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.Socket;

public class ServerReaderThread extends Thread{
    private Socket socket;
    public ServerReaderThread(Socket socket){
        this.socket = socket;
    }
    @Override
    public void run() {
        InputStream is = null;
        try {
            is = socket.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            // 先转字符输入流，再转缓冲字符输入流
            String msg;
            while((msg = br.readLine())!=null){
                System.out.println(socket.getRemoteSocketAddress() + "说了" + msg);
            }
        } catch (IOException e) {
            System.out.println(socket.getRemoteSocketAddress() + "下线了");
        }

    }
}
```

服务端调用多线程，并用accept方法判断上线：

```java
public class ServerDemo {
    public static void main(String[] args) {
        try {
            // 注册端口
            System.out.println("======服务端启动成功========");
            ServerSocket serverSocket = new ServerSocket(7777);
           // 定义死循环由主线程不断接受客户端socket管道链接
            while(true){
                Socket socket = serverSocket.accept();
                System.out.println(socket.getRemoteSocketAddress() + "上线了");
                **new ServerReaderThread(socket).start();**
            }

        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
/*
======服务端启动成功========
/127.0.0.1:58117上线了
/127.0.0.1:58126上线了
/127.0.0.1:58135上线了
/127.0.0.1:58135下线了
/127.0.0.1:58126说了尼戈卢达哟
/127.0.0.1:58126下线了

*/
```

可实现多个客户端给服务端发信息，但问题是无法控制线程数。

利用**线程池**解决此问题：

```java
public class ServerDemo {
    private static ExecutorService pool = new ThreadPoolExecutor(3, 5, 6, TimeUnit.SECONDS,
            new ArrayBlockingQueue<>(2), Executors.defaultThreadFactory(),
            new ThreadPoolExecutor.AbortPolicy());

    public static void main(String[] args) {
        try {
            // 注册端口
            System.out.println("======服务端启动成功========");
            ServerSocket serverSocket = new ServerSocket(7777);
           // 定义死循环由主线程不断接受客户端socket管道链接
            while(true){
                Socket socket = serverSocket.accept();
                System.out.println(socket.getRemoteSocketAddress() + "上线了");
                // 实例化任务
                Runnable target = new ServerReaderRunnable(socket);
                // 将任务传给线程池运行
                pool.execute(target);
            }

        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
```

线程池需要用任务队列而非线程类：

```java
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.Socket;

public class ServerReaderRunnable implements Runnable{
    private Socket socket;
    public ServerReaderRunnable(Socket socket){
        this.socket = socket;
    }
    @Override
    public void run() {
        try {
            InputStream is = socket.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            // 先转字符输入流，再转缓冲字符输入流
            String msg;
            while((msg = br.readLine())!=null){
                System.out.println(socket.getRemoteSocketAddress() + "说了" + msg);
            }
        } catch (IOException e) {
            System.out.println(socket.getRemoteSocketAddress() + "下线了");
        }
    }
}
/*
"C:\Program Files (x86)\Java\jdk1.8.0_333\bin\java.exe" "-javaagent:E:\IntelliJ IDEA 2022.1\lib\idea_rt.jar=58410:E:\IntelliJ IDEA 2022.1\bin" -Dfile.encoding=UTF-8 -classpath "C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\charsets.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\deploy.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\access-bridge-32.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\cldrdata.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\dnsns.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\jaccess.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\jfxrt.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\localedata.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\nashorn.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunec.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunjce_provider.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunmscapi.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunpkcs11.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\zipfs.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\javaws.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jce.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jfr.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jfxswt.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jsse.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\management-agent.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\plugin.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\resources.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\rt.jar;E:\Java_IDEA\Java_lerannig_v3\out\production\Java_lerannig_v3" hit.com.D7_socket_multi.ServerDemo
======服务端启动成功========
/127.0.0.1:58419上线了
/127.0.0.1:58427上线了
/127.0.0.1:58419说了我是第一个线程
/127.0.0.1:58427说了我是第二个线程
/127.0.0.1:58444上线了
/127.0.0.1:58444说了我是第三个客户端， 占用了一个核心线程
/127.0.0.1:58460上线了
/127.0.0.1:58484上线了
/127.0.0.1:58492上线了
/127.0.0.1:58492说了我是第六个任务
/127.0.0.1:58523上线了
/127.0.0.1:58523说了我是第七个客户端
/127.0.0.1:58564上线了
Exception in thread "main" java.util.concurrent.RejectedExecutionException: Task hit.com.D7_socket_multi.ServerReaderRunnable@16f6e28 rejected from java.util.concurrent.ThreadPoolExecutor@15fbaa4[Running, pool size = 5, active threads = 5, queued tasks = 2, completed tasks = 0]
	at java.util.concurrent.ThreadPoolExecutor$AbortPolicy.rejectedExecution(ThreadPoolExecutor.java:2063)
	at java.util.concurrent.ThreadPoolExecutor.reject(ThreadPoolExecutor.java:830)
	at java.util.concurrent.ThreadPoolExecutor.execute(ThreadPoolExecutor.java:1379)
	at hit.com.D7_socket_multi.ServerDemo.main(ServerDemo.java:28)
/127.0.0.1:58419下线了
/127.0.0.1:58460说了我是第四个客户端

*/
```

可以很优雅地控制线程，防止资源耗尽。

## TCP即时通信

需要在服务端实现**端口转发**

在ServerDemo类定义静态集合存储所有在线的Socket：

```java
public static List<Socket> allOnlineSockets = new ArrayList<>();
```

```java
public class ServerReaderThread extends Thread{
    private Socket socket;
    public ServerReaderThread(Socket socket){
        this.socket = socket;
    }
    @Override
    public void run() {
        InputStream is = null;
        try {
            is = socket.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            // 先转字符输入流，再转缓冲字符输入流
            String msg;
            while((msg = br.readLine())!=null){
                System.out.println(socket.getRemoteSocketAddress() + "说了" + msg);
                // 消息端口转发给客户端
                sendMsgToAll(msg);
            }
        } catch (Exception e) {
            System.out.println(socket.getRemoteSocketAddress() + "下线了");
            ServerDemo.allOnlineSockets.remove(socket);
        }
    }
    private void sendMsgToAll(String msg) throws Exception{
        for (Socket socket : ServerDemo.allOnlineSockets) {
            PrintStream ps = new PrintStream(socket.getOutputStream());
						// 在Socket管道建立输出流（用打印流封装）
            ps.println(msg);
            ps.flush();
        }
    }
}
```

```java
public class ClientDemo {
    public static void main(String[] args) throws IOException {
        System.out.println("=============客户端启动成功===========");
        Socket socket = new Socket("127.0.0.1", 7777);
        new ClientReaderThread(socket).start();
        // 利用IO流在管道发送数据
        OutputStream os = socket.getOutputStream();

        PrintStream ps = new PrintStream(os);

        Scanner sc = new Scanner(System.in);
        while(true){
            String msg = sc.nextLine();
            ps.println(msg);
            ps.flush();
        }
    }
}

class ClientReaderThread extends Thread{
    private Socket socket;
    public ClientReaderThread(Socket socket){
        this.socket = socket;
    }
    @Override
    public void run() {
        InputStream is = null;
        try {
            is = socket.getInputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            // 先转字符输入流，再转缓冲字符输入流
            String msg;
            while((msg = br.readLine())!=null){
                System.out.println(socket.getRemoteSocketAddress() + "说了" + msg);
            }
        } catch (IOException e) {
            System.out.println("被踢出去了！！");
        }

    }
}
```

### BS架构

修改端口用浏览器访问：

```java
ServerSocket serverSocket = new ServerSocket(8888);
```

```java
public class ServerReaderThread extends Thread{
    private Socket socket;
    public ServerReaderThread(Socket socket){
        this.socket = socket;
    }
    @Override
    public void run() {
        try {
            PrintStream ps = new PrintStream(socket.getOutputStream());
            // 在Socket管道建立输出流（用打印流封装）
            ps.println("HTTP/1.1 200 OK");
            ps.println("Content-Type:text/html;charset=UTF-8");
            ps.println();
            ps.println("<h1>hello world!!!!</h1>");
            ps.flush();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

## 单元测试 断言

```java
import org.testng.Assert;
import org.testng.annotations.Test;

public class testtest {
    @Test
    public void testLoginName(){
        test test = new test();
        String rs = test.loginName("admin","12346");
        // **使用断言**
        Assert.assertEquals(rs,"登录成功","您的业务出问题了！");
    }
}
```

```java
public class test {
    public String loginName(String loginName, String passWord){
        if ("admin".equals(loginName) && "13456".equals(passWord)){
           return "登录成功";
        }else {
            return "登录失败!";
        }
    }
    public void selectName(){
        System.out.println(10/0);
        System.out.println(1111);
    }
}
```

测试可以跑整个类，也可跑单个测试类。

其他注解：

```java
@Before
public void  before(){
    System.out.println("===执行前执行！");
}

@After
public void after(){
    System.out.println("===执行后执行！");
}
```

## ★反射

**运行时动态**获取**类**信息以及动态调用类中成分称之为**反射**

### 反射第一步：获取Class类对象

获取Class类对象的三种方法：

```java
public class reflectDemo {
    public static void main(String[] args) throws Exception{
        // 1. 静态方法
        Class c = Class.forName("hit.hit.D1_reflect.Student");
        System.out.println(c);
        // 2. 类名

        Class c1 = Student.class;
        System.out.println(c1);

        // 3. 由对象获取

        Student s = new Student();
        Class c2 = s.getClass();
        System.out.println(c2);
    }
}
/*
"C:\Program Files (x86)\Java\jdk1.8.0_333\bin\java.exe" "-javaagent:E:\IntelliJ IDEA 2022.1\lib\idea_rt.jar=60832:E:\IntelliJ IDEA 2022.1\bin" -Dfile.encoding=UTF-8 -classpath "C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\charsets.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\deploy.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\access-bridge-32.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\cldrdata.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\dnsns.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\jaccess.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\jfxrt.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\localedata.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\nashorn.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunec.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunjce_provider.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunmscapi.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunpkcs11.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\zipfs.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\javaws.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jce.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jfr.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jfxswt.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jsse.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\management-agent.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\plugin.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\resources.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\rt.jar;E:\Java_IDEA\Java_lerannig_v3\out\production\Java_lerannig_v3;C:\Users\Yoruko\.m2\repository\org\testng\testng\7.1.0\testng-7.1.0.jar;C:\Users\Yoruko\.m2\repository\com\beust\jcommander\1.72\jcommander-1.72.jar;C:\Users\Yoruko\.m2\repository\com\google\inject\guice\4.1.0\guice-4.1.0-no_aop.jar;C:\Users\Yoruko\.m2\repository\javax\inject\javax.inject\1\javax.inject-1.jar;C:\Users\Yoruko\.m2\repository\aopalliance\aopalliance\1.0\aopalliance-1.0.jar;C:\Users\Yoruko\.m2\repository\com\google\guava\guava\19.0\guava-19.0.jar;C:\Users\Yoruko\.m2\repository\org\yaml\snakeyaml\1.21\snakeyaml-1.21.jar;C:\Users\Yoruko\.m2\repository\junit\junit\4.13.1\junit-4.13.1.jar;C:\Users\Yoruko\.m2\repository\org\hamcrest\hamcrest-core\1.3\hamcrest-core-1.3.jar" hit.hit.D1_reflect.reflectDemo
class hit.hit.D1_reflect.Student
class hit.hit.D1_reflect.Student
class hit.hit.D1_reflect.Student

进程已结束,退出代码0
*/
```

### 反射第二步：获取构造器对象 + 获取对象

```java
public void getConstructors(){
        Class c = Student.class;
        Constructor[] constructors = c.getConstructors();
        for (Constructor constructor : constructors) {
            System.out.println(constructor.getName() + "参数" + constructor.getParameterCount());
        }
    }
```

由构造器new对象：

```java
public class studentTest2 {
    @Test
    public void getConstructors() throws Exception {
        Class c = Student.class;
        // 获取指定的构造器
        Constructor constructor = c.getDeclaredConstructor(String.class, int.class);
        System.out.println(constructor.getName() + constructor.getParameterCount());
        constructor.setAccessible(true);

        Student stu = (Student) constructor.newInstance("张三",10);
        System.out.println(stu);
    }
}
```

## 反射获取成员变量：赋值与取值

```java
public class reflectDemo2 {
    @Test
    public void getDeclaredFields(){
        Class c = Student.class;
        Field[] fields = c.getDeclaredFields();
        for (Field field : fields) {
            System.out.println(field.getName() + field.getType());
        }
    }

    @Test
    public void getFields() throws Exception{
        Class c = Student.class;
        // 获取特定成员变量
			Field ageF = c.getDeclaredField("age");

        ageF.setAccessible(true);
        // 赋值
        Student s = new Student();
        ageF.set(s, 10);
        System.out.println(s);

        // 取值

        int age = (int) ageF.get(s);
        System.out.println(age);
    }
}
```

### 反射提取方法 运行

```java
@Test
public void getDeclaredMethods(){
    Class c = Dog.class;

    Method[] methods = c.getDeclaredMethods();
    for (Method method : methods) {
        System.out.println(method.getName() + "=>" + method.getParameterCount() + "=>" + method.getReturnType());
    }
}
```

```java
@Test
public void getDeclaredMethod() throws Exception{
    Class c = Dog.class;

    Method m = c.getDeclaredMethod("run",String.class);
    Method s = c.getDeclaredMethod("sleep");

    Dog d = new Dog();
    Object result = m.invoke(d,"呃呃");
    System.out.println(result);

    Object result2 = s.invoke(d);
    System.out.println(result2);
}
```

## 反射的作用

1. 擦除泛型，可在**运行阶段强行加入**其他类型的集合。
1. 用作**通用框架**

## 注解

### 自定义注解

```java
package hit.hit.d2_annotation;

@Mybook(name = "精通java", authors = {"11","22"}, price = 22.5)
public class annotationDemo {
        @Mybook(name = "精通java", authors = {"11","22"}, price = 22.5)
        private annotationDemo(){

        }
        @Mybook(name = "精通java", authors = {"11","22"}, price = 22.5)
        public static void main(String[] args) {
            @Mybook(name = "精通java", authors = {"11","22"}, price = 22.5)
            int age = 12;
        }
}
```

```java
public @interface Mybook {
    String name();
    String[] authors();
    double p;
```

若自定义注解中有特殊属性value()，则若只有一个属性可省略属性名。

### 元注解

放在自定义注解上的注解。

```java
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.METHOD,ElementType.FIELD})
// 规定注解方法和属性
@Retention(RetentionPolicy.RUNTIME)
// 生命周期为一直存活
public @interface Book {
    String value();
}
```

### 注解解析

```java
public class annotationDemo {
    @Test
    public void parseClass() throws Exception{
	      Class c1 = bookStore.class;
	      Method m = c1.getDeclaredMethod("test");
	
	      Class c = bookStore.class;
        if (c.isAnnotationPresent(Mybook.class)){
            Mybook book = (Mybook) c.getDeclaredAnnotation(Mybook.class);
            System.out.println(book.authors());
            System.out.println(book.price());
            System.out.println(book.value());
        }
    }
}
@Mybook(value = "1111", authors = {"古龙"}, price = 200.0)
class bookStore{
    @Mybook(value = "1111", authors = {"5555"},price = 110.2)
    public void test(){

    }
}
```

## 注解的应用：标记做特殊处理

```java
public class annotationTest {
    @MyTest
    public void test1(){
        System.out.println("====text1====");
    }
    public void test2(){
        System.out.println("====text2====");
    }
    @MyTest
    public void test3(){
        System.out.println("====text3====");
    }
    /**
     * **启动菜单，有注解的方法才被调用**
     */
    public static void main(String[] args) throws Exception{
        // 获取类对象
        Class c = annotationTest.class;
        // 获取全部方法
        Method[] methods = c.getDeclaredMethods();

        for (Method method : methods) {
            if (method.isAnnotationPresent(MyTest.class)) {
                method.invoke(new annotationTest());
            }
        }
    }
}
```

多用于各种框架开发。

# ★动态代理

```java
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

public class StarAgentProxy {
    /*
    * 设计方法返回明星对象的代理对象
    * */
    public static Skill getProxy(Star star){
        // 为明星对象生成代理对象
        return (Skill) Proxy.newProxyInstance(star.getClass().getClassLoader(),
                star.getClass().getInterfaces(), new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        System.out.println("收取首款~~");
                        // 调用的代理方法
                        Object rs = method.invoke(star,args);
                        System.out.println("收尾款");
                        return rs;
                    }
                });
    }
}
```

```java
// **代理对象必须实现了某个接口**
public interface Skill {
    void jump();
    void sing();
}
```

```java
public class Star implements Skill{
    private String name;

    @Override
    public void jump() {
        System.out.println("跳舞~~~~");
    }

    @Override
    public void sing() {
        System.out.println("唱歌~~~");
    }
}
```

最后调用：

```java
public class proxyDemo {
    public static void main(String[] args) {
        // 目标：开发代理对象，理解动态代理
        Star s = new Star("serenchan");
        Skill s2 = StarAgentProxy.getProxy(s);
		// 代理后返回的代理后对象是Skill类型，相当于也实现了需要代理的对象的接口
        s2.jump();
        // s2.sing();
    }
}
```

### 代理的作用：提高代码复用性，可将重复的方法封装成代理对象。

例如每个方法都加个性能分析的System.currentTimeMillis()，可加在代理内：

```java
public class Test {
    public static void main(String[] args) {
        UserService userService = ProxyUtil.getProxy(new UsreServiceDemo());
        System.out.println(userService.login("admin", "123456"));
        userService.deleteUsers();
    }
}
```

```java
public class ProxyUtil {
    public static UserService getProxy(UserService userService){
        return (UserService) Proxy.newProxyInstance(userService.getClass().getClassLoader(),
                userService.getClass().getInterfaces(), new InvocationHandler() {
                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        long startTime = System.currentTimeMillis();
                        Object rs = method.invoke(userService,args);
                        long lastTime = System.currentTimeMillis();
                        System.out.println(method.getName() + "耗时为" + (lastTime - startTime) / 1000.0 + "s");
                        return rs;
                    }
                });
    }
}
```

注：也可用泛型实现任意接口做代理：

## XML

可扩展标记语言，常用于传输和存储数据。

特点：

1. 纯文本，默认UTF-8
2. 可嵌套
3. 可存为XML文件
4. 常用作消息进行网络传输， 或作为配置文件用作存储系统信息。

### XML文档约束

## XML解析

dom4j（DOM for java）

```java
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import org.testng.annotations.Test;

/**
 * @author Yoruko
 */
public class Dom4jDemo1 {
    @Test
    public void parseXml() throws Exception {

        // 创建Dom4j解析器对象
        SAXReader saxReader = new SAXReader();
        Document document = saxReader.read(Dom4jDemo1.class.getResourceAsStream("/hello_world.xml"));
        Element root = document.getRootElement();
    }
}
```

实例：解析成对象

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!--注释-->
<contactlist>
    <contact id="1" vip="false">
        <name>国王</name>
        <sex>male</sex>
        <email>1616161</email>
    </contact>
    <contact id="2" vip="true">
        <name>王后</name>
        <sex>female</sex>
        <email>56565656556</email>
    </contact>
</contactlist>
```

工具类

```java
package com.dom4j;
/*
<contact id="1" vip="false">
<name>国王</name>
<sex>male</sex>
   </contact>
* */
public class Contact {
    private String name;
    private String sex;
    private int id;
    private boolean vip;
    private String email;

    @Override
    public String toString() {
        return "Contact{" +
                "name='" + name + '\'' +
                ", sex='" + sex + '\'' +
                ", id=" + id +
                ", vip=" + vip +
                ", email='" + email + '\'' +
                '}';
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSex() {
        return sex;
    }

    public void setSex(String sex) {
        this.sex = sex;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public boolean isVip() {
        return vip;
    }

    public void setVip(boolean vip) {
        this.vip = vip;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Contact() {
    }

    public Contact(String name, String sex, int id, boolean vip, String email) {
        this.name = name;
        this.sex = sex;
        this.id = id;
        this.vip = vip;
        this.email = email;
    }
}
```

主程序

```java
package com.dom4j;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;
import org.testng.annotations.Test;

import java.util.ArrayList;
import java.util.List;

public class Dom4JTest2 {
    @Test
    public void parseToList() throws DocumentException {
        SAXReader saxReader = new SAXReader();
        Document document = saxReader.read(Dom4JTest2.class.getResourceAsStream("/hello_world.xml"));
        Element root = document.getRootElement();

        List<Element> contactsEles = root.elements("contact");
        List<Contact> contacts = new ArrayList<>();
        for (Element contactsEle : contactsEles) {
            Contact contact = new Contact();
            contact.setId(Integer.valueOf(contactsEle.attributeValue("id")));
            contact.setVip(Boolean.valueOf(contactsEle.attributeValue("vip")));

            contact.setName(contactsEle.elementTextTrim("name"));
            contact.setSex(contactsEle.elementTextTrim("sex"));
            contact.setEmail(contactsEle.elementTextTrim("email"));
            contacts.add(contact);
        }

        for (Contact contact : contacts) {
            System.out.println(contact);
        }
    }
}

/*
"C:\Program Files (x86)\Java\jdk1.8.0_333\bin\java.exe" -ea -Didea.test.cyclic.buffer.size=1048576 "-javaagent:E:\IntelliJ IDEA 2022.1\lib\idea_rt.jar=60221:E:\IntelliJ IDEA 2022.1\bin" -Dfile.encoding=UTF-8 -classpath "E:\IntelliJ IDEA 2022.1\lib\idea_rt.jar;E:\IntelliJ IDEA 2022.1\plugins\testng\lib\testng-rt.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\charsets.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\deploy.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\access-bridge-32.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\cldrdata.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\dnsns.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\jaccess.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\jfxrt.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\localedata.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\nashorn.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunec.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunjce_provider.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunmscapi.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunpkcs11.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\zipfs.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\javaws.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jce.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jfr.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jfxswt.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jsse.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\management-agent.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\plugin.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\resources.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\rt.jar;E:\Java_IDEA\Java_lerannig_v3\out\production\Java_lerannig_v3;C:\Users\Yoruko\.m2\repository\org\testng\testng\7.1.0\testng-7.1.0.jar;C:\Users\Yoruko\.m2\repository\com\beust\jcommander\1.72\jcommander-1.72.jar;C:\Users\Yoruko\.m2\repository\com\google\inject\guice\4.1.0\guice-4.1.0-no_aop.jar;C:\Users\Yoruko\.m2\repository\javax\inject\javax.inject\1\javax.inject-1.jar;C:\Users\Yoruko\.m2\repository\aopalliance\aopalliance\1.0\aopalliance-1.0.jar;C:\Users\Yoruko\.m2\repository\com\google\guava\guava\19.0\guava-19.0.jar;C:\Users\Yoruko\.m2\repository\org\yaml\snakeyaml\1.21\snakeyaml-1.21.jar;C:\Users\Yoruko\.m2\repository\junit\junit\4.13.1\junit-4.13.1.jar;C:\Users\Yoruko\.m2\repository\org\hamcrest\hamcrest-core\1.3\hamcrest-core-1.3.jar;E:\Java_IDEA\Java_lerannig_v3\lib\dom4j-2.1.3.jar" com.intellij.rt.testng.RemoteTestNGStarter -usedefaultlisteners false -socket60220 @w@C:\Users\Yoruko\AppData\Local\Temp\idea_working_dirs_testng.tmp -temp C:\Users\Yoruko\AppData\Local\Temp\idea_testng.tmp
Contact{name='国王', sex='male', id=1, vip=false, email='1616161'}
Contact{name='王后', sex='female', id=2, vip=true, email='56565656556'}

===============================================
Default Suite
Total tests run: 1, Passes: 1, Failures: 0, Skips: 0
===============================================

*/
```

注意：**导包要注意同名包**，尤其在用到第三方库时：

## XML检索：XPath

```java
public class XPathDemo1 {
    @Test
    public void parse01() throws Exception{
        SAXReader saxReader = new SAXReader();
        Document document = saxReader.read(XPathDemo1.class.getResourceAsStream("/hello_world.xml"));

        List<Node> nameNodes = document.selectNodes("/contactlist/contact/name");
        for (Node nameNode : nameNodes) {
            Element nameEle = (Element) nameNode;
            System.out.println(nameEle.getTextTrim());
        }
    }
}
```
