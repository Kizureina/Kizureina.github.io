---
title: Java学习笔记v1
date: 2022-04-14 20:53:14
tags: 
- java
---

# Note of Java Learning

# Java 语法基础

### 引用

Java中有**引用**的概念，类似于C语言的指针。

例如**改变指向数组指针（引用数组）**的值：

![1111.](https://files.catbox.moe/jqgme2.png)

数组也好，字符串通过地址引用也好，都与指针如出一辙嘛。

## for each

```java
public class Main {
    public static void main(String[] args) {
        int[] ns = { 1, 4, 9, 16, 25 };
        for (**int n : ns**) {
            System.out.println(n);
        }
    }
}
```

int n定义变量，“**:**”用于遍历数组。

此时n直接拿到数组的元素，无需索引，若用ns[i]这种形式存在索引。

## 输入输出

```java
Scanner scanner = new Scanner(System.in);
// 创建Scanner对象
System.out.print("Input your name: ");
// 打印提示
String name = scanner.nextLine();
// 读取一行输入并获取字符串
System.out.print("Input your age: ");
// 打印提示
int age = scanner.nextInt();
// 读取一行输入并获取整数
System.out.printf("Hi, %s, you are %d\n", name, age);
// 格式化输出
```

## Java面向对象

一个.java源文件可以定义多个类，但**只能有一个public class** 且类名需要与文件名相同

![](https://files.catbox.moe/jmmck9.png)

类内有field和method，若定义private field，则不能从类外直接操作field值，但可以调用类内的public方法来间接操作field，在类内方法可以**加赋值的限制条件**，以此来解耦合。

```java
package com.hit.demo;

public class Hello {
    public static void main(String[] args) {
        Person gf = new Person();
        gf.name = "AzusaSeren";
        gf.age = 27;
        System.out.println(gf.name);
        System.out.println(gf.age);
        gf.setScore(95.5);
        gf.setWeight(44.5);
        double weight = gf.getWeight();
        double score = gf.getScore(95,62);
        System.out.println(weight+"\n"+score);
    }
    static class Person {
        public String name;
        public int age;
        private double score;
        private double weight;
        public void setScore(double score) {
            this.score = score;
        }
        public double getScore(double bestScore, double lastScore) {
            calcScore(bestScore,lastScore);
            return this.score;
        }
        private void calcScore(double bestScore, double lastScore) {
            this.score = bestScore - lastScore;
        }
        public void setWeight(double weight) {
            this.weight = weight;
        }
        public double getWeight() {
            return this.weight;
        }
    }
}
```

`Person gf = new Person();`为定义一个**引用类型为Person的变量gf指向一个Person类的实例**。

private method不能从外部调用，只能在类内调用。

这说明方法可以**封装一个类的对外接口**，调用方不需要知道也不关心`Person`实例在内部到底有没有score。

### this关键字

```java
class Person {
    private String name;

    public void setName(String name) {
        this.name = name; // 前面的this不可少，少了就变成局部变量name了
    }
}
```

this.name是类的field，第二个name是方法的局部变量。

### 可变参数

```java
class Group {
    private String[] names;

    public void setNames(String... names) {
        this.names = names;
    }
}
```

调用方法赋值时：

```java
Group.setNames("Azusa","Seren");
Group.setNames("hck");
Group.setNames();
```

以上均可，另外java在给字符串数组赋值时需要**new一个字符串对象**：

```java
String[] names = new String[] {"hck", "azusa"};
//赋值时:
Group.setNames(new String[] {"hck", "azusa"});
```

## 构造方法

```java
public static void class main(){
	City test = new City("Beijing",500);
	System.out.println(test.getName());
	System.out.println(test.getAge());	
}
class City{
	private String name;
	private int age;
	
	**public City(String name, int age)**{
		this.name = name;
		this.age = age;
	}
	public String getName(){
		return this.name;	
	}
	public int getage(){
		return this.age;
	}
}
```

如上，类似于PHP的魔术函数__construct__()，构造函数可在**对象调用时直接传参赋值**。

若在类内已经赋值：

```java
class Perosn{
	private String sex = "male";
	public String Person(String sex){
		this.sex = sex;
		return sex;
	}
}
```

但在调用时又赋值，以后赋值为准。

注：构造方法无法返回值，只需用public修饰符即可。

## 方法重载

方法名相同，但功能不同的一组方法：

```java
class Person{
	private String name;
	private int age;
	private int sex;
	public void person(String name){
			this.name = name;
	}
	public void person(int age){
			this.age = age;
	}
	public void person(int sex){
			this.sex = sex;
	}
}
```

调用时：

```java
public static void class main(){
		Person p = new Person();
		p.person("Azusa");
		p.perosn(15);
		p.person(2);
} 
```

## 继承

可用extends关键字继承父类的属性和方法：

```java
static class Person{
        protected String name;
        private int age;
        public void person(String name){
            this.name = name;
        }
        public void person(int age){
            this.age = age;
        }
        public int getAge(){
            return this.age;
        }
        public String getName(){
            return this.name;
        }
    }
    **static class Student extends Person**{
        static int SCORE_BEST = 100;
        private double score;
        public String hello(){
            return "hello" + name;
        }
        public void setScore(double score){
            if (score > 0 && score <= SCORE_BEST) {
                this.score = score;
            }
            else {
                this.score = 0;
            }
        }
        public double getScore(){
            return score;
        }
    }
```

但注意：实例化子类后，新实例会自动继承所有父类的属性和方法，但**无法访问父类实例化复制后的private属性**，只能访问public和protected。

例如上例实例化后：

```java
public static void class main(String[] arags){
	Person p = new Person(15);
	Student stu = new Student();
}
```

在子类内无法访问父类的age属性，也就得不到15的赋值。

`protected`关键字可以把字段和方法的访问权限控制在继承树内部，一个`protected`
字段和方法可以被其子类，以及子类的子类所访问。

若从子类访问父类属性，且已经有同名变量，可用super关键字：

```java
public Student extends Person{
	private int stuAge;
	public void setStuAge(int age){
		this.stuAge = age;
	}
	public String getAge(){
		return "Your father's age is " + **super**.age;
		return "Your age is " + this.stuAge;
	}
}
```

由于子类*不会继承*任何父类的构造方法。子类默认的构造方法是编译器自动生成的，不是继承的。

super关键字还可用于调用父类构造方法：

```java
class Student extends Person {
    protected int score;

    public Student(String name, int age, int score) {
        super(name, age); // 调用父类的构造方法Person(String, int)
        this.score = score;
    }
}
```

## 多态与覆写

子类中存在与父类的方法名完全相同的方法，而且此方法返回值也相同，称之为覆写。

```java
class Person {
    public void run() {
        System.out.println("Person.run");
    }
}
class Student extends Person {
    @Override
		//编译器检查是否为覆写（即检查方法名与返回值）
    public void run() {
        System.out.println("Student.run");
    }
}
```

那如果调用子类时，究竟执行哪一个？

例如

```java
Person p = new Student();
p.run();
```

实际运行时执行的不是引用标识的Person，而是Student，即调用时的实例是动态的，这种面向对象的特性称之为“多态”。

多态的意义是复用代码，大大提高程序的**可扩展性**。

### 子类调用父类中被覆写过的方法

```java
class Person{
		protected String name;
		public String hello(){
			return "Hello " + name;
	}
}
class Student extends Perosn{
	 public String hello(){
		return super.hello() + " !";
	}
} 
```

## final修饰符

可阻止子类继承父类的方法，或阻止子类继承父类

```java
final class Person {
    protected String name;
}

// compile error: 报错，不允许继承自Person
Student extends Person {
}
```

## 抽象类 面向抽象编程

只有规范没有具体实现的类称为抽象类：

```java
public class Main {
    public static void main(String[] args) {
        Person p = new Student();
        p.run();
    }
}

**abstract** class Person {
    public abstract void run();
}

class Student extends Person {
    @Override
    public void run() {
        System.out.println("Student.run");
    }
}
```

Person类的run方法无具体实现，需要在子类内对该方法进行覆写

```java
public class Main() {
	public static void main(String[] args) {
		Perosn p1 = new Student();
		Person p2 = new Teacher();
		**p1.run();
		p2.run();**
	}
}
```

这样在调用run()方法时不用关心实际方法来自哪个子类的覆写。

**面向抽象编程**的本质就是：

- 上层代码只定义规范（例如：`abstract class Person`）；
- 不需要子类就可以实现业务逻辑（正常编译）；
- 具体的业务逻辑由不同的子类实现，调用者并不关心。

## 接口

当一个抽象类没有属性，只有抽象方法时，称之为**接口**。

```java
interface class Person{
	Sting setName(String name);
	void run();
}
```

接口中所有方法都是默认“abstract public”的。

### default关键字

若接口需新增方法但非所有子类都需要，可用default关键字修饰新方法

```java
public class Main {
    public static void main(String[] args){
        Person p = new Student("hck");
        p.run();
    }
}
interface Person{
    String getName();
    **default void run()**{
        System.out.println("hello " + getName());
    }
}
class Student implements Person{
    private String name;
    public Student(String name){
        this.name = name;
    }
    public String getName(){
        return name;
    }
}
```

## Static关键字

### 静态属性

```java
public class Main(String[] args){
	public static void main(){
		Person p1 = new Person(1111);
    Person p2 = new Person(2222);
    int a1 = p1.age = 1111;
    int a2 = p2.age = 2222;
    **Person.score = 95.5;
    Person.score = 99.5;
		//只能用类操作静态属性**
    System.out.println(a1 + "\n" + a2);
    System.out.println(Person.score);
	}
}
class Person{
		public int age;
    public static double score;
    public Person(int age){
        this.age = age;
	}
}
```

age属于Person类，实例化后会有一个独立的内存空间存放。而静态属性score为共享内存空间，不能通过实例来操作，只能通过类来操作（类似于作用域不同）：

**一般属性指向实例，静态属性指向类。**

注：interface即接口不能有实例属性，但可以有静态属性：

```java
public interface Person {
    // 编译器会自动加上public static final:
    int MALE = 1;
    int FEMALE = 2;
		// 实际为public static final int FEMALE = 2;
}
```

### 静态方法

调用实例方法必须通过一个实例变量，例如

```java
Person p = new Person();
//p为实例变量
p.run();
```

而调用静态方法则**不需要实例变量**，通过类名就可以调用。静态方法类似其它编程语言的**函数**。

```java
public class Main {
    public static void main(String[] args) {
        Person.setNumber(99);
        System.out.println(Person.number);
    }
}

class Person {
    public static int number;

    public static void setNumber(int value) {
        number = value;
				//不能调用类内的属性（实例化得到值），只能调用静态属性
    }
}
```

## 作用域

java支持边用边定义，使用局部变量时，应该尽可能把局部变量的作用域缩小，尽可能延后声明局部变量。

```java
package abc;

public class Hello {
    void hi(String name) { // ①
        String s = name.toLowerCase(); // ②
        int len = s.length(); // ③
        if (len < 10) { // ④
            int p = 10 - len; // ⑤
            for (int i=0; i<10; i++) { // ⑥
                System.out.println(); // ⑦
            } // ⑧
        } // ⑨
    } // ⑩
}
```

例如变量 i只在循环内有作用域。

Java内建的访问权限包括`public`、`protected`、`private`和`package`权限；

Java在方法内部定义的变量是局部变量，局部变量的作用域从变量声明开始，到一个块结束；

`final`修饰符不是访问权限，它可以修饰`class`、`field`和`method`；

一个`.java`文件只能包含一个`public`类，但可以包含多个非`public`类。

## 异常处理

异常是一种`class`，因此它本身带有类型信息。异常可以在任何地方抛出，但只需要在上层捕获，这样就和方法调用分离了。

```java
public class Main {
    public static void main(String[] args) {
        byte[] bs = toGBK("中文");
        System.out.println(Arrays.toString(bs));
    }

    static byte[] toGBK(String s) {
		//toGBK方法返回值为byte[]
        try {
            // 用指定编码转换String为byte[]:
            return s.getBytes("GBK");
        } catch (UnsupportedEncodingException e) {
            // 如果系统不支持GBK编码，会捕获到UnsupportedEncodingException:
            System.out.println(e); // 打印异常信息
            return s.getBytes(); // 尝试使用用默认编码
        }
    }
}
```

以上用到了getBytes()方法，必须捕获UnsupportedEncodingException才能过编译。

getBytes定义：

```java
public byte[] getBytes(String charsetName) throws UnsupportedEncodingException {
    ...
}
```

这是因为在该方法定义的时候，使用`throws Xxx`表示该方法可能抛出的异常类型。调用方在调用的时候，**必须强制捕获这些异常**，否则编译器会报错。

在`toGBK()`方法中，因为调用了`String.getBytes(String)`方法，就必须捕获`UnsupportedEncodingException`。

在测试时若为方便，可抛出所有异常：

```java
public static void main(String[] args) throws Excpetions{
.....
}
```

## 抛出异常

异常被抛出时，会一直向上层传递，直到被catch。

```java
public class Main {
    public static void main(String[] args) {
        try {
            process1();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    static void process1() {
        process2();
    }

    static void process2() {
        Integer.parseInt(null); // 会抛出NumberFormatException
    }
}
```

运行上面这段代码返回

![](https://files.catbox.moe/4c15us.png)

显示调用栈，可见异常为一层一层向上传播至main被捕获的。

## 断言（Assert）

```java
Public class main(){
	public static void main(String[] arags){
		double x = Math.abc(-123.45);
		assert x >= 0 : "X must > 0.";
		System.out.println(x);
	}
}
```

判断x是否大于0，若否则退出程序报错抛出**AssertionError：X must > 0.**

需要在命令行加参数运行才能使用断言，直接运行JVM会把该行忽略：

![Untitled](https://files.catbox.moe/dijgqv.png)

**注：**

在命令行运行java需要先用

```bash
javac com\hit\demo\Main.java
#编译出Main.class文件
```

再用java包名+类名的格式运行该文件即可，必须在src文件运行且加包名，否则会报错。

具体参见：[Java命令行运行错误: 找不到或无法加载主类](https://blog.csdn.net/gao_zhennan/article/details/112749742)

对于可恢复的异常不能用断言，不可恢复的异常多用单元测试，实际很少用断言。

## String对象

比较字符串：

```java
 public class StringTest1 {
    public static void main(String[] args) {
        String okName = "1111";
        String passWord = "12345678";
        Scanner scanner = new Scanner(System.in);
        String name = scanner.next();
        String psd = scanner.next();
        if (name == okName && psd == passWord){
            System.out.println("You're right!");
        }else {
            System.out.println("NO!");
        }
    }
}
```

上述代码无法完整功能，因为用双引号定义的字符串存储在**字符串常量池**，而用scanner接受new出来的字符串存储在**堆内存**，因此二者即便内容相同，其**地址**不同无法用==比较字符串变量(存储字符串地址)，而该用String对象的equals方法:

```java
if (**name.equals(okName) && psd.equals(passWord**)){
            System.out.println("You're right!");
        }else {
            System.out.println("NO!");
        }
```

## 类修饰符

private修饰符修饰的变量属于类实例化出来的对象，不属于类，因此不能直接通过**类名**访问。即为实例成员变量。

static修饰符变量为静态成员变量（与实例成员变量相对），属于类，在定义的时候就已加载在内存中，可共享访问——以直接通过实例访问，也可以通过类名访问，同一个类内可以直接用变量名访问。

![Untitled](https://files.catbox.moe/etib7v.png)

静态方法：与**对象属性无关的通用功能方法**，方便同一个类中直接访问，无需实例化对象。不能方法实例属性，不能出现this关键字。

实例方法：需要访问对象的属性，非通用方法。

注：静态方法多用于工具类中，工具类的构造方法多用private修饰来阉割。

## 静态代码块与实例代码块

```java
public class StaticCode {
    public static String Schoolname;
    public static ArrayList<String> cards = new ArrayList<>();
    static {
        System.out.println("----静态代码块执行");
        Schoolname = "aiheima";
    }
		//静态代码块
    StaticCode(){
        System.out.println("构造器被触发");
    }
    {
        System.out.println("实例代码块被触发");
    
		//实例化代码块
    public static void main(String[] args) {
        StaticCode s1 = new StaticCode();
    }
}
```

## 单例设计模式

通过单例类拿对象，只加载一次：

```java
public class singleInstance {
    public static singleInstance instance = new singleInstance();

    private singleInstance(){
    }
}
```

如上为饿汉单例，在创建类的同时加载类。

拿对象时:

```java
public class Test1{
		public static void main(String[] args) {
        singleInstance s1 = singleInstance.instance;
    }
}
```

懒汉单例：在需要对象的时候才创建单例

```java
public class lanHan {
    private static lanHan instance;

    public static lanHan getInstance(){
        if (instance == null){
						//实例只加载一次
            instance = new lanHan();
        }
        return instance;
    }

    private lanHan(){}

}
```

```java
public class Test1 {
    public static void main(String[] args) {
        lanHan s1 = lanHan.getInstance();
        lanHan s2 = lanHan.getInstance();
        System.out.println(s1);
        System.out.println(s2);
				//s1 == s2
    }
}
```

## 继承

子类可以继承父类私有成员，但无法访问。

子类只能继承一个父类。

可用super关键字访问父类方法和有参数构造器。

```java
public class Teach extends Person{
    public Teach(){
        // 若定义了有参数构造器，则必须定义无参数构造器
    }
    public Teach(String name, int age){
        super(name,age);
        // 用于指定父类有参数构造器
    }
}
```

```java

public class Person {
    private String name;
    private int age;

    public Person(){}
    public Person(String name,int age){
        this.name = name;
        this.age = age;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }
}

```

## this()

```java
public class Students {
    private String name;
    private int age;
    public Students(){}
    **public Students(String name){
        this(name,111111);
				// 可设定默认参数传入构造器
    }**
    public Students(String name,int age){
        this.age = age;
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }
}
```

```java
public class Test1 {
    public static void main(String[] args) {
        Students s1 = new Students("张三",111);
        System.out.println(s1.getName());
        Students s2 = new Students("李四");
        System.out.println(s2.getAge());
    }
}
```

this()用于在类内调用兄弟构造器。

注：**this()与super()在构造器中都只能在第一行（故不能共存于构造器中）**，即优先初始化父类构造器或者兄弟构造器。

![Untitled](https://files.catbox.moe/cqo2dk.png)

## 方法重写

```java
public class ReWrite {
    public static void main(String[] args) {
        NewPhone hw = new NewPhone();
        hw.call();
        hw.sendMsg();
    }
}
class NewPhone extends Phone{
    @Override
    // 重写校验注解
    public void call(){
        // 方法重写
        super.call();
        System.out.println("开始视频");
    }
		@Override
    public void sendMsg(){
        super.sendMsg();
        System.out.println("发送图片");
    }
}

class Phone{
    public void call(){
        System.out.println("打电话");
    }
    public void sendMsg(){
        System.out.println("发信息");
    }
    public static void test(){
        //静态方法不能被子类重写
    }
}
```

方法重写只用于子类中重写父类的方法，来增加子类的功功能。

## Protected修饰符

只能被同一包内类或者**不同包的子类**访问。

![Untitled](https://files.catbox.moe/dg1jda.png)

## final修饰符

1. 修饰类：不能产生子类
2. 修饰方法：不能重写
3. 修饰变量：有且仅有一次赋值（约等于const）

注：修饰引用变量时，地址值不变，但**地址指向的对象内容可改变**

## 常量

public static final修饰的变量，必须有初始化值，且执行中其值不能改变。

常量在编译阶段会进行宏替换，方便维护。

## 枚举

用于信息分类和标志的**数据类型**

枚举的优势：可读性好，入参约束严谨（相比常量）

## 抽象类

抽象方法只能声明，**不能写方法体**。

抽象类是不完整的设计图，通常用作父类来给子类继承(抽象类作为标准约束子类，只能复写)。

```java
public abstract class Animal{
	public abstract void run();
}
```

继承抽象类的子类**必须重写所有抽象类的抽象方法**。

1. 类的成员（构造器，属性，方法）在抽象类中都有。
2. 抽象类可没有抽象方法，但抽象方法一定需要在抽象类中。
3. 抽象类不能创建对象。

抽象类中的非抽象方法可用于做**模板方法, 多用final修饰：**

## 接口（Interface）

接口中所有方法都是public abstract，可省略。

接口不能继承，需要用**实现：**

```java
public class PingPongMan implements SportsMan {
    private String name;
    public PingPongMan(String name){
        this.name = name;
    }

    @Override
    public void run() {
        System.out.println("跑步");
    }

    @Override
    public void competition() {
        System.out.println("比赛");
    }
}
```

```java
package com.advanced.d8;

public interface SportsMan {
    void run();
    void competition();
}
```

接口与接口：1. 接口支持多实现，即**public class main implements Law, Others{}**

1. public interface SportsMan implements Law{}

## 多态

同类型对象，执行同一方法，出现不同**行为**结果称之为**多态**。

```java
public class Test {
    public static void main(String[] args) {
        Animal d = new Dog();
        d.run();
				
        Animal b = new Bird();
        b.run();
				// 不同结果
    }
}
```

```java
public class Test {
    public static void main(String[] args) {
        Animal d = new Dog();
        System.out.println(d.name);

        Animal b = new Bird();
        System.out.println(d.name);
				// 均为父类Animal的属性name值
    }
}
```

劣势：多态下无法调用子类独有的功能

```java
public class Test {
    public static void main(String[] args) {
        Animal d = new Dog();
        d.run();

        Bird b = new Bird();
        b.run();
        Bird b2 = b;
        // 父类型到子类型，必须强制类型转换
        b2.layEgg();

        //Dog d1 = (Dog) b;
        // 这句运行会报错，转换后的类型不同

        go(new Dog());
        go(new Bird());
    }
    public static void go(Animal a){
        a.run();
        if (a instanceof Bird){
            Bird b = (Bird) a;
            b.layEgg();
        }else {
            Dog d = (Dog) a;
            d.lookDorr();
        }

    }
}
```

如上，可用强制类型转换来解决不能访问子类独有功能的问题。

## 内部类

内部类即定义再类里面的类：

```java
public class People{
		public class Heart{
		}
}
```

内部类可以方便地访问外部类private变量

### 静态内部类

```java
public class InnerClass {
    public static int a = 10;
    public static class Iner{
        private String name;
        private int age;
        public static String shoolName;

        public void show(){
            System.out.println("名称" + name);
            System.out.println(a);
        }
```

1. 静态内部类可直接访问外部静态变量。
2. 不能直接访问外部类实例成员，要访问需要先new一个外部类对象
3. 用的很少

### 成员内部类

```java
public class Outer {
    public static String names = "111";
    public class Inner{
        private String name;
        private int age;

        public Inner() {
        }
        public static void show(){
            System.out.println("name" + names);
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public int getAge() {
            return age;
        }

        public void setAge(int age) {
            this.age = age;
        }

        public Inner(String name, int age) {
            this.name = name;
            this.age = age;
        }
    }
}
```

```java
public class Test1 {
    public static void main(String[] args) {
        **Outer.Inner i = new Outer().new Inner();
				// 先实例化外部类，再在外部类对象实例化内部类对象。**
        i.setAge(10);
        i.setName("张三");
        Outer.Inner.show();
					//调用内部类静态方法
    }
}
```

1. 成员内部类可直接访问外部类**实例成员**变量。
2. 访问外部类对象成员用**Outer.this.heartBeat**
3. 较静态内部类用的更多

## 匿名内部类（重要）

一种没有名字的局部内部类，定义在方法中和代码块（例如static{ }）中。

作用：**方便创建子类对象，无需定义子类即可调用**。

```java
package com.advanced.d10;

public class Main {
    public static void main(String[] args) {
        **Animal a = new Animal() {
            @Override
            public void run() {
                System.out.println("跑的块");
            }
        };**
        a.run();
    }
}

//class Tiger extends Animal{
//    @Override
//    public void run() {
//        System.out.println("老虎跑的块");
//    }
//}

abstract class Animal{
    public abstract void run();
}
```

1. 匿名内部是自身的对象，非父类抽象类或接口的对象（抽象类不能实例化成对象）
2. 匿名内部类对象相当于new之前的类的子类对象。

![Untitled](https://files.catbox.moe/cagava.png)

**对象回调：匿名内部类实例化的对象可直接作为参数传入方法。**

匿名内部类可实现简化代码。

## 常用API

### object

toString()默认打印地址，多在子类中重写方法打印对象内容。

equals()比较对象地址，也可在子类中重写：

```java
/*s1.equals(s2)*/
@override
public boolean equals(Object o){
		if(o instanceof Student){
			Student s2 = (Student) o;
			// 必须强制类型转换，o为object类型，内没有s2的对象内容
			if(this.name.equals(s2.name)){
				return true;		
		}else{
				return false		
}
	}else{
		return false;
	}
}
```

```java
if(this.name.equals(s2.name)){
				return true;		
		}else{
				return false	}
// 可写作
return this.name.equals(s2.name);
```

## StringBuilder类

操作字符串较String性能更好，而且可修改。

因为String对象不可变，只能在拼接字符串时每次都创建新字符串，而StringBuilder只需要在堆内存内操作一个对象即可。

```java
public class Test5 {
    public static void main(String[] args) {
        StringBuilder sb = new StringBuilder();
        sb.append("aaaaaaaa");
        sb.append("1111");
        System.out.println(sb);

        StringBuilder s1 = new StringBuilder();
        **s1.append("a").append("bbbb").append("2222");
        // 支持链式编程**
        System.out.println(s1);
    }
}
```

sb.append()方法可在完成后再返回字符串对象，因此支持**链式编程。**

注：StringBuider只能操作拼接字符串的手段，最后还是要转成String类型

```java
StringBuilder sb = new StringBuilder();
sb.append("aaaaaaaa");
String s = sb.toString();
```

实例

```java
public class TestStringBuilder {
    public static void main(String[] args) {
        int[] arr = {111,888,89,979,49,4,94,94,9,49};
        System.out.println(toString(arr));
    }

    public static String toString(int[] arr){
        if (arr != null){
            StringBuilder sb = new StringBuilder("[");
            for (int i = 0; i < arr.length; i++) {
                sb.append(arr[i] ).append(i == arr.length - 1 ? "": ",");
								//判断是否为最后一个int
            }
            sb.append("]");
            return sb.toString();
        }else{
            return null;
        }
    }
}
```

## Math类

```java
public class MathTest {
    public static void main(String[] args) {
        System.out.println(Math.abs(10));
        System.out.println(Math.floor(1.2));
        System.out.println(Math.pow(2,3));
        System.out.println(Math.random());
        //0 - 1.0包前不包后的随机数
        System.out.println(Math.round(4.49));
        System.out.println(Math.round(4.5));
        //四舍五入
    }
}
```

## System类

![Untitled](https://files.catbox.moe/8356xq.png)

### BigDecimal类

```java
double b = 10.0;
BigDecimal b1 = BigDecimal.valueOf(b);
```

不能直接new对象和构造器，**需要用valueOf方法转**。

注：只能用于精确运算，除不尽时需要用a.divide(b1, 2, RoundingMode.HELP_UP)

### SimpleDateFormat类

```java
public class DateDemo1 {
    public static void main(String[] args) {
        Date d = new Date();
				// d = System.CurrentTimeMillis() + 121 * 1000
				//当前时间121秒后的时间
        System.out.println(d);

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy年MM月dd日 HH:mm:ss EEE a");

        String rs = sdf.format(d);
        System.out.println(rs);

    }
}
```

时间计算：

```java
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Test1 {
    public static void main(String[] args) throws ParseException {
        String dateStr = "2021年08月06日 11:11:11";
        // 解析为日期对象（重点）

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy年MM月dd日 HH:mm:ss");

        Date d = sdf.parse(dateStr);

        long time = d.getTime()  + (2L*24*60*60 + 14*60*60 + 49*60 + 6) * 1000;
        // L为所有数据以long进行计算

        System.out.println(sdf.format(time));
    }
}
```

## 包装类

基本数据类型的引用类型

```java
public class BaoZhuanglei {
    public static void main(String[] args) {
        int a = 10;
        Integer a1 = 10;
        Integer a2 = a;
        int a3 = a1;

        double db = 11.9;
        Double d2 = db;
        double d3 = d2;
    }
}
```

容错率高，兼容null：

```java
Integer age = null;
//不会报错，因为是引用类型
Integer a = 10;
```

最有用的做法：**可把字符串类型数值转换为真实的数据类型**：

```java
String str = "213";
int age = Integer.parseInt(str);
System.out.println(age);

String str2 = "99.5";
double d = Double.parseDouble(str2);
// 也可用**double d = Double.valueOf(str2);**
System.out.println(d);
```

## 正则表达式

多用于数据校验：String类的**matches**方法可匹配正则表达式

```java
public class RegexDmoe {
    public static void main(String[] args) {
        System.out.println(checkqq("15591991"));
    }

    public static Boolean checkqq(String qq){
        return qq != null && qq.matches("\\d{6,20}");
				// 校验数据为六到二十位且全部为d(0~9)
    }
}
```

![Untitled](https://files.catbox.moe/hsud0z.png)

提取信息：

```java
public class RegexDemo2 {
    public static void main(String[] args) {
        String name = "张三daddawda李四dwadawdawwad";
        String[] names = name.split("\\w+");
        // 以w切割字符串进入字符串数组   
        for (int i = 0; i < names.length; i++) {
            System.out.println(names[i]);
        }
				//张三 李四
    }
}
```

```java
public class RegexDemo2 {
    public static void main(String[] args) {
        String name = "张三daddawda李四dwadawdawwadhouchangkun@gmail.com49494949449949dwa9aaddwa49aw4d94";

        String regex = "(\\w{1,30}@[a-zA-z\\d]){2,20}((\\.[a-zA-Z0-9])" +
                "{2,20}){1,2}|(1[3-9]\\d{9})|(0[1-9]{2,6}--?\\d{5,20})|(400-?\\d{3,9}-?\\d{3,9})|\\W+";
        //“-?"表示-可有可无

        Pattern pattern = Pattern.compile(regex);

        Matcher matcher = pattern.matcher(name);
				// 匹配器对象
        while (matcher.find()){
            String r1 = matcher.group();
            System.out.println(r1);
        }
    }
}
```

## Arrays类

1. Arrays.toString(arr)打印数组内容
2. Arrays.sort(arr)排序数组（默认升序排序）
3. Arrays.binarySearch(arr, 22)二分查找返回搜索数据的位置，只能用于排好序的数组（查找不到则返回-1）

## Lambda表达式

作用：简化匿名内部类的代码写法

```java
(匿名内部类被重写方法的形参列表)->{
方法体;
}
```

注意：匿名内部类只能简化**函数式接口（接口中必须只有一个抽象方法）**的匿名内部类。

例如：

```java
public class Main {
    public static void main(String[] args) {
//        Swimming s = new Swimming() {
//            @Override
//            public void swim() {
//                System.out.println("老师游泳");
//            }
//        };
//        go(s);
        **Swimming s = () -> {
            System.out.println("老师游泳");
        };**
        go(s);

        System.out.println("-----------");
        go(() ->{
            System.out.println("--老师游泳--");
        });
				go(() -> System.out.println("--老师游泳--"));
        
    }

    public static void go(Swimming s){
        s.swim();
    }
}
@FunctionalInterface
interface Swimming{
    void swim();
}
```

Lambda也可继续简化：

```java
package com.LambdaTest;

import java.util.Arrays;
import java.util.Comparator;

public class Demo {
    public static void main(String[] args) {
        Integer[] arr = {12,59,4,49,49,9};

        Arrays.sort(arr, new Comparator<Integer>() {
            @Override
            public int compare(Integer o1, Integer o2) {
                return o2 - o1;
            }
        });
        System.out.println(Arrays.toString(arr));

        Arrays.sort(arr, (Integer o1, Integer o2) -> {
            return o2 - o1;
        });
        System.out.println(Arrays.toString(arr));

        **Arrays.sort(arr, ((o1, o2) -> o2 - o1));**
        System.out.println(Arrays.toString(arr));
    }
}
```

## 集合

1. 多用于**数据个数不能确定**，且需要进行**增删**元素。
2. 集合只能存储引用类型数据
3. 体系结构：

![Untitled](https://files.catbox.moe/qbniy2.png)

List系列集合：添加的元素是有序，可重复，有索引

Set系列集合：无序，不重复，无索引

1. 集合支持**泛型，用于约束集合所存储的数据类型**

```java
public class CollectionTest {
    public static void main(String[] args) {
        Collection<String> list = new ArrayList<>();
        list.add("java");
//        list.add(111);
        list.add("java");
//        list.add(true);
        System.out.println(list);

        Collection list1 = new HashSet();
        list1.add("java");
        list1.add(111);
        list1.add("java");
        list1.add(true);
        System.out.println(list1);
				// "java"被去重复了
    }
}
```

![Untitled](https://files.catbox.moe/395la7.png)

**c.addall(c1)**可将c1中所有元素导入c中。

迭代器遍历集合元素：

```java
public class CollectionTest {
    public static void main(String[] args) {
        Collection<String> list = new ArrayList<>();
        list.add("java");
        list.add("MYsql");
        list.add("python");
        list.add("C++");
        System.out.println(list);

        **Iterator<String> it = list.iterator();**
//        String ele = it.next();
//        System.out.println(ele);
//        System.out.println(it.next());
        while (it.hasNext()){
            String ele = it.next();
            System.out.println(ele);
        }
```

### 可用增强for简化迭代器：

```java
for (String s : list) {
            System.out.println(s);
}
```

### Lambda表达式

```java
list.forEach(new Consumer<String>() {
            @Override
            public void accept(String s) {
                System.out.println(s);
            }
        });
// =>
list.forEach(s -> System.out.println(s));
// =>
list.forEach(System.out::println);
```

案例：

```java
public class Main2 {
    public static void main(String[] args) {
        Collection<Movie> movies = new ArrayList<>();
        movies.add(new Movie("111",9.5,"ddd3423"));
        movies.add(new Movie("111w322",8.5,"ddd324324"));
        movies.add(new Movie("111324324",1.5,"dd324342d"));

        for (Movie movie : movies) {
            System.out.println(movie.getActor());
            System.out.println(movie.getName());
            System.out.println(movie.getScore());
        }
    }
}

```

![Untitled](https://files.catbox.moe/osvr58.png)

## List系列集合

![Untitled](https://files.catbox.moe/b45zg9.png)

```java
package com;

import java.util.ArrayList;
import java.util.List;

public class ListTest {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>();
        list.add("Java");
        list.add("java");
        list.add("Java");

        list.add(2,"HTML");
        // 添加
        System.out.println(list);
        System.out.println(list.remove(2));
        System.out.println(list);

        list.set(2,"c++");
        // 覆盖
        System.out.println(list);
        System.out.println(list.get(2));
    }
}
```

**ArrayList**底层基于数组，增删较慢，索引定位较快。

**LinkedList底层基于双链表，首尾操作较快，查询较慢**

LinkedList实现栈和对列：

```java
public class LinkListTest {
    public static void main(String[] args) {
        LinkedList<String> stack = new LinkedList<>();
        //压栈
        stack.push("111");
        stack.addFirst("2222");
        stack.addFirst("33333333");
        stack.addFirst("444444444");
        //出栈
        System.out.println(stack.pop());
        System.out.println(stack.removeFirst());
        System.out.println(stack.removeFirst());
        System.out.println(stack.removeFirst());
        System.out.println(stack);
        //队列
        LinkedList<String> queue = new LinkedList<>();
				//入队
        queue.addLast("1");
        queue.addLast("22");
        queue.addLast("33");
        queue.addLast("444");

        System.out.println(queue);
				//出队
        queue.removeLast();
        queue.removeLast();
        queue.removeLast();
        System.out.println(queue);
    }
}
```

边遍历边删除问题：

```java
package com;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class ListTest {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>();
        list.add("Java");
        list.add("java");
        list.add("Java");

        list.add(2,"HTML");
        // 添加
        System.out.println(list);

        Iterator<String> it = list.listIterator();
        while (it.hasNext()){
            String ele = it.next();
            if("Java".equals(ele)){
                **it.remove();//会在删除当前位置后不后移，不会漏删
                //list.remove();
                //不能用list，会在漏删出现bug**
            }
        }

    }
```

用**集合**删除元素后i++导致跳过一个元素，应用**迭代器**删除元素。

### 自定义泛型类

![Untitled](https://files.catbox.moe/qg28oz.png)

```java
package com.ListTest1;

import java.util.ArrayList;

public class MyArrayList<E> {
    ArrayList<String> list = new ArrayList<>();
    public void add(E s){
        list.add(s);
    }
    public void remove(E s){
        list.remove(s);
    }
}
```

### 泛型方法

定义方法的同时定义了泛型的方法，就是泛型方法。

```java
public <T> void show(T t){}
```

可接受数据类型更灵活。

```java
public class Test {
    public static void main(String[] args) {
        
        String[] names = {"hhh", "duwagwd", "dwidwadwa"};
        Integer[] ages = {121,324,2434,455};
        printArray(ages);
				printArray(names);

    }

    **public static <T> void printArray(T[] t){
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < t.length; i++) {
            sb.append(t[i]).append(i != t.length - 1 ? ",": "");
        }
        sb.append("]"); 
        System.out.println(sb);
    }**
}
```

<T>对于String和Integer均可接受，但注意只能为引用类型。

### 泛型接口

![Untitled](https://files.catbox.moe/27vwj3.png)

### 通配符

用于使用泛型时：

```java
public static void go(ArrayList<?> cars){
}
```

## Set系列集合

特定：无序，不重复，无索引

### HashSet

底层基于哈希表和红黑树。

![Untitled](https://files.catbox.moe/n8yxom.png)

Collection集合**总结：**

![Untitled](https://files.catbox.moe/f4teuz.png)

## 可变参数

接受数据非常灵活，收参数可以为不确定个数。

```java

package com.D1;

import java.lang.reflect.Array;
import java.util.Arrays;

public class MethodDemo {
    public static void main(String[] args) {
        sum();
        sum(1000);
        sum(10,25,59,19,19);
        sum(new int[]{15,59,9,29,19,9});
    }

    public static void sum(int...nums){
        System.out.println(Arrays.toString(nums));
    }
}
```

注：可变参数只能放在形参列表的**最后.**

## Collection工具类

```java
public class CollectionsDemo {
    public static void main(String[] args) {
        List<String> list = new ArrayList<>();
        Collections.addAll(list,"wdaihidowa","fuyghj","fuygihjlk");
	      Collections.shuffle(list);
				//打乱排序
				// reSort the list elements
	        System.out.println(list);
    }
}
```

sort() method:

```java
ArrayList<Integer> lists = new ArrayList<>();
Collections.addAll(lists,116,94,4,94,94,94,94,4,9,151,51,51);
Collections.sort(lists);
System.out.println(lists);

//[4, 4, 9, 51, 51, 94, 94, 94, 94, 94, 116, 151]
```

**比较器**

![Untitled](https://files.catbox.moe/yvl7wh.png)

## Map集合（键值对集合）

键：**有序 不重复 无索引**

![Untitled](https://files.catbox.moe/pyfkgz.png)

### Maps遍历

1. 获取所有键的集合：Set<K> keySet()

```java
Maps<String, Integer> maps = new HashMap<>();
Set<String> set = maps.keySet();
// 先取所有键
for (String key : set) {
    int value = maps.get(key);
    System.out.println(key + "=>" + value);
}
```

1. 先把Maps集合转为Set集合

```java
Set<Map.Entry<String, Integer>> entries = maps.entrySet();
// 转成Set键值对对象
for (Map.Entry<String, Integer> entry : entries) {
    String key = entry.getKey();
    int value = entry.getValue();
    System.out.println(key + "=>" + value);
}
```

1. Lambda表达式

```java
maps.forEach(new BiConsumer<String, Integer>() {
    @Override
    public void accept(String s, Integer integer) {
        System.out.println(s + "=>" + integer);
    }
});

// 简化
**maps.forEach((s, integer) -> System.out.println(s + "=>" + integer));**
```

## 其他实现类

LinkedHashMap：有序，无索引，不重复

TreeMap：键可排序，无索引，无重复
