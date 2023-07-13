---
title: Java学习笔记v2
date: 2022-06-17 20:53:14
tags: 
- java
---

## 集合嵌套

在Map集合中再放List集合：

```java
package com.D2;

import java.util.*;

/**
 * 统计投票人数
 *
**/
public class MapTest {
    public static void main(String[] args) {
        **Map<String, List<String>> data = new HashMap<>();**
        //存入学生数据
        List<String> selects = new ArrayList<>();
        Collections.addAll(selects,"A","C");
        data.put("luoyong",selects);

        List<String> selects2 = new ArrayList<>();
        Collections.addAll(selects2,"B","C","D");
        data.put("hutao",selects2);

        List<String> selects1 = new ArrayList<>();
        Collections.addAll(selects1,"B","C","D","A");
        data.put("hutao2",selects1);

        System.out.println(data);
    }
}
```

存入后统计投票结果：

```java
// data = {hutao2=[B, C, D, A], hutao=[B, C, D], luoyong=[A, C]}
Map<String, Integer> infos = new HashMap<>();
// 定义集合存景点名与投票数
Collection<List<String>> values = data.values();
// 用data的api提取出所有的**值数据**作为Collection对象（其中每一个对象都是List集合）
for (List<String> value : values) {
		// value为List集合例如["A","C"]
    for (String s : value) {
				// s为List集合中的成员
        if (infos.containsKey(s)){
						// 判断是否存在info中是否存在键s，存在则值（infos.get(key)）加一
            infos.put(s,infos.get(s) + 1);
        }else {
            infos.put(s, 1);
        }
    }
}
System.out.println(infos);
```

### 不可变集合

不可修改的集合，在创建时提供数据并且在生命周期中无法修改（否则会报错），类似于**静态初始化数组**。

```java
List<Double> lists = List.of(569.5,525.5,700.5,522.0);
lists.add(111.2);
// 修改lists会报错
```

## Stream流

目的：简化集合和数组操作的API

```java
public class StreamTest {
    public static void main(String[] args) {
        List<String> names = new ArrayList<>();
        names.add("张三丰");
        names.add("张无忌");
        names.add("赵敏");
        System.out.println(names);

        List<String> zhangList = new ArrayList<>();
        for (String name : names) {
            if (name.startsWith("张")){
                zhangList.add(name);
            }
        }
        System.out.println(zhangList);

        List<String> zhangThreeList = new ArrayList<>();
        for (String name : names) {
            if (name.length() == 3){
                zhangThreeList.add(name);
            }
        }
        System.out.println(zhangThreeList);

        // 使用Stream流
        names.stream().filter(s -> s.startsWith("张")).filter(s -> s.length() == 3).forEach(s -> System.out.println(s));
				// 如上代码只需要一行，因为支持**链式编程**
    }
}

```

### Stream流的关键在**得到Stream流对象**。

1. Collection集合只需要用.stream()即可，任何集合都可通过此方法得到Stream流对象
2. Map集合需要分成键流和值流

```java
Map<String, Integer> maps = new HashMap<>();

Stream<String> keyStream = maps.keySet().stream();
Stream<Integer> valueStream = maps.values().stream();
```

也可用键值对流拿整体：

```java
Stream<Map.Entry<String, Integer>> keyAndValueStream = maps.entrySet().stream();
```

1. 数组

```java
String[] names = {"小明","小红"};

Stream<String> nameStream = Arrays.stream(names);
// 也可用Stream里的静态方法:
Stream<String> nameStream2 = Stream.of(names);
```

### Stream常用API

```java
names.stream().filter(s -> s.startsWith("张"))
```

实际上为

```java
names.stream().filter(new Predicate<String>() {
    @Override
    public boolean test(String s) {
        return s.startsWith("张");
    }
});
```

即lambda表达式。

应用—求平均工资：

```java
package com.D3_Stream;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

public class Main {
    public static double allMoney = 0;

    public static void main(String[] args) {
        List<Employee> one = new ArrayList<>();
        one.add(new Employee("张三",'男',7000.5,25500.0,null));
        one.add(new Employee("李四",'男',2000.5,2500.0,null));
        one.add(new Employee("王五",'男',8000.5,550.0,null));
        one.add(new Employee("赵三",'男',9000.5,2500.0,null));
        one.add(new Employee("钱利",'男',10000.5,5500.0,null));

        List<Employee> two = new ArrayList<>();
        two.add(new Employee("张三2",'男',700.5,25500.0,null));
        two.add(new Employee("李四3",'男',200.5,250.0,null));
        two.add(new Employee("王五4",'男',800.5,55.0,null));
        two.add(new Employee("赵三6",'男',900.5,250.0,null));
        two.add(new Employee("钱利4",'男',1000.5,500.0,null));

        Employee e = one.stream().max((o1, o2) -> Double.compare(o1.getSalary() + o1.getBonus(), o2.getBonus() + o2.getSalary())).get();
        System.out.println(e);

        TopFormer t = one.stream().max((o1, o2) -> Double.compare(o1.getSalary() + o1.getBonus(), o2.getBonus() + o2.getSalary()))
                .map(employee -> new TopFormer(e.getName(),e.getBonus() + e.getSalary())).get();
        System.out.println(t);

        // 统计平均工资且去掉最高和最低

        one.stream().sorted(new Comparator<Employee>() {
            @Override
            public int compare(Employee o1, Employee o2) {
                return Double.compare(o1.getSalary() + o1.getBonus(),o2.getBonus() + o2.getSalary());
            }
        }).skip(1).limit(one.size() - 2).forEach(employee -> {
            // 求平均值
            allMoney += (e.getSalary() + e.getBonus());
        });

        System.out.println("平均为" + allMoney / (one.size() - 2));

        BigDecimal b1 = BigDecimal.valueOf(allMoney);
        BigDecimal b2 = BigDecimal.valueOf(one.size() - 2);

        System.out.println(b1.divide(b2,2, RoundingMode.HALF_UP));

    }
}
```

### 收集Stream流

将Stream类型转成其他类型：List，Set

```java
package com.D3_Stream;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class APITest {
    public static void main(String[] args) {
        List<String> names = new ArrayList<>();
        names.add("张三丰");
        names.add("张无忌");
        names.add("赵敏");
        System.out.println(names);

//        names.stream().filter(new Predicate<String>() {
//            @Override
//            public boolean test(String s) {
//                return s.startsWith("张");
//            }
//        }).forEach(System.out::println);

        Stream<String> s1 = names.stream().filter(s -> s.startsWith("张"));
        List<String> list = s1.collect(Collectors.toList());
				// 转成List类型
        list.forEach(System.out::println);
    }
}
```

注意：流只能使用一次。收集完后的流**不能再次收集**。

## 异常

常见运行时异常：

1. NullPointerException空指针
2. ClassCastException类型转换
3. ArrayIndexOutOfBoundsException数组越界
4. NumberFormatException数字转换异常
5. ArithmeticException数学操作异常

**常见编译异常：**

日期解析异常：

```java
public class D4_Exception {
    public static void main(String[] args) {
        String date = "2015-02-28 10:28:31";

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date d = sdf.parse(date);
        System.out.println(d);
    }
}
```

需要改成

```java
public static void main(String[] args) **throws ParseException** {
        String date = "2015-02-28 10:28:31";

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date d = sdf.parse(date);
        System.out.println(d);
    }
```

### 异常处理流程

1. throw抛出异常:

谁出现谁抛出，可以有多个throw但只能有一个被抛出（抛给虚拟机后结束程序），因此可写作

```java
public void test() throws Exception{
}
```

1. 监视异常处理（可用**ctrl+alt+t**生成），不会抛出异常给JVM，可在**出现异常的方法内处理完**

```java
try{
	//主方法
} catch (Exception e){
	//解析出现的异常
	e.printStackTrace();//打印异常栈信息
}
```

1. 前两者结合

```java
public class D4_Exception {
    public static void main(String[] args){
        String date = "2015-02.28 10:28:31";
        try {
            parseTime(date);
        } **catch (Exception e) {
            e.printStackTrace();
        }**

        System.out.println("-----------------\n程序结束");

    }
    public static void parseTime(String date) **throws Exception**{
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date d = sdf.parse(date);
        System.out.println(d);
    }
}
```

**既可防止抛出异常到JVM导致结束程序，又可让上层获取底层的处理结果。**

### 自定义异常

继承Exception父类必要

### 注：**throw 与 throws区别：**

throw：用于在方法内部，直接创建一个异常对象，并从此处抛出异常

throws：用于在方法声明处，抛出方法内部异常

自定义日常实例：

```java
public class ExceptionTest extends Exception{
    public ExceptionTest() {
    }

    //调用父类构造器初始化
    public ExceptionTest(String message) {
        super(message);
    }
}
```

```java
public class ExceptionDemo {
    public static void main(String[] args) {
        try {
            checkAge(-34);
						// 调用时若不处理异常会不通过编译
        } catch (ExceptionTest e) {
            throw new RuntimeException(e);
        }
    }
    public static void checkAge(int Age) throws ExceptionTest {
        if (Age < 0 || Age > 200) {
            // 抛出异常对象给调用者
            throw new ExceptionTest(Age + " is illeagal!");
        } else {
            System.out.println("年龄合法");
        }
    }
}
```

运行时显示：

## 日志框架

实例：

```java
public class Test {
    public static final Logger LOGGER = LoggerFactory.getLogger("Test.class");

    public static void main(String[] args) {
        try {
            LOGGER.debug("main方法执行");
            LOGGER.debug("main方法执行中");
            LOGGER.info("yunx zhong ");
            int a = 10;
            int b = 15;
            LOGGER.trace("a=" + a);
            System.out.println(a / b);
        } catch (Exception e) {
            e.printStackTrace();
            LOGGER.error("出现异常" + e);

        }
    }
}
```

日志输出具体设置可用logback.xml控制。

## FILE类

```java
File f = new File("E:/workplace")
```

注：lastModified()返回long类型，可new一个SimpleDateFormat类解析转为Date类型。

多用第二个，可直接拿到**文件对象。**

**listFiles()注意：**

 1.  调用者不存在时，返回null

1. 调用者是文件时，返回null
2. 调用者为空文件夹时，返回长度为0的数组
3. 调用者为有内容的文件夹时，将所有文件和文件夹路径放在File数组中返回

## 递归

递归死循环会导致栈内存溢出。

例如计算阶乘：

```java
public class main {
    public static void main(String[] args) {
        System.out.println(f(10));

    }
    public static int f(int n){
        if (n == 1){
            return 1;
        } else{
            return f(n - 1) * n;
        }
    }
		// 先递升 再归回
}
```

递归核心：

1. 能描述问题的公式—f(n - 1) * n
2. 递归终结点—f(1)
3. 递归方式必须走向终结点

猴子吃桃问题：

```java
public class RecusionDemo {
    public static void main(String[] args) {
        System.out.println(f(1));
    }
    public static int f(int x){
        if (x == 10){
            return 1;
        }else {
            return 2 * f(x + 1) + 2;
        }
    }
/// 先递减，再归回
}
```

## 递归解决文件搜索

```java
import java.io.File;
import java.io.IOException;

/*
* 去F盘搜索文件并打开
* */
public class RecusionFIleDemo {
    public static void main(String[] args) {
        searchFile(new File("F:/"),"BGI.chs.exe");
    }

    public static void searchFile(File dir, String fileName){
        if (dir != null && dir.isDirectory()){
            File[] files = dir.listFiles();
            // 判断是否存在一级文件对象
            if (files != null && files.length > 0){
                for (File file : files) {
                    // 判断当前文件对象是文件夹还是文件
                    if (file.isFile()){
                        if (file.getName().contains(fileName)){
                            System.out.println("找到了");
                            System.out.println(file.getAbsolutePath());
                            try {
                                Runtime r = Runtime.getRuntime();
                                r.exec(file.getAbsolutePath());
                            } catch (IOException e) {
                                throw new RuntimeException(e);
                            }
                            break;

                        }
                    } else{
                        searchFile(file,fileName);
                    }
                }
            }
        }
    }
}
```

## 字符集

### 字符集编码和解码

```java
import java.util.Arrays;

public class charset {
    public static void main(String[] args) {
        String name = "abc我爱你";
        byte[] bytes = name.getBytes();//默认解码为UTF-8
        System.out.println(bytes.length);
        System.out.println(Arrays.toString(bytes));

        String rs = new String(bytes);//默认解码为UTF-8
        System.out.println(rs);
    }
}
```

## IO流

字节流可读写所有文件，字符流只能读写**文本文件**

```java
public class main {
    public static void main(String[] args) throws Exception {
        // 创建文件字节输入流管道与源文件接通
        InputStream is = new FileInputStream("E:\\Java_IDEA\\logging_test\\src\\data.txt");

//        int b1 = is.read();
//        System.out.println((char)b1);
//        int b2 = is.read();
//        System.out.println((char)b2);
//        int b3 = is.read();
//        System.out.println((char)b3);
//        int b4 = is.read();
//        System.out.println((char)b4);
        int b;
        while((b = is.read()) != -1){
            System.out.println((char)b);
        }
    }
}
```

如上为文件字节输入流的读取方法，is.read()用法。

如上每次读一个字节，一来效率低，二来无法解决中文乱码

用read()方法传入**字节数组，可每次读取三个字节：当无法读出时返回-1**

```java
byte[] buffer = new byte[3];
// 用桶装水
int len;
while((len = is.read(buffer)) != -1){
    // 读多少倒多少
    System.out.print(**new String(buffer,0,len)**);
}
```

### 避免中文乱码：一次读完所有字符

```java
public class FileInutStreamDemo2 {
    public static void main(String[] args) throws Exception {
        File f = new File("E:\\Java_IDEA\\logging_test\\src\\data.txt");

        InputStream is = new FileInputStream(f);
        byte[] buffer = new byte[(int) f.length()];
        int len = is.read(buffer);
        System.out.println("读取了" + len + "字节");
//        byte[] buffer = Files.readAllBytes(Paths.get(f.getPath()));
        System.out.println(f.length());
        System.out.print(new String(buffer));
    }
}
```

也可用**is.readAllBytes()**方法读取所有字节。

### 文件字节输出流

默认为覆盖管道，可用：

```java
OutputStream os = new FileOutputStream("/test/src/com/hit/data.txt", **true**);
```

使用追加流，不覆盖原内容。

os.write()写数据只能读取字节或字节数组，因此其他类型需要用`getBytes(StandardCharsets.*UTF_8*)`

转成字节数组。

```java
OutputStream os = new FileOutputStream("E:/Java_IDEA/logging_test/src/data1.txt");

os.write('a');
os.write(98);
// 写文件必须刷新数据，否则会用缓冲流的数据
os.flush();
os.write(10);

byte[] buffer = {'a', 98, 97, 99};
os.write(buffer);
byte[] buffer1 = "我是中国人".getBytes(StandardCharsets.UTF_8);
os.write(buffer1);
os.write("\n".getBytes(StandardCharsets.UTF_8));
os.write(buffer,0,3);

os.close();
```

文件复制：

```java
import java.io.*;
/*
* 利用字节流完成文件复制
* */
public class CopyDemo {
    public static void main(String[] args){
        try {
            InputStream is = new FileInputStream("F:\\Adult\\test\\gura.ts");

            OutputStream os = new FileOutputStream("F:\\Adult\\gura.ts");

            byte[] buffer = new byte[1024];
            int len;
						// 防止最后一个字节数组**不能全部倒出**
            while((len = is.read(buffer)) != -1){
                os.write(buffer,0,len);
            }
            os.close();
            is.close();

        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}
```

## 资源释放方式

try-catch-finally防止在资源释放前程序已退出

注：在finally中释放资源前必须要做**非空校验。**

finally中**不能写return**，因为任何return都要先执行finally。

```java
public class CopyDemo {
    public static void main(String[] args) throws Exception {
        InputStream is = null;
        OutputStream os = null;
        try {
            is = new FileInputStream("F:\\Adult\\test\\gura.ts");

            os = new FileOutputStream("F:\\Adult\\gura.ts");

            byte[] buffer = new byte[1024];
            int len;
            while((len = is.read(buffer)) != -1){
                os.write(buffer,0,len);
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally{
            if (os != null){
                os.close();
            }
            if (is != null){
                is.close();
            }

        }

    }
}
```

JDK7简化方案：

```java
public static void main(String[] args){
        try (
                // 只能防止资源对象
                // 自动释放资源
                InputStream is = new FileInputStream("F:\\Adult\\test\\gura.ts");
                OutputStream os = new FileOutputStream("F:\\Adult\\gura.ts");
        ){

            byte[] buffer = new byte[1024];
            int len;
            while((len = is.read(buffer)) != -1){
                os.write(buffer,0,len);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

    }
```

资源释放可自动进行。

()中只能放**资源对象，放置其他类型会报错。**

## 字符流

多用于读取文本，适用于不同的编码格式

读取字符数组：

```java
public class FileReaderDemo {
    public static void main(String[] args) throws Exception {
        Reader fr = new FileReader("E:/Java_IDEA/logging_test/src/data1.txt");

        char[] buffer = new char[1024];
        int len;
        while((len = fr.read(buffer))!=-1){
            String rs = new String(buffer,0,len);
            System.out.print(rs);
        }

    }
}
```

读中文不会乱码而且效率较高。

文件字符输入流

```java
Writer fw = new FileWriter("E:/Java_IDEA/logging_test/src/data2.txt", true);

fw.write(98);
fw.write('王');
fw.write('a');
fw.write("我是中国人");
char[] chars = "中国人".toCharArray();
fw.write(chars);

char[] chars1 = "abcdefg".toCharArray();
fw.write(chars1,0,2);

fw.flush();
fw.close();
///b王a我是中国人中国人ab
```

与字节输入流区别不大，但更方便，可直接写入字符串。

## 缓冲流

缓存流自带8kb缓冲区，效率更高

缓存流包装原始流，**缓冲流构造器均为接受原始流对象**：

```java
try (
        // 只能防止资源对象
        // 自动释放资源
        InputStream is = new FileInputStream("F:\\Adult\\test\\gura.ts");
        InputStream bis = new BufferedInputStream(is);

        OutputStream os = new FileOutputStream("F:\\gura.ts");
        OutputStream bos = new BufferedOutputStream(os);
        ){

    byte[] buffer = new byte[1024];
    int len;
    while((len = bis.read(buffer)) != -1){
        bos.write(buffer,0,len);
    }

} catch (Exception e) {
    e.printStackTrace();
}
```

性能比较：

```java
public static void copy2(){
    long startTime = System.currentTimeMillis();
    try(
            InputStream is = new FileInputStream(SRC_FILE);
            OutputStream os = new FileOutputStream(DEST_FILE + "video1.mp4");
    ) {
        byte[] buffer = new byte[1024];
        int len;
        while((len=is.read(buffer))!=-1){
            os.write(buffer,0,len);
        }
        System.out.println("复制完成！");
    } catch(Exception e){
            e.printStackTrace();
}
    long endTime = System.currentTimeMillis();
    System.out.println("原始流一个一个字节数组读取所耗时间为" + (endTime - startTime)/1000.0 + "s");

}
public static void copy3(){
    long startTime = System.currentTimeMillis();
    try (
            // 只能防止资源对象
            // 自动释放资源
            InputStream is = new FileInputStream(SRC_FILE);
            InputStream bis = new BufferedInputStream(is);

            OutputStream os = new FileOutputStream(DEST_FILE + "video2.mp4");
            OutputStream bos = new BufferedOutputStream(os);
    ){

        byte[] buffer = new byte[1024];
        int len;
        while((len = bis.read(buffer)) != -1){
            bos.write(buffer,0,len);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
    long endTime = System.currentTimeMillis();
    System.out.println("缓冲流一个一个字节数组读取所耗时间为" + (endTime - startTime)/1000.0 + "s");

}
```

运行结果：

```java
复制完成！
原始流一个一个字节数组读取所耗时间为10.044s
缓冲流一个一个字节数组读取所耗时间为1.535s
```

### 文件字符缓冲流

readline方法按行读取，很常用

```java
public class char_buffer {
    public static void main(String[] args) {
        try(
        Reader fr = new FileReader("E:/Java_IDEA/logging_test/src/data2.txt");
        BufferedReader br = new BufferedReader(fr);
        ){
            **String line;
            while((line=br.readLine())!=null){
                System.out.println(line);**
            }
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
```

## 转换流

InputStreamReader用于解决文件字符流读写编码不一致时的报错。

## 对象序列化

使用对象字节输出流**ObjectOutputStream**

```java
public class ObjectOutputStreamDemo {
    public static void main(String[] args) throws Exception{
        Student s = new Student("hck",19,"hachika","123456");
        ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream("E:\\Java_IDEA\\logging_test\\src\\obj.txt"));

        oos.writeObject(s);
        oos.close();
    }
}
```

注：序列化的类必须实现了可序列化接口，即

```java
public class Student implements Serializable {}
```

## 反序列化

ObjectInputStream

```java
public class ObjectInputStreamDemo {
    public static void main(String[] args) throws Exception {
        ObjectInputStream is = new ObjectInputStream(new FileInputStream("E:\\Java_IDEA\\logging_test\\src\\obj.txt"));
        Student student = (Student) is.readObject();
        System.out.println(student);
    }
}
```

注：

```java
private transient String passWord;
```

用**transient**修饰的变量不能序列化。

```java
private static final long serialVersionUID = 0;
```

序列化版本号与反序列化必须一致。

## 打印流

```java
public class Demo1 {
    public static void main(String[] args) throws Exception{
        PrintStream ps = new PrintStream(new FileOutputStream("E:\\Java_IDEA\\logging_test\\src\\data5.txt"));
        ps.println(98);
        ps.println("我是中国人");
        ps.println("w");
        ps.println('a');
        ps.close();
    }
}
```

### 打印流是最强大的输出流，可将上面所有输出流替代。

注：打印流默认为**覆盖管道**

若用追加需要：

```java
PrintStream ps = new PrintStream(new FileOutputStream("path/data.txt",true));
```

### 打印流实现输出重定向

```java
public static void main(String[] args) throws Exception{
        PrintStream ps = new PrintStream(new FileOutputStream("E:\\Java_IDEA\\logging_test\\src\\data5.txt"));
        ps.println(98);
        ps.println("我是中国人");
        ps.println("w");
        ps.println('a');

        System.setOut(ps);
					///将默认打印地址修改为上面的文件地址
        System.out.println("呃呃呃");
					///此时不能打印在控制台
				ps.close();
    }
```

## Properties（属性）

存数据：

```java
public class Demo1 {
    public static void main(String[] args) throws Exception {
        // 将键值对参入文件中

        Properties properties = new Properties();
        properties.setProperty("admin","123456");
        properties.setProperty("dlei","014520");

        System.out.println(properties);
/*      参数为注释，可不写
* */
        properties.store(new FileWriter("E:\\Java_IDEA\\logging_test\\src\\data5.txt"),"this is user");

    }
}
```

读数据：

```java
public class demo2 {
    public static void main(String[] args) throws Exception{
        Properties properties = new Properties();
        System.out.println(properties);

        properties.load(new FileReader("E:\\Java_IDEA\\logging_test\\src\\data5.txt"));
        System.out.println(properties);
        System.out.println(properties.getProperty("admin"));
    }
}
```

## IO框架：commons-io框架

一行代码完成复制

```java
import org.apache.commons.io.IOUtils;
public class CommonIODemo {
    public static void main(String[] args) throws Exception{
        IOUtils.copy(new FileInputStream("E:\\Java_IDEA\\logging_test\\src\\data5.txt"),
				new FileOutputStream("E:\\Java_IDEA\\logging_test\\src\\data6.txt"));
    }
}
```