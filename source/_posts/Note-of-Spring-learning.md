---
title:
  Spring学习笔记
date:
  2023-02-12 19:00:45
tags:
  java
---

## Spring核心概念

解决的问题核心：耦合度高。

1. 业务层需要调用DAO层的方法，就需要在业务层newDAO层的对象
2. 如果DAO层的实现类发生变化，业务层的代码也需要改变，更需要编译和打包部署。

Spring的解决：使用对象时，在程序中不要主动使用new产生对象，转换为由外部提供对象，即**控制反转**。

### IOC -- 控制反转

- 使用对象时，由主动new产生对象转换为由**外部**提供对象，此过程中对象创建控制权由程序转移到外部，此思想称为控制反转。
  - 业务层要用数据层的类对象，以前是自己`new`的
  - 现在自己不new了，交给`别人[外部]`来创建对象
  - `别人[外部]`就反转控制了数据层对象的创建权
  - 这种思想就是控制反转
- Spring和IOC之间的关系是什么呢?
  - Spring技术对IOC思想进行了实现
  - Spring提供了一个容器，称为`IOC容器`，用来充当IOC思想中的”外部”
  - IOC思想中的`别人[外部]`指的就是Spring的IOC容器
- IOC容器的作用以及内部存放的是什么?
  - IOC容器负责对象的创建、初始化等一系列工作，其中包含了数据层和业务层的类对象
  - 被创建或被管理的对象在IOC容器中统称为Bean
  - IOC容器中放的就是一个个的Bean对象
- 当IOC容器中创建好service和dao对象后，程序能正确执行么?
  - 不行，因为service运行需要依赖dao对象
  - IOC容器中虽然有service和dao对象
  - 但是service对象和dao对象没有任何关系
  - 需要把dao对象交给service,也就是说要绑定service和dao对象之间的关系
  - 像这种在容器中建立对象与对象之间的绑定关系就要用到DI(Dependency Injection)依赖注入.

### DI -- 依赖注入

在容器中建立bean与bean之间的依赖关系的整个过程，称为依赖注入。

- - - 业务层要用数据层的类对象，以前是自己`new`的
    - 现在自己不new了，靠`别人[外部其实指的就是IOC容器]`来给注入进来
    - 这种思想就是依赖注入
- IOC容器中哪些bean之间要建立依赖关系呢?
  - 这个需要程序员根据业务需求提前建立好关系，如业务层需要依赖数据层，service就要和dao建立依赖关系
- 介绍完Spring的IOC和DI的概念后，我们会发现这两个概念的最终目标就是:充分解耦，具体实现靠:
  - 使用IOC容器管理bean（IOC)
  - 在IOC容器内将有依赖关系的bean进行关系绑定（DI）
  - 最终结果为:使用对象时不仅可以直接从IOC容器中获取，并且获取到的bean已经绑定了所有的依赖关系.

这种有意思的思想解释可以参见[浅谈控制反转与依赖注入](https://zhuanlan.zhihu.com/p/33492169).

## 控制反转(IOC)

### Bean基础配置

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="bookDao" name="dao" class="com.hit.dao.impl.BookDaoImpl" scope="prototype"/>
<!--    scope可控制bean是否是单例的-->

    <bean id="bookService" name="bookService2" class="com.hit.service.BookServiceImpl">
    <!--        依赖注入-->
        <property name="bookDao" ref="bookDao"/>
        <!--    注意:配置中的两个bookDao的含义是不一样的-->
        <!--    name=”bookDao”中bookDao的作用是让Spring的IOC容器在获取到名称后，将首字母大写，前面加set找对应的setBookDao()方法进行对象注入-->
        <!--    ref=”bookDao”中bookDao的作用是让Spring能在IOC容器中找到id为bookDao的Bean对象给bookService进行注入-->
    </bean>
</beans>
```

![img](https://i.328888.xyz/2023/03/08/SjSXc.png)

name是bean的别名，作用与id相同。

```java
BookService bookService = (BookService) context.getBean("bookService2");
```

bean默认单例，可在标签内用Scope属性更改。

### Bean实例化

Bean本质上是对象，需要实例化。

1. **无参构造器实例化**

   [![SjoKA.png](https://i.328888.xyz/2023/03/08/SjoKA.png)](https://imgloc.com/i/SjoKA)

​		spring实例化实际上是基于**反射**，私有构造器也可以实例化（但只能用无参构造器）。

2. **静态工厂实例化**

   ```java
   public class App {
       public static void main(String[] args) {
           BookDao bookDao = BookDaoFactory.getBookDao();
           bookDao.save();
       }
   }
   ```

   ```java
   package com.hit.factory;
   
   import com.hit.dao.BookDao;
   import com.hit.dao.impl.BookDaoImpl;
   
   public class BookDaoFactory {
       public static BookDao getBookDao(){
           return new BookDaoImpl();
       }
   }
   ```

   bean中的配置

   ```xml
   <bean id="bookDaoFactory" class="com.hit.factory.BookDaoFactory" factory-method="getBookDao"/>
   ```

   factory-method为关键，否则会构造出工厂对象。

3. **实例工厂与FactoryBean**

   先将工厂实例化，再用工厂对象构造类：
   ```xml
   <bean id="userFactory" class="com.hit.factory.UserFactory"/>
   <bean id="userDao" factory-method="getUserDao" factory-bean="userFactory"/>
   ```

   [![SjvDo.png](https://i.328888.xyz/2023/03/08/SjvDo.png)](https://imgloc.com/i/SjvDo)

   上述比较麻烦，可进行如下改良：

   对工厂类做实现接口：

   ```java
   package com.hit.factory;
   
   import com.hit.dao.BookDao;
   import com.hit.dao.impl.BookDaoImpl;
   import org.springframework.beans.factory.FactoryBean;
   
   public class UserDaoFactoryBean implements FactoryBean<BookDao>{
       @Override
       public BookDao getObject() throws Exception {
           return new BookDaoImpl();
       }
   
       @Override
       public Class<?> getObjectType() {
           return BookDao.class;
       }
   }
   
   ```

   Bean配置：

   ```xml
   <bean id="BookDaoFactroy" class="com.hit.factory.UserDaoFactoryBean"/>
   ```

   大部分框架中使用此种方法实例化Bean。

### Bean的生命周期

```java
public class BookServiceImpl implements BookService {
    private BookDao bookDao;

    public void setBookDao(BookDao bookDao){
        this.bookDao = bookDao;
        //System.out.println("Set方法被调用了！");
    }
    @Override
    public void save() {
        System.out.println("book srevice save.....");
        bookDao.save();//判断是否成功完成依赖注入
    }
    public void init() {
        System.out.println("init...");
    }
    public void destory(){
        System.out.println("Destroy....");
    }
}

```

Bean配置：

```xml
<bean id="bookService" name="bookService2" class="com.hit.service.BookServiceImpl" init-method="init" destroy-method="destory">
```

但上述配置下无法看待Destroy方法执行，因为在结束时jvm会直接退出，不会将bean销毁。

因此需要**在虚拟机退出前将容器关闭**。

1. context.close()

```java
public class App {
    public static void main(String[] args) {
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");

        BookService bookService = (BookService) context.getBean("bookService");
        bookService.save();
        context.close();
    }
}
```

另外需要修改context为其子类。

2. 设置关闭钩子，关闭容器更为温和。

   ```
   context.registerShutdownHook();
   ```

另外，也可用实现接口的方式控制生命周期：

```java
public class BookServiceImpl implements BookService,InitializingBean,DisposableBean {
    @Override
    public void destroy() throws Exception {
        System.out.println("service init");
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("service destroy!");
    }
}
```
## 依赖注入(DI)

### setter注入

主要分为**引用类型注入**和**简单类型注入**。

引用类型注入：

- 在bean中定义引用类型属性，并提供可访问的**set方法**

  ```java
  public class BookServiceImpl implements BookService {
      private BookDao bookDao;
      public void setBookDao(BookDao bookDao) {
          this.bookDao = bookDao;
      }
  }
  ```

- 配置中使用property标签ref属性注入引用类型对象

  ```xml
  <bean id="bookService" class="com.blog.service.impl.BookServiceImpl">
      <property name="bookDao" ref="bookDao"></property>
  </bean>
  ```

简单类型注入：

**在bean中定义类型属性并提供可访问的set方法。**

再在property用value写参数：

```xml
<bean id="userDao" class="com.hit.dao.impl.UserDaoImpl">
        <property name="database" value="mysql"/>
        <property name="connectNum" value="100"/>
    </bean>
```

```java
package com.hit.dao.impl;
import com.hit.dao.UserDao;

public class UserDaoImpl implements UserDao {
    private int connectNum;
    private String database;
    public UserDaoImpl(){
    }
    @Override
    public void save() {
        System.out.println("UserDao is save!" + connectNum + " " + database);
    }

    public void setDatabase(String database) {
        this.database = database;
    }
    public void setConnectNum(int connectNum){
        this.connectNum = connectNum;
    }
}
```

### 构造器注入

将需要依赖的类中的setter方法改为有参构造器，即可用构造器注入：

```java
public BookServiceImpl(BookDao bookDao, UserDao userDao) {
        this.bookDao = bookDao;
        this.userDao = userDao;
    }
```

bean配置：

```xml
<bean id="bookService" class="com.hit.service.BookServiceImpl">
        <constructor-arg name="bookDao" ref="bookDao"/>
        <constructor-arg name="userDao" ref="userDao"/>
```

简单类型完全类似。

但name必须与bean中属性名一致，存在紧耦合，可用type或参数位置解决。

### 依赖注入选择——自己写多用setter注入

1. 强制依赖使用构造器进行，使用setter注入有概率不进行注入导致null对象出现
   - 强制依赖指对象在创建的过程中必须要注入指定的参数
2. 可选依赖使用setter注入进行，灵活性强
   - 可选依赖指对象在创建过程中注入的参数可有可无
3. Spring框架倡导使用构造器，第三方框架内部大多数采用构造器注入的形式进行数据初始化，相对严谨
4. 如果有必要可以两者同时使用，使用构造器注入完成强制依赖的注入，使用setter注入完成可选依赖的注入
5. 实际开发过程中还要根据实际情况分析，如果受控对象没有提供setter方法就必须使用构造器注入
6. 自己开发的模块推荐使用setter注入

### 自动装配

IOC容器根据bean所依赖的资源在容器中`自动查找并注入`到bean中的过程称为自动装配

手写依赖注入比较麻烦，自动装配效率更高。

主要有三种方式：

- 按类型（常用）
- 按名称
- 按构造方法

#### 按类型

```xml
 <bean class="com.hit.dao.impl.BookDaoImpl"/>
 <!-- 按类型注入可省去id-->
 <bean id="bookService" name="bookService2" class="com.hit.service.BookServiceImpl" autowire="byType">
```

#### 按名称

即需要注入的bean的id为注入类内setter方法的后半部分。

若将id改为bookDao2则不能注入，需要修改对应的方法名。

```xml
<bean id="bookDao2" name="dao" class="com.hit.dao.impl.BookDaoImpl" scope="prototype"/>
 <bean id="bookService" name="bookService2" class="com.hit.service.BookServiceImpl" autowire="byName">
```

同时修改BookServiceImpl类汇总的`setBookDao`方法，将其重命名为`setBookDao2`.

```java
public class BookServiceImpl implements BookService{
    private BookDao bookDao;

    public void setBookDao2(BookDao bookDao) {
        this.bookDao = bookDao;
    }

    public void save() {
        System.out.println("book service save ...");
        bookDao.save();
    }
}
```

对于依赖注入，需要注意一些其他的配置特征:

1. 自动装配用于引用类型依赖注入，不能对简单类型进行操作
2. 使用按类型装配时（byType）必须保障容器中相同类型的bean唯一，推荐使用
3. 使用按名称装配时（byName）必须保障容器中具有指定名称的bean，因变量名与配置耦合，不推荐使用
4. 自动装配优先级低于setter注入与构造器注入，同时出现时自动装配配置失效

### 集合注入

与之前的引用类型，基本类型没多少区别。

```xml
<property name="array">
    <array>
        <value>100</value>
        <value>200</value>
        <value>300</value>
    </array>
</property>
<property name="array">
    <array>
        <value>100</value>
        <value>200</value>
        <value>300</value>
    </array>
</property>
<property name="set">
    <set>
        <value>100</value>
        <value>200</value>
        <value>ABC</value>
        <value>ABC</value>
    </set>
</property>
<property name="map">
    <map>
        <entry key="探路者" value="马文"/>
        <entry key="次元游记兵" value="恶灵"/>
        <entry key="易位窃贼" value="罗芭"/>
    </map>
</property>
<property name="properties">
    <props>
        <prop key="暴雷">沃尔特·菲茨罗伊</prop>
        <prop key="寻血猎犬">布洛特·亨德尔</prop>
        <prop key="命脉">阿杰·切</prop>
    </props>
</property>
```

### Spring管理第三方数据源

```xml
<bean id="dataSource" class="com.alibaba.druid.pool.DruidDataSource">
        <property name="driverClassName" value="com.msql"/>
        <property name="url" value="jdbc:mysql://localhost:3306"/>
        <property name="username" value="root"/>
        <property name="password" value="root"/>
    </bean>
```

注意：Spring的xml配置文件applicationContext.xml需要先配置上下文，即需要再idea的项目结构中添加spring控件，否则会报错无法找到xml文件．

### 核心容器

上面bean容器都是用xml配置文件创建的, 其实也可以用绝对路径创建．

```java
ApplicationContext ctx = new FileSystemXmlApplicationContext("D:\xxx/xxx\applicationContext.xml");
```

但看起来就很蠢，其实完全没人用吧．

#### 获取bean的三种方式

- 方式一，就是我们之前用的方式

- 这种方式存在的问题是每次获取的时候都需要进行**类型转换**，有没有更简单的方式呢?

  ```java
  BookDao bookDao = (BookDao) ctx.getBean("bookDao");
  ```

- 方式二
  这种方式可以解决类型强转问题，但是参数又多加了一个，相对来说没有简化多少。

  ```java
  BookDao bookDao = ctx.getBean("bookDao"，BookDao.class);
  ```

- 方式三

- 这种方式就类似我们之前所学习**依赖注入中的按类型注入**。必须要确保IOC容器中该类型对应的bean对象只能有一个。

  ```java
  BookDao bookDao = ctx.getBean(BookDao.class);
  ```

#### BeanFactory

容器的最上级的父接口为`BeanFactory`.
使用`BeanFactory`也可以创建IOC容器

```java
public class AppForBeanFactory {
    public static void main(String[] args) {
        Resource resources = new ClassPathResource("applicationContext.xml");
        BeanFactory bf = new XmlBeanFactory(resources);
        BookDao bookDao = bf.getBean(BookDao.class);
        bookDao.save();
    }
}
```


为了更好的看出`BeanFactory`和`ApplicationContext`之间的区别，在BookDaoImpl添加如下构造函数

```java
public class BookDaoImpl implements BookDao {
    public BookDaoImpl() {
        System.out.println("constructor");
    }
    public void save() {
        System.out.println("book dao save ..." );
    }
}
```


如果不去获取bean对象，打印会发现：

- BeanFactory是延迟加载，只有在获取bean对象的时候才会去创建

- ApplicationContext是立即加载，容器加载的时候就会创建bean对象

- ApplicationContext要想成为延迟加载，只需要将lazy-init设为true

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <beans xmlns="http://www.springframework.org/schema/beans"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="
              http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
      <bean id="bookDao" class="com.blog.dao.impl.BookDaoImpl"  lazy-init="true"/>
  </beans>
  ```

#### 总结

容器相关

- BeanFactory是IoC容器的顶层接口，初始化BeanFactory对象时，加载的bean延迟加载
- ApplicationContext接口是Spring容器的核心接口，初始化时bean立即加载
- ApplicationContext接口提供基础的bean操作相关方法，通过其他接口扩展其功能
- ApplicationContext接口常用初始化类
  - ClassPathXmlApplicationContext(常用)
  - FileSystemXmlApplicationContext

Bean相关

![img](https://pic.imgdb.cn/item/631070e616f2c2beb1536517.jpg)

依赖注入

![img](https://pic.imgdb.cn/item/631070f716f2c2beb1536fa3.jpg)

## 注解开发

### 注解开发定义Bean

注解开发是spring的核心, 极大简化了bean的创建和管理.

此时无需直接在xml配置中手动添加bean, 而是只需要在实现接口的类中加上component注解:

```java
@Component("bookDao")
public class BookDaoImpl implements BookDao {
    @Override
    public void save() {
        System.out.println("BookDao is running!");
    }
}
```

```java
ApplicationContext ctx = new ClassPathXmlApplicationContext("applicationContext.xml");
BookDao bookDao = (BookDao) ctx.getBean("bookDao");
bookDao.save();
```

上面的写法是**按名称**创建bean, 因此注解中还有参数, 当然也可用**按类型**创建bean:

```java
@Component("bookDao")
public class BookDaoImpl implements BookDao {
    @Override
    public void save() {
        System.out.println("BookDao is running!");
    }
}
```

```java
ApplicationContext ctx = new ClassPathXmlApplicationContext("applicationContext.xml");
BookService bean = ctx.getBean(BookService.class);
bean.save();
```

注意：@Component注解不可以添加在接口上，因为接口是*无法创建对象*的。

然后在xml配置中写好包扫描即可:

```xml
 <context:component-scan base-package="com.hit"/>
```

- 说明：component-scan
  - component:组件,Spring将管理的bean视作自己的一个组件
  - scan:扫描
    base-package指定Spring框架扫描的包路径，它会扫描指定包及其子包中的所有类上的注解。
  - 包路径越多`如:com.hit.dao.impl`，扫描的范围越小速度越快
  - 包路径越少`如:com.hit`,扫描的范围越大速度越慢
  - 一般扫描到项目的组织名称即Maven的groupId下`如:com.hit`即可。

### 关于Component注解

@Component注解如果不起名称，会有一个默认值就是当前类名首字母小写，所以也可以按照名称获取，如

```java
BookService bookService = (BookService) context.getBean("bookServiceImpl");
```

此外, 对于@Component注解，还衍生出了其他三个注解`@Controller`、`@Service`、`@Repository`

通过查看源码会发现：这三个注解和@Component注解的作用是一样的，为什么要衍生出这三个呢?

这是方便我们后期在编写类的时候能很好的区分出这个类是属于`表现层`、`业务层`还是`数据层`的类。

### 纯注解开发

上面已经可以使用注解来配置bean,但是依然有用到配置文件，在配置文件中对包进行了扫描，Spring在3.0版

经支持纯注解开发，使用Java类替代配置文件，开启了Spring快速开发赛道，那么具体如何实现?

主要思路:**将配置文件applicationContext.xml删掉，用类来替换.**

创建一个配置类:

```java
@Configuration
@ComponentScan("com.hit")
public class SpringConfig {
}
```

此时写法也需要换:

```java
AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(SpringConfig.class);
BookDao bookDao = (BookDao) context.getBean("bookDao");
bookDao.save();
BookService bookService = context.getBean(BookService.class);
bookService.save();
```

这部分要重点掌握的是使用注解完成Spring的bean管理，需要掌握的内容为:

- 记住`@Component`、`@Controller`、`@Service`、`@Repository`这四个注解
- applicationContext.xml中`<context:component-san/>`的作用是指定扫描包路径，注解为`@ComponentScan`
- `@Configuration`标识该类为配置类，使用类替换`applicationContext.xml`文件
- `ClassPathXmlApplicationContext`是加载XML配置文件
- `AnnotationConfigApplicationContext`是加载配置类

### 注解开发Bean生命周期

配置文件中的bean标签中的
`id`对应`@Component("")`，`@Controller("")`，`@Service("")`，`@Repository("")`
`scope`对应`@scope()`
`init-method`对应`@PostConstruct`
`destroy-method`对应`@PreDestroy`

其实与写xml配置没啥区别.

### 注解开发依赖注入

Spring为了使用注解简化开发，并没有提供`构造函数注入`、`setter注入`对应的注解，只提供了自动装配的注解实现。

在需要依赖注入的被注入类中的注入类对象中用注解标记:

```java
@Component
public class BookServiceImpl implements BookService {
    @Autowired
    private BookDao bookDao;
//    public BookServiceImpl(BookDao bookDao){
//        this.bookDao = bookDao;
//    }
    @Override
    public void save() {
        System.out.println("BookService is running!");
        bookDao.save();
    }
}

```

此时无论构造器还是Setter都可以删掉.

- 为什么setter方法可以删除呢?
  - 自动装配基于反射设计创建对象并通过`暴力反射`为私有属性进行设值
  - 普通反射只能获取public修饰的内容
  - 暴力反射除了获取public修饰的内容还可以获取private修改的内容
  - 所以此处无需提供setter方法

**@Autowired**是按照类型注入, 对应BookDao接口如果有多个实现类，比如添加BookDaoImpl2

```java
@Repository
public class BookDaoImpl2 implements BookDao {
    public void save() {
        System.out.println("book dao save ...2");
    }
}
```

此时会报错`NoUniqueBeanDefinitionException`

因此此时需要使用按照名称注入:

```java
@Repository("bookDao")
public class BookDaoImpl implements BookDao {
    public void save() {
        System.out.println("book dao save ..." );
    }
}
@Repository("bookDao2")
public class BookDaoImpl2 implements BookDao {
    public void save() {
        System.out.println("book dao save ...2" );
    }
}
```

- 此时就可以注入成功输出book dao save ...，但是得思考个问题:
- @Autowired是按照**类型**注入的，给BookDao的两个实现起了名称，它还是有两个bean对象，为什么不报错?
- @Autowired默认按照类型自动装配，**如果IOC容器中同类的Bean找到多个，就按照变量名和Bean的名称匹配。**因为变量名叫`bookDao`而容器中也有一个`bookDao`，所以可以成功注入。

因此如果将参数的bookDao改为bookDao1，则无法注入成功，因为BookServiceImpl容器中没有bookDao.

#### 注解实现名称注入

但是当根据类型在容器中找到多个bean,注入参数的属性名又和容器中bean的名称不一致，这个时候该如何解决？

此时需要使用到`@Qualifier`来指定注入哪个名称的bean对象。`@Qualifier`注解后的值就是需要注入的bean的名称。

```java
@Service
public class BookServiceImpl implements BookService {
    @Autowired
    @Qualifier("bookDao1")
    private BookDao bookDao;
    
    public void save() {
        System.out.println("book service save ...");
        bookDao.save();
    }
}
```

注意:@Qualifier不能独立使用，必须和@Autowired一起使用.

#### 简单数据类型注入

与引用型几乎一致，添加变量然后用value注解即可：
```java
@Repository
public class BookDaoImpl implements BookDao {
    @Value("Stephen")
    private String name;
    public void save() {
        System.out.println("book dao save ..." + name);
    }
}
```

#### 注解读取properties文件

在SpringConfig中配置：

```java
@Configuration
@ComponentScan("com.blog")
@PropertySource("jdbc.properties")
public class SpringConfig {
}
```

直接用@Value引用properties文件内容：

```java
@Repository
public class BookDaoImpl implements BookDao {
    @Value("${name}")
    private String name;
    public void save() {
        System.out.println("book dao save ..." + name);
    }
}
```

## IOC/DI注解开发管理第三方bean

### 管理第三方bean

例如阿里巴巴的druid：

在配置类中写对应bean的方法：

```java
@Configuration
public class SpringConfig {
    public DataSource dataSource() {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://localhost:13306/spring_db");
        dataSource.setUsername("root");
        dataSource.setPassword("PASSWORD");
        return dataSource;
    }
}
```

添加Bean注解来**将方法返回值作为Spring管理的bean对象**

```java
@Configuration
public class SpringConfig {
    @Bean
    public DataSource dataSource() {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://localhost:13306/spring_db");
        dataSource.setUsername("root");
        dataSource.setPassword("PASSWORD");
        return dataSource;
    }
}
```

此时即可从IOC容器中获取对象：

```java
public class App {
    public static void main(String[] args) {
        AnnotationConfigApplicationContext ctx = new AnnotationConfigApplicationContext(SpringConfig.class);
        DataSource dataSource = ctx.getBean(DataSource.class);
        System.out.println(dataSource);
    }
}
```

如果有多个第三方包需要被Spring管理，需要用单独的jdbcConfig:

```java
public class JdbcConfig {
    @Bean
    public DataSource dataSource() {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://localhost:13306/spring_db");
        dataSource.setUsername("root");
        dataSource.setPassword("PASSWORD");
        return dataSource;
    }
}
```

然后用SpringConfig引入：

```java
@Configuration
@Import(JdbcConfig.class)
public class SpringConfig {
}
```

### 注解开发实现第三方bean注入

可分为简单数据类型注入和引用类型注入：

#### 简单数据类型注入

在jdbcConfig中提供需要注入的简单数据类型的属性：

````java
public class JdbcConfig {

    private String driver;
    private String url;
    private String username;
    private String password;

    @Bean
    public DataSource dataSource() {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setDriverClassName(driver);
        dataSource.setUrl(url);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        return dataSource;
    }
}
````

使用Value注解实现数据注入：

```java
public class JdbcConfig {
    @Value("com.mysql.jdbc.Driver")
    private String driver;
    @Value("jdbc:mysql://localhost:13306/spring_db")
    private String url;
    @Value("root")
    private String username;
    @Value("PASSWORD")
    private String password;

    @Bean
    public DataSource dataSource() {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setDriverClassName(driver);
        dataSource.setUrl(url);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        return dataSource;
    }
}
```

也可读取配置文件中的数据：

```java
@PropertySource("jdbc.properties")
public class JdbcConfig {
    @Value("${jdbc.driver}")
    private String driver;
    @Value("${jdbc.url}")
    private String url;
    @Value("${jdbc.username}")
    private String username;
    @Value("${jdbc.password}")
    private String password;

    @Bean
    public DataSource dataSource() {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setDriverClassName(driver);
        dataSource.setUrl(url);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        return dataSource;
    }
}
```

#### 引用数据类型注入

在SpringConfg中配置注入类的扫描：

```java
@Configuration
@ComponentScan("com.dao")
@Import(JdbcConfig.class)
public class SpringConfig {
}
```

在JdbcConfig类的方法上添加参数:

```java
@Bean
public DataSource dataSource(BookDao bookDao) {
    bookDao.save();
    DruidDataSource dataSource = new DruidDataSource();
    dataSource.setDriverClassName(driver);
    dataSource.setUrl(url);
    dataSource.setUsername(username);
    dataSource.setPassword(password);
    return dataSource;
}
```

引用类型注入只需要为bean定义方法设置形参即可，容器会`根据类型`自动装配对象。

#### 注解开发总结

![img](https://pic.imgdb.cn/item/6311791f16f2c2beb1cd19b1.jpg)

## Spring整合

### 整合Mybatis

Mybatis程序核心对象分析
从图中可以获取到，真正需要交给Spring管理的是SqlSessionFactory：

![img](https://pic.imgdb.cn/item/6313ff4416f2c2beb1bf13f0.jpg)

整合Mybatis，就是将Mybatis用到的内容交给Spring管理，分析下配置文件

![img](https://pic.imgdb.cn/item/6313ff5116f2c2beb1bf1ee5.jpg)

说明:

- 第一部分读取外部properties配置文件，Spring有提供具体的解决方案`@PropertySource`,需要交给Spring
- 第二部分起别名包扫描，为SqlSessionFactory服务的，需要交给Spring
- 第三部分主要用于做连接池，Spring之前我们已经整合了Druid连接池，这块也需要交给Spring
- 前面三部分一起都是为了创建SqlSession对象用的，那么用Spring管理SqlSession对象吗?回忆下SqlSession是由SqlSessionFactory创建出来的，所以只需要将SqlSessionFactory交给Spring管理即可。
- 第四部分是Mapper接口和映射文件[如果使用注解就没有该映射文件]，这个是在获取到SqlSession以后执行具体操作的时候用，所以它和SqlSessionFactory创建的时机都不在同一个时间，可能需要单独管理。

#### 具体整合步骤

1. Spring要管理MyBatis中的SqlSessionFactory

2. Spring要管理Mapper接口的扫描

其实在SpringBoot中也会有整合。

### Spring整合Junit

- `步骤一：`引入依赖

  ```xml
  <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.12</version>
      <scope>test</scope>
  </dependency>
  
  <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-test</artifactId>
      <version>5.2.10.RELEASE</version>
  </dependency>
  ```

- `步骤二：`编写测试类

  ```java
  //设置类运行器
  @RunWith(SpringJUnit4ClassRunner.class)
  //设置Spring环境对应的配置类
  @ContextConfiguration(classes = {SpringConfig.class})//加载配置类
  public class AccountServiceTest {
      //支持自动装配注入bean
      @Autowired
      private AccountService accountService;
  
      @Test
      public void test(){
          Account account = accountService.findById(1);
          System.out.println(account);
      }
  
      @Test
      public void selectAll(){
          List<Account> accounts = accountService.findAll();
          System.out.println(accounts);
      }
  }
  ```

**注意:**

- 单元测试，如果测试的是注解配置类，则使用`@ContextConfiguration(classes = 配置类.class)`
- 单元测试，如果测试的是配置文件，则使用`@ContextConfiguration(locations={配置文件名,...})`
- Junit运行后是基于Spring环境运行的，所以Spring提供了一个专用的类运行器，这个务必要设置，这个类运行器就在Spring的测试专用包中提供的，导入的坐标就是这个东西`SpringJUnit4ClassRunner`
- 上面两个配置都是固定格式，当需要测试哪个bean时，使用自动装配加载对应的对象，下面的工作就和以前做Junit单元测试完全一样了

## 面向切面编程(AOP)

核心概念：**不改原有代码的前提下对其进行增强**。

例如下面这段：

```java
@Repository
public class BookDaoImpl implements BookDao {
    public void save() {
        //记录程序当前执行执行（开始时间）
        Long startTime = System.currentTimeMillis();
        //业务执行万次
        for (int i = 0;i<10000;i++) {
            System.out.println("book dao save ...");
        }
        //记录程序当前执行时间（结束时间）
        Long endTime = System.currentTimeMillis();
        //计算时间差
        Long totalTime = endTime-startTime;
        //输出信息
        System.out.println("执行万次消耗时间：" + totalTime + "ms");
    }
    public void update(){
        System.out.println("book dao update ...");
    }
    public void delete(){
        System.out.println("book dao delete ...");
    }
    public void select(){
        System.out.println("book dao select ...");
    }
}
```

当在App类中从容器中获取bookDao对象后，分别执行其`save`,`delete`,`update`和`select`方法后会有不同的打印结果，这是怎么回事呢？

其实就是用了Spring的AOP:

![img](https://pic.imgdb.cn/item/63155fb516f2c2beb109d12c.jpg)

1. 前面一直在强调，Spring的AOP是对一个类的方法在不进行任何修改的前提下实现增强。对于上面的案例中BookServiceImpl中有`save`,`update`,`delete`和`select`方法,这些方法我们给起了一个名字叫`连接点`
2. 在BookServiceImpl的四个方法中，`update`和`delete`只有打印没有计算万次执行消耗时间，但是在运行的时候已经有该功能，那也就是说`update`和`delete`方法都已经被增强，所以对于需要增强的方法我们给起了一个名字叫`切入点`
3. 执行BookServiceImpl的update和delete方法的时候都被添加了一个计算万次执行消耗时间的功能，将这个功能抽取到一个方法中，换句话说就是存放共性功能的方法，我们给起了个名字叫`通知`
4. 通知是要增强的内容，会有多个，切入点是需要被增强的方法，也会有多个，那哪个切入点需要添加哪个通知，就需要提前将它们之间的关系描述清楚，那么对于通知和切入点之间的关系描述，我们给起了个名字叫`切面`
5. 通知是一个方法，方法不能独立存在需要被写在一个类中，这个类我们也给起了个名字叫`通知类`

至此AOP中的核心概念就已经介绍完了，总结下:

- 连接点(JoinPoint)：程序执行过程中的任意位置，粒度为执行方法、抛出异常、设置变量等
  - 在SpringAOP中，理解为方法的执行
- 切入点(Pointcut):匹配连接点的式子
  - 在SpringAOP中，一个切入点可以描述一个具体方法，也可也匹配多个方法
    - 一个具体的方法:如com.blog.dao包下的BookDao接口中的无形参无返回值的save方法
    - 匹配多个方法:所有的save方法/所有的get开头的方法/所有以Dao结尾的接口中的任意方法/所有带有一个参数的方法
  - 连接点范围要比切入点范围大，是切入点的方法也一定是连接点，但是是连接点的方法就不一定要被增强，所以可能不是切入点。
- 通知(Advice):在切入点处执行的操作，也就是共性功能
  - 在SpringAOP中，功能最终以方法的形式呈现
- 通知类：定义通知的类
- 切面(Aspect):描述通知与切入点的对应关系。

### AOP实例

添加pom：

```xml
<dependency>
    <groupId>org.aspectj</groupId>
    <artifactId>aspectjweaver</artifactId>
    <version>1.9.4</version>
</dependency>
```

创建环境：

```java
@Repository("bookDao1")
public class BookDaoImpl implements BookDao {
    @Override
    public void save() {
        System.out.println(System.currentTimeMillis());
        System.out.println("BookDao is running!");
    }

    @Override
    public void update() {
        System.out.println("book dao update!");
    }
}
```

需求：利用AOP将update方法扩展，不仅打印一句话还要打印当前时间。

新建通知类，名称无约束，但需要在SpringConfig规定的Component的包扫描路径下：

```java
@Component
@Aspect
public class MyAdvice {
    @Pointcut("execution(void com.hit.dao.BookDaoImpl.update())")
    private void pt() {
    }

    @Before("pt()")
    public void method() {
        System.out.println(System.currentTimeMillis());
    }
}
```

@Aspect说明这是一个切面的通知类。

@Pointcut指定需要增强的切入点，参数为方法名

@Before说明在切面执行前执行，method为增强的具体方法内容。

最后在SpringConfig规定AOP：

```java
@Configuration
@ComponentScan("com")
@EnableAspectJAutoProxy
public class SpringConfig {
}
```

### AOP工作流程

由于AOP是基于Spring容器管理的bean做的增强，所以整个工作过程需要**从Spring加载bean**说起

- 流程一：

  Spring容器启动

  - 容器启动就需要去加载bean,哪些类需要被加载呢?
  - 需要被增强的类，如:BookServiceImpl
  - 通知类，如:MyAdvice
  - 注意此时bean对象还没有创建成功

- 流程二：

  读取所有切面配置中的切入点

  ```java
  @Component
  @Aspect
  public class MyAdvice {
      @Pointcut("execution(void com.hit.dao.impl.BookDaoImpl.update())")
      private void ptx() {
      }
  
      @Pointcut("execution(void com.hit.dao.impl.BookDaoImpl.update())")
      private void pt() {
      }
  
  
      @Before("pt()")
      public void method() {
          System.out.println(System.currentTimeMillis());
      }
  }
  ```

  上面这个例子中有两个切入点的配置，但是第一个`ptx()`并没有被使用，所以**不会被读取**。

- 流程三：初始化bean，判定bean对应的类中的方法是否匹配到任意切入点

  - 注意第一步在容器启动的时候，bean对象还没有被创建成功。
  - 要被实例化bean对象的类中的方法和切入点进行匹配

[![img](https://pic.imgdb.cn/item/6315bf8416f2c2beb16ede79.jpg)](https://pic.imgdb.cn/item/6315bf8416f2c2beb16ede79.jpg)

- 匹配失败，创建原始对象，如`UserDao`
  - 匹配失败说明不需要增强，直接调用原始对象的方法即可。
- 匹配成功，创建原始对象（`目标对象`）的`代理`对象，如:`BookDao`
  - 匹配成功说明需要对其进行增强
  - 对哪个类做增强，这个类对应的对象就叫做目标对象
  - 因为要对目标对象进行功能增强，而采用的技术是动态代理，所以会为其创建一个代理对象
  - 最终运行的是代理对象的方法，在该方法中会对原始方法进行功能增强
- 流程四：获取bean执行方法
  - 获取的bean是原始对象时，调用方法并执行，完成操作
  - 获取的bean是代理对象时，根据代理对象的运行模式运行原始方法与增强的内容，完成操作

**那么如何验证容器中是否为代理对象呢？**

- 如果目标对象中的方法`会被增强`，那么容器中将存入的是目标对象的`代理对象`
- 如果目标对象中的方法`不被增强`，那么容器中将存入的是目标`对象本身`

- `步骤一：`修改App运行类，获取类的类型并输出

  ```java
  public class App {
      public static void main(String[] args) {
          AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext(SpringConfig.class);
          BookDao bookDao = context.getBean(BookDao.class);
          System.out.println(bookDao);
          System.out.println(bookDao.getClass());
      }
  }
  ```

- `步骤二：`修改MyAdvice类，改为不增强
  将定义的切入点改为`updatexxx`，而BookDaoImpl类中不存在该方法，所以BookDao中的update方法在执行的时候，就不会被增强
  所以此时容器中的对象应该是目标对象本身。

  ```java
  @Component
  @Aspect
  public class MyAdvice {
      @Pointcut("execution(void com.blog.dao.impl.BookDaoImpl.updatexxx())")
      private void pt() {
      }
  
      @Before("pt()")
      public void method() {
          System.out.println(System.currentTimeMillis());
      }
  }
  ```

- `步骤三：`运行程序
  输出结果如下，确实是目标对象本身，符合我们的预期

  > com.blog.dao.impl.BookDaoImpl@bcec361
  > class com.blog.dao.impl.BookDaoImpl

- `步骤四：`修改MyAdvice类，改为增强
  将定义的切入点改为`update`，那么BookDao中的update方法在执行的时候，就会被增强
  所以容器中的对象应该是目标对象的代理对象

  ```java
  @Component
  @Aspect
  public class MyAdvice {
      @Pointcut("execution(void com.blog.dao.impl.BookDaoImpl.update())")
      private void pt() {
      }
  
      @Before("pt()")
      public void method() {
          System.out.println(System.currentTimeMillis());
      }
  }
  ```

- `步骤五：`运行程序
  结果如下

  > com.blog.dao.impl.BookDaoImpl@3d34d211
  > class com.sun.proxy.$Proxy19

至此对于刚才的结论，我们就得到了验证，这块我们需要注意的是:
不能直接打印对象，从上面两次结果中可以看出，直接打印对象走的是对象的toString方法，不管是不是代理对象，打印的结果都是一样的，原因是内部对toString方法进行了重写。

### AOP核心概念

在上面介绍AOP的工作流程中，我们提到了两个核心概念，分别是:

- 目标对象(Target)：原始功能**去掉共性功能**对应的类产生的对象，这种对象是无法直接完成最终工作的
- 代理(Proxy)：目标对象无法直接完成工作，需要对其进行**功能回填**，通过原始对象的代理对象实现

上面这两个概念比较抽象，简单来说：

目标对象就是要增强的类`如:BookServiceImpl类`对应的对象，也叫原始对象，不能说它不能运行，只能说它在运行的过程中对于要增强的内容是缺失的。

SpringAOP是在不改变原有设计(代码)的前提下对其进行增强的，它的底层采用的是**代理模式**实现的，所以要对原始对象进行增强，就需要对原始对象创建代理对象，在代理对象中的方法把通知`如:MyAdvice中的method方法`内容加进去，就实现了增强，这就是我们所说的代理(Proxy)。

因此，SpringAOP的本质或者可以说底层实现是通过`代理模式`。

### AOP配置管理

#### 切入点表达式

```java
@Pointcut("execution(void com.blog.dao.impl.BookDaoImpl.update())")
```

对于AOP中切入点表达式，我们总共会学习三个内容，分别是`语法格式`、`通配符`和`书写技巧`。

#### 语法格式

首先我们先要明确两个概念:

- 切入点:要进行增强的方法
- 切入点表达式:要进行增强的方法的描述方式

对于切入点的描述，我们其实是有两种方式的，先来看下前面的例子
由于BookDaoImpl类实现了BookDao接口，那么有如下两种方式来描述

- 描述方式一：

  执行com.hit.dao包下的BookDao**接口**中的无参数update方法

  ```java
  execution(void com.hit.dao.BookDao.update())
  ```

- 描述方式二：

  执行com.hit.dao.impl包下的实现类BookDaoImpl类中的无参数update方法

  ```java
  execution(void com.hit.dao.impl.BookDaoImpl.update())
  ```

  因为调用接口方法的时候**最终运行的还是其实现类**的方法，所以上面两种描述方式都是可以的。

对于切入点表达式的语法为:

- 切入点表达式标准格式：动作关键字(访问修饰符 返回值 包名.类/接口名.方法名(参数) 异常名）

  对于这个格式，我们不需要硬记，通过一个例子，理解它:

  ```java
  execution(public User com.hit.service.UserService.findById(int))
  ```

- execution：动作关键字，描述切入点的行为动作，例如execution表示执行到指定切入点

- public:访问修饰符,还可以是public，private等，可以省略

- User：返回值，写返回值类型

- com.blog.service：包名，多级包使用点连接

- UserService:类/接口名称

- findById：方法名

- int:参数，直接写参数的类型，多个类型用逗号隔开

- 异常名：方法定义中抛出指定异常，可以省略

#### 使用通配符

`*`:**单个独立的任意符号**，可以独立出现，也可以作为前缀或者后缀的匹配符出现

匹配com.blog包下的任意包中的UserService类或接口中所有find开头的带有一个参数的方法:

```java
execution（public * com.blog.*.UserService.find*(*))
```

`..`：多个**连续**的任意符号，可以独立出现，常用于简化包名与参数的书写
匹配com包下的任意包中的UserService类或接口中所有名称为findById的方法:

```java
execution（public User com..UserService.findById(..))
```

`+`：专用于匹配子类类型
这个使用率较低，描述子类的，`*Service+`，表示所有以Service结尾的接口的子类:

```java
execution(* *..*Service+.*(..))
```

#### 书写技巧

对于切入点表达式的编写其实是很灵活的，那么在编写的时候，有没有什么好的技巧让我们用用:

- 所有代码按照标准规范开发，否则以下技巧全部失效
- 描述切入点通常`描述接口`，而不描述实现类,如果描述到实现类，就出现紧耦合了
- 访问控制修饰符针对接口开发均采用public描述（`可省略访问控制修饰符描述`）
- 返回值类型对于增删改类使用精准类型加速匹配，对于查询类使用`*`通配快速描述
- `包名`书写尽量不使用`..`匹配，效率过低，常用`*`做单个包描述匹配，或精准匹配
- `接口名/类名`书写名称与模块相关的采用`*`匹配，例如UserService书写成`*Service`，绑定业务层接口名
- 方法名书写以`动词`进行`精准匹配`，名词采用`*`匹配，例如`getById`书写成`getBy*`，`selectAll`书写成`selectAll`
- 参数规则较为复杂，根据业务方法灵活调整
- 通常`不使用异常`作为`匹配`规则

### AOP通知类型

我们先来回顾下AOP通知:

- AOP通知描述了抽取的共性功能，根据共性功能抽取的位置不同，最终运行代码时要将其加入到合理的位置

那么具体可以将通知添加到哪里呢？一共提供了5种通知类型

- 前置通知
- 后置通知
- `环绕通知(重点)`
- 返回后通知(了解)
- 抛出异常后通知(了解)

为了更好的理解这几种通知类型，我们来看一张图：

![](https://pic.imgdb.cn/item/6315d94816f2c2beb18bafb7.jpg)

1. **前置通知**，追加功能到方法执行前,类似于在代码1或者代码2添加内容
2. **后置通知**,追加功能到方法执行后,不管方法执行的过程中有没有抛出异常都会执行，类似于在代码5添加内容
3. **返回后通知**,追加功能到方法执行后，只有方法正常执行结束后才进行,类似于在代码3添加内容，如果方法执行抛出异常，返回后通知将不会被添加
4. **抛出异常后通知**,追加功能到方法抛出异常后，只有方法执行出异常才进行,类似于在代码4添加内容，只有方法抛出异常后才会被添加
5. **环绕通知,环绕通知功能比较强大**，它可以追加功能到方法执行的前后，这也是比较常用的方式，它可以实现其他四种通知类型的功能，具体是如何实现的，需要我们往下学。

对应用到的注解为：

- @Before("pt()")
- @After()
- @Around
- @AfterReturning()
- @AfterThrowing()

其中Around若不做配置，只会执行对应方法内的语句，而没有执行未增强前的原方法语句。

需要在方法参参数中增加`ProceedingJoinPoint`, 然后调用相应的方法：

```java
@Around("pt()")
public void around(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
    System.out.println("around before advice ...");
    proceedingJoinPoint.proceed();
    System.out.println("around after advice ...");
}
```

当原方法有返回值时，如果我们使用环绕通知的话，要根据原始方法的返回值来设置环绕通知的**返回值**，具体解决方案为改为Object:

```java
@Around("pt()")
    public Object around(ProceedingJoinPoint pjp) throws Throwable {
        System.out.println("around before advice ...");
        Object res = pjp.proceed();
        System.out.println("around after advice ...");
        return res;
    }
```

当方法中出现异常时，用@AfterThrowing()：

```java
@Component
@Aspect
public class MyAdvice {
    @Pointcut("execution(int com.hit.dao.BookDao.select())")
    private void pt() {
    }

    @AfterThrowing("pt()")
    public void afterThrowing() {
        System.out.println("afterThrowing advice ...");
    }
}
```

其实可以都写在Around里，就只需要用一种注解即可：

![img](https://pic.imgdb.cn/item/6316050116f2c2beb1be2656.jpg)

环绕通知注意事项

1. 环绕通知必须依赖形参**ProceedingJoinPoint**才能实现对原始方法的调用，进而实现原始方法调用前后同时添加通知
2. 通知中如果未使用ProceedingJoinPoint对原始方法进行调用将跳过原始方法的执行
3. 对原始方法的调用可以不接收返回值，通知方法设置成void即可，如果接收返回值，最好设定为*Object*类型
4. 原始方法的返回值如果是void类型，通知方法的返回值类型可以设置成void,也可以设置成Object
5. 由于无法预知原始方法运行后是否会抛出异常，因此环绕通知方法必须要处理**Throwable**异常

### AOP通知获取数据

上面几乎没有对数据的操作，接下来我们要说说AOP中数据相关的内容，我们将从`获取参数`、`获取返回值`和`获取异常`三个方面来研究切入点的相关信息。
前面我们介绍通知类型的时候总共讲了五种，那么对于这五种类型都会有参数，返回值和异常吗?
我们先来逐一分析下:

- 获取切入点方法的参数，所有的通知类型都可以获取参数
  - **JoinPoint**：适用于前置、后置、返回后、抛出异常后通知
  - **ProceedingJoinPoint**：适用于环绕通知
- 获取切入点方法返回值，前置和抛出异常后通知是没有返回值，后置通知可有可无，所以不做研究
  - 返回后通知
  - 环绕通知
- 获取切入点方法运行异常信息，前置和返回后通知是不会有，后置通知可有可无，所以不做研究
  - 抛出异常后通知
  - 环绕通知

#### @Before注解

增强类：

```java
@Override
    public int findId(int id) {
        System.out.println("id:" + id);
        return id;
    }
```

通知类：

````java
@Pointcut("execution(int com.hit.BookDao.findId(..))")
private void pt() {
}
@Before("pt()")
public void before(JoinPoint joinPoint) {
    Object[] args = joinPoint.getArgs();
    System.out.println(Arrays.toString(args));
    System.out.println("before advice ...");
}
````

此时在App中调用findId方法传参会打印出id， 注意Array.toString()不可省略。

#### @Around()注解

**环绕通知**也是类似的操作，因为ProceedJoinPoint是JoinPoint的子类，也有getArags()方法：

```java
@Component
@Aspect
public class MyAdvice {

    @Pointcut("execution(* com.hit.dao.BookDao.findName(..))")
    public void pt(){}

    @Around("pt()")
    public Object around(ProceedingJoinPoint pjp) throws Throwable {
        Object[] args = pjp.getArgs();
        System.out.println(Arrays.toString(args));
        Object res = pjp.proceed();
        return res;
    }
}
```

注意:

- pjp.proceed()方法是有两个构造方法，分别是:

  - proceed()
  - proceed(Object[] object)

- 调用无参数的proceed，当原始方法有参数，会在调用的过程中自动传入参数

- 所以调用这两个方法的任意一个都可以完成功能

- 但是当**需要修改原始方法的参数**时，就只能采用带有参数的方法,如下:

  ```java
  @Component
  @Aspect
  public class MyAdvice {
  
      @Pointcut("execution(* com.hit.dao.BookDao.findName(..))")
      public void pt(){}
  
      @Around("pt()")
      public Object around(ProceedingJoinPoint pjp) throws Throwable {
          Object[] args = pjp.getArgs();
          System.out.println(Arrays.toString(args));
          args[0] = 9421;
          Object res = pjp.proceed(args);
          return res;
      }
  }
  ```

#### @AfterReturing()注解

对于返回值，只有返回后`AfterReturing`和环绕`Around`这两个通知类型可以获取，具体如何获取?

```java
@Component
@Aspect
public class MyAdvice {

    @Pointcut("execution(* com.hit.dao.BookDao.findName(..))")
    public void pt(){}

    @Around("pt()")
    public Object around(ProceedingJoinPoint pjp) throws Throwable {
        Object[] args = pjp.getArgs();
        System.out.println(Arrays.toString(args));
        args[0] = 9421;
        Object res = pjp.proceed(args);
        return res;
    }
}
```

此时return的**res**会返回给增强类，可在传参前作数据预处理。

返回后通知获取返回值使用**@AfterReturning(value = "pt()", returning = "res")**:

```java
@Component
@Aspect
public class MyAdvice {

    @Pointcut("execution(* com.hit.dao.BookDao.findName(..))")
    public void pt(){}

    @AfterReturning(value = "pt()", returning = "res")
    public void afterReturning(Object res){
        System.out.println("afterReturning advice ..." + res);
    }
}
```

注意:

1. 参数名的问题
   赋给returning的值，必须与Object类型参数名一致，上面的代码中均为`res`

2. afterReturning方法参数类型的问题
   参数类型可以写成String，但是为了能匹配更多的参数类型，建议写成Object类型

3. afterReturning方法参数的顺序问题

   如果存在**JoinPoint参数，则必须将其放在第一位**，否则运行将报错

   ```java
   public void afterReturning(JoinPoint jp,Object res)
   ```

#### @AfterThrowing()注解

对于获取抛出的异常，只有抛出异常后`AfterThrowing`和环绕`Around`这两个通知类型可以获取，具体如何获取?

- 环绕通知获取异常
  这块比较简单，以前我们是抛出异常，现在只需要将异常捕获，就可以获取到原始方法的异常信息了

  ```java
  @Component
  @Aspect
  public class MyAdvice {
  
      @Pointcut("execution(* com.hit.BookDao.findName(..))")
      public void pt(){}
  
      @Around("pt()")
      public Object around(ProceedingJoinPoint pjp) {
          Object[] args = pjp.getArgs();
          System.out.println(Arrays.toString(args));
          args[0] = 9421;
          Object res = null;
          try {
              res = pjp.proceed(args);
          } catch (Throwable e) {
              throw new RuntimeException(e);
          }
          return res;
      }
  }
  ```

- 抛出异常后通知获取异常

  ```java
  @Component
  @Aspect
  public class MyAdvice {
      @Pointcut("execution(* com.hit.BookDao.findName(..))")
      public void pt() {
      }
  
      @AfterThrowing(value = "pt()", throwing = "throwable")
      public void afterThrowing(Throwable throwable) {
          System.out.println("afterThrowing advice ..." + throwable);
      }
  }
  ```

至此，AOP通知如何获取数据就已经讲解完了，数据中包含`参数`、`返回值`、`异常(了解)`。

#### AOP实例

需求：对百度网盘分享链接输入密码时尾部多输入的空格做兼容处理。
问题描述：

- 当我们从别人发给我们的内容中复制提取码的时候，有时候会多复制到一些空格，直接粘贴到百度的提取码输入框
- 但是百度那边记录的提取码是没有空格的
- 这个时候如果不做处理，直接对比的话，就会引发提取码不一致，导致无法访问百度盘上的内容
- 所以多输入一个空格可能会导致项目的功能无法正常使用。
- 此时我们就想能不能将输入的参数先帮用户去掉空格再操作呢?
  - 答案是可以的，我们只需要在业务方法执行之前对所有的输入参数进行格式处理——trim()
- 那要对所有的参数都需要去除空格么?
  - 也没有必要，一般只需要针对字符串处理即可。

- 以后涉及到需要去除前后空格的业务可能会有很多，这个去空格的代码是每个业务都写么?
  - 可以考虑使**用AOP来统一处理**。
- AOP有五种通知类型，该使用哪种呢?
  - 我们的需求是**将原始方法的参数处理后再参与原始方法的调用**，能做这件事的就只有**环绕通知**。

通知类如下：

```java
@Component
@Aspect
public class MyAdvice {
    @Pointcut("execution(* com.hit.service.*Service.*(..))")
    public void pt(){}

    @Around("pt()")
    public Object around(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
        Object[] args = proceedingJoinPoint.getArgs();
        for (int i = 0; i < args.length; i++) {
            if ((String.class).equals(args[i].getClass())){
                args[i] = args[i].toString().trim();
            }
        }
        Object res = proceedingJoinPoint.proceed(args);
        return res;
    }
}
```

### AOP总结

#### AOP核心概念

- 概念：AOP(Aspect Oriented Programming)面向切面编程，一种编程范式
- 作用：在不惊动原始设计的基础上为方法进行功能`增强`
- 核心概念
  - 代理（Proxy）：SpringAOP的核心本质是采用`代理模式`实现的
  - 连接点（JoinPoint）：在SpringAOP中，理解为任意方法的执行
  - 切入点（Pointcut）：匹配连接点的式子，也是具有共性功能的方法描述
  - 通知（Advice）：若干个方法的共性功能，在切入点处执行，最终体现为一个方法
  - 切面（Aspect）：描述通知与切入点的对应关系
  - 目标对象（Target）：被代理的原始对象成为目标对象

#### 切入点表达式

- 切入点表达式标准格式：动作关键字(访问修饰符 返回值 包名.类/接口名.方法名（参数）异常名)

  ```java
  execution(* com.itheima.service.*Service.*(..))
  ```

- 切入点表达式描述通配符：

  - 作用：用于快速描述，范围描述
  - `*`：匹配任意符号（常用）
  - `..` ：匹配多个连续的任意符号（常用）
  - `+`：匹配子类类型

- 切入点表达式书写技巧

  1. 按`标准规范`开发
  2. 查询操作的返回值建议使用`*`匹配
  3. 减少使用`..`的形式描述包，效率低
  4. `对接口进行描述`，使用`*`表示模块名，例如UserService的匹配描述为`*Service`
  5. 方法名书写保留动词，例如get，使用`*`表示名词，例如getById匹配描述为getBy`*`
  6. 参数根据实际情况灵活调整

#### 五种通知类型

- 前置通知
- 后置通知
- 环绕通知（重点）
  - 环绕通知依赖形参ProceedingJoinPoint才能实现对原始方法的调用
  - 环绕通知可以隔离原始方法的调用执行
  - 环绕通知返回值设置为Object类型
  - 环绕通知中可以对原始方法调用过程中出现的异常进行处理
- 返回后通知
- 抛出异常后通知

#### 通知中获取参数

- 获取切入点方法的参数，所有的通知类型都可以获取参数
  - JoinPoint：适用于前置、后置、返回后、抛出异常后通知
  - ProceedingJoinPoint：适用于环绕通知
- 获取切入点方法返回值，前置和抛出异常后通知是没有返回值，后置通知可有可无，所以不做研究
  - 返回后通知
  - 环绕通知
- 获取切入点方法运行异常信息，前置和返回后通知是不会有，后置通知可有可无，所以不做研究
  - 抛出异常后通知
  - 环绕通知

## Spring事务

### 事务相关概念

- 事务作用：在数据层保障一系列的数据库操作同成功同失败
- Spring事务作用：在数据层或业务层保障一系列的数据库操作同成功同失败

数据层或数据库有**事务**我们可以理解，为什么业务层也需要处理事务呢？举个简单的例子

- 转账业务会有两次数据层的调用，一次是加钱一次是减钱
- 把事务放在数据层，加钱和减钱就有两个事务
- 没办法保证加钱和减钱同时成功或者同时失败
- 这个时候就需要将事务放在业务层进行处理。

Spring为了管理事务，提供了一个**平台事务管理器**`PlatformTransactionManager`

```java
public interface PlatformTransactionManager extends TransactionManager {
    TransactionStatus getTransaction(@Nullable TransactionDefinition var1) throws TransactionException;

    void commit(TransactionStatus var1) throws TransactionException;

    void rollback(TransactionStatus var1) throws TransactionException;
}
```

commit是用来提交事务，rollback是用来回滚事务。

PlatformTransactionManager只是一个**接口**，Spring还为其提供了一个具体的实现:

```java
public class DataSourceTransactionManager extends AbstractPlatformTransactionManager implements ResourceTransactionManager, InitializingBean {
    @Nullable
    private DataSource dataSource;
    private boolean enforceReadOnly;
···
···

}
```

从名称上可以看出，我们只需要给它一个**DataSource**对象，它就可以帮你去在**业务层管理事务**。其内部采用的是JDBC的事务。所以说如果你持久层采用的是JDBC相关的技术，就可以采用这个事务管理器来管理你的事务。而Mybatis内部采用的就是JDBC的事务，所以后期我们Spring整合Mybatis就采用的这个`DataSourceTransactionManager`事务管理器。

当程序出问题后，我们需要让事务进行回滚，而且这个事务应该是加在业务层上，而Spring的事务管理就是用来解决这类问题的。

Spring事务管理具体的实现步骤如下:

`步骤一：`在需要被事务管理的方法上添加`@Transactional`注解:

```java
@Service
public class AccountServiceImpl implements AccountService {
    @Autowired
    protected AccountDao accountDao;

    @Transactional
    public void transfer(String out, String in, Double money) {
        accountDao.outMoney(out, money);
        int a = 1 / 0;
        accountDao.inMoney(in, money);
    }
}
```

注意:`@Transactional`可以写在接口类上、接口方法上、实现类上和实现类方法上

- 写在接口类上，该接口的所有实现类的所有方法都会有事务
- 写在接口方法上，该接口的所有实现类的该方法都会有事务
- 写在实现类上，该类中的所有方法都会有事务
- 写在实现类方法上，该方法上有事务
- `建议写在实现类或实现类的方法上`

`步骤二：`在JdbcConfig类中配置事务管理器:

```java
public class JdbcConfig {
    @Value("${jdbc.driver}")
    private String driver;
    @Value("${jdbc.url}")
    private String url;
    @Value("${jdbc.username}")
    private String username;
    @Value("${jdbc.password}")
    private String password;

    @Bean
    public DataSource dataSource() {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setDriverClassName(driver);
        dataSource.setUrl(url);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        return dataSource;
    }

    //配置事务管理器，mybatis使用的是jdbc事务
    @Bean
    public PlatformTransactionManager platformTransactionManager(DataSource dataSource){
        DataSourceTransactionManager transactionManager = new DataSourceTransactionManager();
        transactionManager.setDataSource(dataSource);
        return transactionManager;
    }
}
```

`步骤三：`在SpringConfig开启事务注解**@EnableTransactionManagement**

```java
@Configuration
@ComponentScan("com")
@PropertySource("jdbc.properties")
@EnableTransactionManagement
@Import({JdbcConfig.class, MyBatisConfig.class})
public class SpringConfig {
}
```

### Spring事务角色

这部分我们重点要理解两个概念，分别是`事务管理员`和`事务协调员`。

当未开启Spring事务之前:

![img](https://pic.imgdb.cn/item/63180cda16f2c2beb1974dc0.jpg)

- AccountDao的outMoney因为是修改操作，会开启一个事务T1
- AccountDao的inMoney因为是修改操作，会开启一个事务T2
- AccountService的transfer没有事务，
  - 运行过程中如果没有抛出异常，则T1和T2都正常提交，数据正确
  - 如果在两个方法中间抛出异常，T1因为执行成功提交事务，T2因为抛异常不会被执行
  - 就会导致数据出现错误

当开启Spring的事务管理后:

![img](https://pic.imgdb.cn/item/63180d1a16f2c2beb197868a.jpg)

- transfer上添加了@Transactional注解，在该方法上就会有一个事务T
- AccountDao的outMoney方法的事务T1加入到transfer的事务T中
- AccountDao的inMoney方法的事务T2加入到transfer的事务T中
- 这样就保证他们在同一个事务中，当业务层中出现异常，整个事务就会回滚，保证数据的准确性。

通过上面例子的分析，我们就可以得到如下概念:

- 事务管理员：发起事务方，在Spring中通常指代业务层开启事务的方法
- 事务协调员：加入事务方，在Spring中通常指代数据层方法，也可以是业务层方法

注意：目前的事务管理是基于`DataSourceTransactionManager`和`SqlSessionFactoryBean`使用的是同一个数据源。

### Spring事务属性

这部分我们主要学习三部分内容`事务配置`、`转账业务追加日志`、`事务传播行为`。

#### 事务配置

|          属性          |            作用            |                  示例                   |
| :--------------------: | :------------------------: | :-------------------------------------: |
|        readOnly        |     设置是否为只读事务     |        readOnly = true 只读事务         |
|        timeout         |      设置事务超时时间      |         timeout = -1(永不超时)          |
|      rollbackFor       |  设置事务回滚异常(class)   |  rollbackFor{NullPointException.class}  |
|  rollbackForClassName  | 设置事务回滚异常（String)  |            同上格式为字符串             |
|     noRollbackFor      | 设置事务不回滚异常(class)  | noRollbackFor{NullPointExceptior.class} |
| noRollbackForClassName | 设置事务不回滚异常(String) |            同上格式为字符串             |
|       isolation        |      设置事务隔离级别      |     isolation = Isolation. DEFAULT      |
|      propagation       |      设置事务传播行为      |                    …                    |

上面这些属性都可以在`@Transactional`注解的参数上进行设置。

- readOnly：true只读事务，false读写事务，增删改要设为false,查询设为true。

- timeout:设置超时时间单位秒，在多长时间之内事务没有提交成功就自动回滚，-1表示不设置超时时间。

- rollbackFor:当**出现指定异常进行事务回滚**（相当常用）。

- noRollbackFor:当出现指定异常不进行事务回滚

  - 思考:出现异常事务会自动回滚，这个是我们之前就已经知道的

  - noRollbackFor是设定对于指定的异常不回滚，这个好理解

  - rollbackFor是指定回滚异常，对于异常事务不应该都回滚么，为什么还要指定?

    - 事实上**Spring的事务只会对Error异常和RuntimeException异常及其子类进行事务回滚**，其他的异常类型是不会回滚的，如下面的代码就不会回滚

      ```java
      @Service
      public class AccountServiceImpl implements AccountService {
          @Autowired
          protected AccountDao accountDao;
      
          @Transactional
          public void transfer(String out, String in, Double money) throws IOException {
              accountDao.outMoney(out, money);
              if (true) throw new IOException();
              accountDao.inMoney(in, money);
          }
      }
      ```

      所以当我们运行程序之后，Tom会少100块钱，而Jerry不会多100块钱，这100块钱就凭空消失了

    - 此时就可以使用**rollbackFor**属性来设置出现**IOException异常不回滚**

      ```java
      @Service
      public class AccountServiceImpl implements AccountService {
          @Autowired
          protected AccountDao accountDao;
      
          @Transactional(rollbackFor = {IOException.class})
          public void transfer(String out, String in, Double money) throws IOException {
              accountDao.outMoney(out, money);
              if (true) throw new IOException();
              accountDao.inMoney(in, money);
          }
      }
      ```

    - rollbackForClassName等同于rollbackFor,只不过**属性为异常的类全名字符串**

    - noRollbackForClassName等同于noRollbackFor，只不过**属性为异常的类全名字符串**

    - isolation设置事务的隔离级别（实际上**与Mysql的事务隔离级别一模一样**）

      - DEFAULT :默认隔离级别, 会采用数据库的隔离级别
      - READ_UNCOMMITTED : 读未提交
      - READ_COMMITTED : 读已提交
      - REPEATABLE_READ : 重复读取
      - SERIALIZABLE: 串行化

#### 事务传播行为

![img](https://pic.imgdb.cn/item/6318177d16f2c2beb1a2274f.jpg)

对于上述案例的分析:

- log方法、inMoney方法和outMoney方法都属于**增删改**，分别有事务T1,T2,T3
- transfer因为加了`@Transactional`注解，也开启了事务T
- 前面我们讲过**Spring事务会把T1,T2,T3都加入到事务T中**（Spring事务管理的关键）
- 所以当转账失败后，`所有的事务都回滚`，导致日志没有记录下来
- 这和我们的需求不符，这个时候我们就想能不能让**log方法单独是一个事务**呢?

要想解决这个问题，就需要用到**事务传播行为**，所谓的事务传播行为指的是:

- 事务传播行为：*事务协调员对事务管理员所携带事务的处理态度*。
  - 具体如何解决，就需要用到之前我们没有说的`propagation属性`。

- 修改logService改变事务的传播行为

  ```java
  @Service
  public class LogServiceImpl implements LogService {
      @Autowired
      private LogDao logDao;
  
      @Transactional(propagation = Propagation.REQUIRES_NEW)
      public void log(String out, String in, Double money) {
          logDao.log(out + "向" + in + "转账" + money + "元");
      }
  }
  ```

此时运行后，就能实现我们想要的结果，**不管转账是否成功，都会记录日志**。

事务传播行为的可选值:

![S8KtZ](https://i.328888.xyz/2023/03/08/S8KtZ.png)
