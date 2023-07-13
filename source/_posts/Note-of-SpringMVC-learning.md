---
title:
  SpringMVC学习笔记
date:
  2023-03-12 18:00:45
tags:
  java
---

SpringMVC是隶属于Spring框架的一部分，主要是用来进行Web开发，是**对Servlet进行了封装**。

SpringMVC是处于Web层的框架，所以其主要作用就是用来**接收前端发过来的请求和数据**，然后经过处理之后将处理结果响应给前端，所以如何处理请求和响应是SpringMVC中非常重要的一块内容。

REST是一种软件架构风格，可以**降低开发的复杂性**，提高系统的可伸缩性，后期的应用也是非常广泛。

对于SpringMVC的学习，`最终要达成的目标：`

1. 掌握基于SpringMVC获取请求参数和响应JSON数据操作
2. 熟练应用基于REST风格的请求路径设置与参数传递
3. 能根据实际业务建立前后端开发通信协议，并进行实现
4. 基于SSM整合技术开发任意业务模块功能

## SpringMCV总览

目前Java Web的开发方式是如下：

将后端服务器Servlet拆分成三层，分别是Web，Service和DAO。

- `web`层主要由`servlet`来处理，负责页面请求和数据的收集以及响应结果给前端
- `service`层主要负责**业务逻辑**的处理
- `dao`层主要负责**数据**的增删改查操作

- 但`servlet`处理请求和数据时，存在一个问题：一个`servlet`只能处理一个请求

针对**Web层进行优化**，采用MVC设计模式，将其设计为Controller，View和Model，即MVC的设计模式。
  - `controller`负责请求和数据的接收，接收后将其转发给`service`进行业务处理
  - `service`根据需要会调用`dao`对数据进行增删改查
  - `dao`把数据处理完后，将结果交给`service`，`service`再交给`controller`
  - `controller`根据需求组装成`Model`和`View`，`Model`和`View`组合起来生成页面，转发给前端浏览器
  - 这样做的好处就是`controller`可以处理多个请求，并对请求进行分发，执行不同的业务操作

但随着互联网的发展，上面的模式因为是**同步**调用，性能太差跟不上需求，所以**异步**调用走到了前端，是现在比较流行的一种处理方式。

![img](https://pic.imgdb.cn/item/631969df16f2c2beb1dfa3f2.jpg)

- 因为是异步调用，所以后端不需要返回View视图，将其去除
- 前端如果通过异步调用的方式进行交互，后端就需要**将返回的数据转换成JSON格式**进行返回
- SpringMVC主要负责的就是
  - controller如何接收请求和数据
  - 如何将请求和数据转发给业务层
  - 如何将响应数据转换成JSON返回到前端
- SpringMVC是一种基于Java实现MVC模型的轻量级Web框架
  - 优点
    - 使用简单、开发快捷（相比较于Servlet）
    - 灵活性强

## SpringMCV入门

因为SpringMVC是一个Web框架，将来是要**替换Servlet**，所以先来回顾下以前Servlet是如何进行开发的?

1. 创建web工程(Maven结构)
2. 设置tomcat服务器，加载web工程(tomcat插件)
3. 导入坐标(Servlet)
4. 定义处理请求的功能类(UserServlet)
5. 设置请求映射(配置映射关系)

SpringMVC的制作过程和上述流程几乎是一致的，具体的实现流程是什么?

1. 创建web工程(Maven结构)
2. 设置tomcat服务器，加载web工程(tomcat插件)
3. 导入坐标(SpringMVC+Servlet)
4. 定义处理请求的功能类(UserController)
5. 设置请求映射(配置映射关系)
6. 将SpringMVC设定加载到Tomcat容器中

另外，使用Maven骨架的webapp搭建JavaWeb环境配置tomcat会更方便，可直接识别为Web工件。

搭建好Web环境导入SpringMVC坐标后，创建Controller类(即javaWeb中的Servlet)：

```java
//定义Controller，使用@Controller定义Bean让Spring对该类进行托管
@Controller
public class UserController {
    //设置当前访问路径，使用@RequestMapping
    @RequestMapping("/save")
    //设置当前对象的返回值类型
    @ResponseBody
    public String save(){
        System.out.println("user save ...");
        return "{'module':'SpringMVC'}";
        //返回值为JSON格式的字符串
    }
}
```

始化SpringMVC环境（同Spring环境），设定SpringMVC加载对应的Bean：

```java
//创建SpringMVC的配置文件，加载controller对应的bean
@Configuration
//
@ComponentScan("com.hit.controller")
public class SpringMvcConfig {
}
```

初始化Servlet容器(类似Spring入门中的App类)，加载SpringMVC环境，设置SpringMVC对请求进行的处理：

```java
package com.hit.config;

import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.AnnotationConfigWebApplicationContext;
import org.springframework.web.servlet.support.AbstractDispatcherServletInitializer;

//定义一个servlet容器的配置类，在里面加载Spring的配置，继承AbstractDispatcherServletInitializer并重写其方法
public class ServletContainerInitConfig extends AbstractDispatcherServletInitializer {
    //加载SpringMvc容器配置
    protected WebApplicationContext createServletApplicationContext() {
        AnnotationConfigWebApplicationContext context = new AnnotationConfigWebApplicationContext();
        context.register(SpringMvcConfig.class);
        return context;
    }
    //设置哪些请求归SpringMvc处理
    protected String[] getServletMappings() {
        //相当于JavaWeb中filter所有请求都交由SpringMVC处理
        return new String[]{"/"};
    }

    //加载Spring容器配置
    protected WebApplicationContext createRootApplicationContext() {
        return null;
    }
}

```

此时项目结构为：

![Snipaste 2023 03 19 17 52 39](https://s1.ax1x.com/2023/03/19/ppYIR0A.png)

最后访问localhost/save即可，另外也可在IDEA内进行接口测试。页面上成功出现`{'info':'springmvc'}`，至此我们的SpringMVC入门案例就完成了。

### 注意事项

- SpringMVC是基于Spring的，在pom.xml只导入了`spring-webmvc`jar包的原因是它会自动依赖spring相关坐标
- `AbstractDispatcherServletInitializer`类是SpringMVC提供的快速初始化Web3.0容器的抽象类
- **AbstractDispatcherServletInitializer**提供了三个接口方法供用户实现
  - `createServletApplicationContext`方法，创建Servlet容器时，加载SpringMVC对应的bean并放入`WebApplicationContext`对象范围中，而`WebApplicationContext`的作用范围为`ServletContext`范围，即整个web容器范围。
  - `getServletMappings`方法，设定SpringMVC对应的请求映射路径，即SpringMVC**拦截哪些请求**。
  - `createRootApplicationContext`方法，如果创建Servlet容器时需要加载非SpringMVC对应的bean，使用当前方法进行，使用方式和`createServletApplicationContext`相同。
- `createServletApplicationContext`用来加载**SpringMVC环境**
- `createRootApplicationContext`用来加载**Spring环境**

### SpringMVC工作流程解析

#### 启动服务器流程

1. 服务器启动，执行**ServletContainerInitConfig**类，初始化web容器

   - 功能类似于web.xml

     ```java
     public class ServletContainerInitConfig extends AbstractDispatcherServletInitializer {
     
         protected WebApplicationContext createServletApplicationContext() {
             AnnotationConfigWebApplicationContext context = new AnnotationConfigWebApplicationContext();
             context.register(SpringMvcConfig.class);
             return context;
         }
     
         protected String[] getServletMappings() {
             return new String[]{"/"};
         }
     
         protected WebApplicationContext createRootApplicationContext() {
             return null;
         }
     }
     ```

2. 执行**createServletApplicationContext()**方法，创建了WebApplicationContext对象

   - 该方法加载SpringMVC的配置类SpringMvcConfig来初始化SpringMVC的容器

     ```java
     protected WebApplicationContext createServletApplicationContext() {
         AnnotationConfigWebApplicationContext context = new AnnotationConfigWebApplicationContext();
         context.register(SpringMvcConfig.class);
         return context;
     }
     ```

3. 加载**SpringMvcConfig配置类**

   ```java
   @Configuration
   @ComponentScan("com.hit.controller")
   public class SpringMvcConfig {
   }
   ```

4. 执行`@ComponentScan`加载对应的bean

   - 扫描指定包及其子包下所有类上的注解，如Controller类上的`@Controller`注解

5. 加载`UserController`类，每个`@RequestMapping`的名称（即url请求路径）对应一个具体的方法

   - 此时就建立了/save和save()方法的对应关系

     ```java
     @Controller
     public class UserController {
         @RequestMapping("/save")
         @ResponseBody
         public String save(){
             System.out.println("user save ...");
             return "{'module':'SpringMVC'}";
         }
     }
     ```

6. 执行`getServletMappings()`方法，设定SpringMVC拦截请求的路径规则`/`, 代表所拦截请求的路径规则，只有被拦截后才能交给SpringMVC来处理请求

   ```java
   protected String[] getServletMappings() {
       return new String[]{"/"};
   }
   ```

#### 单次请求流程

1. 发送请求`http://localhost/save`
2. web容器发现该请求**满足SpringMVC拦截规则**，将请求交给SpringMVC处理
3. 解析请求路径/save
4. 由`/save`匹配执行对应的方法`save()`上面的第5步已经将请求路径和方法建立了对应关系，通过`/save`就能找到对应的`save()`方法
5. 执行`save()`
6. 检测到有`@ResponseBody`直接将`save()`方法的返回值作为响应体返回给请求方

### Bean加载控制

#### 问题分析

目前项目中有config, controller, service, dao四个包：

- `config`目录存入的是配置类，写过的配置类有:
  - ServletContainersInitConfig
  - SpringConfig
  - SpringMvcConfig
  - JdbcConfig
  - MybatisConfig
- `controller`目录存放的是`SpringMVC`的`controller`类
- `service`目录存放的是`service`接口和实现类
- `dao`目录存放的是`dao/Mapper`接口

除config外其他所有类都需要被容器管理为bean对象，那么具体bean对象是由Spring加载还是SpringMVC加载？

- `SpringMVC`控制的bean
  - 表现层bean,也就是`controller`包下的类(即Servlet功能的类)
- `Spring`控制的bean
  - 业务bean(`Service`)
  - 功能bean(`DataSource`,`SqlSessionFactoryBean`,`MapperScannerConfigurer`等)

分析清楚谁该管哪些bean以后，接下来要解决的问题是如何让`Spring`和`SpringMVC`分开加载各自的内容。

#### 解决思路

对于上面的问题，解决方案也比较简单

- 加载Spring控制的bean的时候，`排除掉`**SpringMVC控制的bean**。

那么具体该如何实现呢？

- 方式一：Spring加载的bean设定扫描范围`com.hit`，排除掉`controller`包内的bean
- 方式二：Spring加载的bean设定扫描范围为精确扫描，具体到`service`包，`dao`包等
- 方式三：不区分Spring与SpringMVC的环境，加载到同一个环境中(`了解即可`)

具体解决：

- 解决方案一：修改Spring配置类，设定扫描范围为精准范围

  ```java
  @Configuration
  @ComponentScan({"com.hit.dao","com.hit.service"})
  public class SpringConfig {
  }
  ```

  再次运行App运行类，报错`NoSuchBeanDefinitionException`，说明Spring配置类没有扫描到UserController，目的达成.

- 解决方案二：修改Spring配置类，设定扫描范围为com.blog，排除掉controller包中的bean

  ```java
  @Configuration
  @ComponentScan(value = "com.hit",
      excludeFilters = @ComponentScan.Filter(
              type = FilterType.ANNOTATION,
              classes = Controller.class
      ))
  public class SpringConfig {
  }
  ```

- excludeFilters属性：设置扫描加载bean时，排除的过滤规则
- type属性：设置排除规则，当前使用按照bean定义时的注解类型进行排除
  - ANNOTATION：按照注解排除
  - ASSIGNABLE_TYPE:按照指定的类型过滤
  - ASPECTJ:按照Aspectj表达式排除，基本上不会用
  - REGEX:按照正则表达式排除
  - CUSTOM:按照自定义规则排除
- classes属性：设置排除的具体注解类，当前设置排除`@Controller`定义的bean

运行程序之前，我们还需要把`SpringMvcConfig`配置类上的`@ComponentScan`注解注释掉，否则不会报错，将正常输出

- 出现问题的原因是
  - Spring配置类扫描的包是`com.hit`
  - SpringMVC的配置类，`SpringMvcConfig`上有一个`@Configuration`注解，也会被Spring扫描到
  - SpringMvcConfig上又有一个`@ComponentScan`，把controller类又给扫描进来了
  - 所以如果不把`@ComponentScan`注释掉，Spring配置类将Controller排除，但是因为扫描到SpringMVC的配置类，又将其加载回来，演示的效果就出不来
  - 解决方案，也简单，把SpringMVC的配置类移出Spring配置类的扫描范围即可。

运行程序，同样报错`NoSuchBeanDefinitionException`，目的达成

最后一个问题，有了Spring的配置类，要想在tomcat服务器启动将其加载，我们需要修改`ServletContainersInitConfig`类：

```java
public class ServletContainerInitConfig extends AbstractDispatcherServletInitializer {
    //加载SpringMvc配置
    protected WebApplicationContext createServletApplicationContext() {
        AnnotationConfigWebApplicationContext context = new AnnotationConfigWebApplicationContext();
        context.register(SpringMvcConfig.class);
        return context;
    }
    //设置哪些请求归SpringMvc处理
    protected String[] getServletMappings() {
        return new String[]{"/"};
    }

    //加载Spring容器配置
    protected WebApplicationContext createRootApplicationContext() {
        AnnotationConfigWebApplicationContext context = new AnnotationConfigWebApplicationContext();
        context.register(SpringConfig.class);
        return context;
    }
}
```


对于上面的`ServletContainerInitConfig`配置类，Spring还提供了一种更简单的配置方式，可以不用再去创建`AnnotationConfigWebApplicationContext`对象，不用手动`register`对应的配置类
我们改用继承它的子类`AbstractAnnotationConfigDispatcherServletInitializer`，然后重写三个方法即可

```java
public class ServletContainerInitConfig extends AbstractAnnotationConfigDispatcherServletInitializer {

    protected Class<?>[] getRootConfigClasses() {
        return new Class[]{SpringConfig.class};
    }

    protected Class<?>[] getServletConfigClasses() {
        return new Class[]{SpringMvcConfig.class};
    }

    protected String[] getServletMappings() {
        return new String[]{"/"};
    }
}
```

## SpringMVC请求与响应

SpringMVC是web层的框架，主要的作用是**接收请求、接收数据、响应结果**。
所以这部分是学习SpringMVC的重点内容，这里主要会讲解四部分内容:

- 请求映射路径
- 请求参数
- 日期类型参数传递
- 响应JSON数据

### 请求映射路径

如果需要由多个controller，但不能重复，可在controller前加**RequestMapping**注解：

```java
@Controller
@RequestMapping("/user")
public class UserController {

    @RequestMapping("/save")
    @ResponseBody
    public String save(){
        System.out.println("user save ..");
        return "{'module':'user save'}";
    }

    @RequestMapping("/delete")
    @ResponseBody
    public String delete(){
        System.out.println("user delete ..");
        return "{'module':'user delete'}";
    }
}
```

### 请求参数

#### 基本数据类型

按上面的方式写需要前端请求参数名与后端的save函数形参相同，否则需要用倒@RequestParam注解：

```java
@RequestMapping("/commonParam")
    @ResponseBody
    public String commonParam(@RequestParam("username") String name, int age){
        System.out.println("普通参数传递name --> " + name);
        System.out.println("普通参数传递age --> " + age);
        return "{'module':'commonParam'}";
    }
```

#### pojo类型

```java
//POJO参数：请求参数与形参对象中的属性对应即可完成参数传递
@RequestMapping("/pojoParam")
@ResponseBody
public String pojoParam(User user){
    System.out.println("POJO参数传递user --> " + user);
    return "{'module':'pojo param'}";
}
```

当请求为`localhost/user/pojoParam?name=Helsing&age=1024`

控制台输出：`POJO参数传递user —> User{name=’Helsing’, age=1024}`

- 注意:
  - POJO参数接收，前端GET和POST发送请求数据的方式不变。
  - 可使用嵌套Pojo参数
  - 请求**参数key的名称要和POJO中属性的名称一致**，否则无法封装。

#### 数组类型

- 数组参数：**请求参数名与形参对象属性名相同且请求参数为多个**，定义数组类型即可接收参数

- 发送请求和参数：`localhost/user/arrayParam?hobbies=sing&hobbies=jump&hobbies=rap&hobbies=basketball`

- 后台接收参数

  ```java
  @RequestMapping("/arrayParam")
  @ResponseBody
  public String arrayParam(String[] hobbies){
      System.out.println("数组参数传递user --> " + Arrays.toString(hobbies));
      return "{'module':'array param'}";
  }
  ```

- 控制台输出如下

  > 数组参数传递user —> [sing, jump, rap, basketball]

#### 集合类型

与数组类型，也可接收集合类型的参数：

- 发送请求和参数：`localhost/user/listParam?hobbies=sing&hobbies=jump&hobbies=rap&hobbies=basketball`

- 后台接收参数

  ```java
  @RequestMapping("/listParam")
  @ResponseBody
  public String listParam(List hobbies) {
      System.out.println("集合参数传递user --> " + hobbies);
      return "{'module':'list param'}";
  }
  ```

- 运行程序，报错`java.lang.IllegalArgumentException: Cannot generate variable name for non-typed Collection parameter type`

  - 错误原因：SpringMVC**将List看做是一个POJO对象来处理**，将其创建一个对象并准备把前端的数据封装到对象中，但是List是一个接口无法创建对象，所以报错。

- 解决方案是：使用`@RequestParam`注解

  ```java
  @RequestMapping("/listParam")
  @ResponseBody
  public String listParam(@RequestParam List hobbies) {
      System.out.println("集合参数传递user --> " + hobbies);
      return "{'module':'list param'}";
  }
  ```

- 控制台输出如下

  > 集合参数传递user —> [sing, jump, rap, basketball]

#### JSON数据传输(重点)

现在比较流行的开发方式为**异步调用**。前后台以异步方式进行交换，传输的数据使用的是JSON，所以前端如果发送的是JSON数据，后端该如何接收?

对于JSON数据类型，我们常见的有三种:

- json普通数组（[“value1”,”value2”,”value3”,…]）
- json对象（{key1:value1,key2:value2,…}）
- json对象数组（[{key1:value1,…},{key2:value2,…}]）

下面我们就来学习以上三种数据类型，前端如何发送，后端如何接收

##### 1. JSON普通数组

- `步骤一：`导入坐标

  ```xml
  <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
      <version>2.9.0</version>
  </dependency>
  ```

- `步骤二：`开启SpringMVC**注解支持**
  使用`@EnableWebMvc`，在SpringMVC的配置类中开启SpringMVC的注解支持，这里面就**包含了将JSON转换成对象**的功能。

  ```java
  @Configuration
  @ComponentScan("com.blog.controller")
  //开启json数据类型自动转换
  @EnableWebMvc
  public class SpringMvcConfig {
  }
  ```

- `步骤三：`PostMan发送JSON数据
  [![img](https://pic.imgdb.cn/item/631addfe16f2c2beb1732627.jpg)](https://pic.imgdb.cn/item/631addfe16f2c2beb1732627.jpg)

- `步骤四：`后台接收参数，参数前添加**@RequestBody**

- **注意**：此处与接收集合类型的参数不同，需要用@Request*Body*而不是@Request*Param*

- 使用`@RequestBody`注解将外部传递的json数组数据映射到形参的集合对象中作为数据

  ```java
  @RequestMapping("/jsonArrayParam")
  @ResponseBody
  public String jsonArrayParam(@RequestBody List<String> hobbies) {
      System.out.println("JSON数组参数传递hobbies --> " + hobbies);
      return "{'module':'json array param'}";
  }
  ```

  控制台输出如下

  > JSON数组参数传递hobbies —> [唱, 跳, Rap, 篮球]

实际上就是接收List类型的数据。

##### 2. JSON对象

- 请求和数据的发送:

  ```json
  {
      "name":"菲茨罗伊",
      "age":"27",
      "address":{
          "city":"萨尔沃",
          "province":"外域"
      }
  }
  ```

- 接收请求和参数

  ```java
  @RequestMapping("/jsonPojoParam")
  @ResponseBody
  public String jsonPojoParam(@RequestBody User user) {
      System.out.println("JSON对象参数传递user --> " + user);
      return "{'module':'json pojo param'}";
  }
  ```

  控制台输出如下

  > JSON对象参数传递user —> User{name=’菲茨罗伊’, age=27, address=Address{province=’外域’, city=’萨尔沃’}}

注意：请求的Json为pojo对象时，该类**不能自定义有参构造器**，会导致不能正常解析接收的pojo对象。

##### 3. JSON对象数组

- 发送请求和数据

  ```json
  [
      {
          "name":"菲茨罗伊",
          "age":"27",
          "address":{
              "city":"萨尔沃",
              "province":"外域"
          }
      },
      {
          "name":"地平线",
          "age":"136",
          "address":{
              "city":"奥林匹斯",
              "province":"外域"
          }
      }
  ]
  ```

- 接收请求和参数

  ```java
  @RequestMapping("/jsonPojoListParam")
  @ResponseBody
  public String jsonPojoListParam(@RequestBody List<User> users) {
      System.out.println("JSON对象数组参数传递user --> " + users);
      return "{'module':'json pojo list param'}";
  }
  ```

  控制台输出如下

  > JSON对象数组参数传递user —> [User{name=’菲茨罗伊’, age=27, address=Address{province=’外域’, city=’萨尔沃’}}, User{name=’地平线’, age=136, address=Address{province=’外域’, city=’奥林匹斯’}}]

**注意**：此时在处理方法的形参处使用的注解仍然是JSON对象的**@RequestBody**而不是接收集合时使用的**@RequestParam**。

##### 4. 小结

SpringMVC接收JSON数据的实现步骤为:

1. 导入jackson包
2. **开启SpringMVC注解驱动**，在配置类上添加`@EnableWebMvc`注解
3. 使用PostMan发送JSON数据
4. Controller方法的参数前添加`@RequestBody`注解

知识点1：`@EnableWebMvc`

| 名称 |       @EnableWebMvc       |
| :--: | :-----------------------: |
| 类型 |        配置类注解         |
| 位置 |  SpringMVC配置类定义上方  |
| 作用 | 开启SpringMVC多项辅助功能 |

知识点2：`@RequestBody`

| 名称 |                         @RequestBody                         |
| :--: | :----------------------------------------------------------: |
| 类型 |                           形参注解                           |
| 位置 |               SpringMVC控制器方法形参定义前面                |
| 作用 | 将请求中**请求体所包含的数据传递给请求参数**，此注解一个处理器方法只能使用一次 |

`@RequestBody`与`@RequestParam`区别

- 区别
  - `@RequestParam`用于接收url地址传参，表单传参【application/x-www-form-urlencoded】
  - `@RequestBody`用于接收json数据【application/json】
- 应用
  - 后期开发中，发送json格式数据为主，`@RequestBody`应用较广
  - 如果发送非json格式数据，选用`@RequestParam`接收请求参数

#### 日期类型参数

- `步骤一：`编写方法接收日期数据

  ```java
  @RequestMapping("/dateParam")
  @ResponseBody
  public String dateParam(Date date) {
      System.out.println("参数传递date --> " + date);
      return "{'module':'date param'}";
  }
  ```

- `步骤二：`启动Tomcat服务器

- `步骤三：`使用PostMan发送请求：`localhost:8080/user/dateParam?date=2077/12/21`

- `步骤四：`查看控制台，输出如下

  > 参数传递date —> Tue Dec 21 00:00:00 CST 2077

- `步骤五：`更换日期格式
  为了能更好的看到程序运行的结果，我们在方法中多添加一个日期参数

  ```java
  @RequestMapping("/dateParam")
  @ResponseBody
  public String dateParam(Date date1,Date date2) {
      System.out.println("参数传递date1 --> " + date1);
      System.out.println("参数传递date2 --> " + date2);
      return "{'module':'date param'}";
  }
  ```

使用PostMan发送请求，如果携带两个不同的日期格式，`localhost:8080/user/dateParam?date1=2077/12/21&date2=1997-02-13`

发送请求和数据后，页面会报400，`The request sent by the client was syntactically incorrect.`

错误的原因是将`1997-02-13`转换成日期类型的时候失败了，原因是SpringMVC默认支持的字符串转日期的格式为`yyyy/MM/dd`,而我们现在传递的不符合其默认格式，SpringMVC就无法进行格式转换，所以报错。

解决方案也比较简单，需要使用`@DateTimeFormat`注解。

```java
@RequestMapping("/dateParam")
@ResponseBody
public String dateParam(Date date1,@DateTimeFormat(pattern = "yyyy-MM-dd") Date date2) {
    System.out.println("参数传递date1 --> " + date1);
    System.out.println("参数传递date2 --> " + date2);
    return "{'module':'date param'}";
}
```

接下来我们再来发送一个**携带具体时间的日期**：

如`localhost:8080/user/dateParam?date1=2077/12/21&date2=1997-02-13&date3=2022/09/09 16:34:07`，那么SpringMVC该怎么处理呢？

继续修改UserController类，添加第三个参数，同时使用`@DateTimeFormat`来设置日期格式

```java
@RequestMapping("/dateParam")
@ResponseBody
public String dateParam(Date date1,
                        @DateTimeFormat(pattern = "yyyy-MM-dd") Date date2,
                        @DateTimeFormat(pattern ="yyyy/MM/dd HH:mm:ss") Date date3) {
    System.out.println("参数传递date1 --> " + date1);
    System.out.println("参数传递date2 --> " + date2);
    System.out.println("参数传递date3 --> " + date3);
    return "{'module':'date param'}";
}
```

##### 内部实现原理

我们首先先来思考一个问题:

- 前端传递字符串，后端使用日期Date接收
- 前端传递JSON数据，后端使用对象接收
- 前端传递字符串，后端使用Integer接收
- 后台需要的数据类型有很多种
- 在数据的传递过程中存在很多类型的转换

`问`:谁来做这个类型转换?

- `答`:SpringMVC

`问`:SpringMVC是如何实现类型转换的?

- `答`:SpringMVC中提供了很多类型转换接口和实现类

在框架中，有一些类型转换接口，其中有:

1. `Converter`接口

   注意：Converter所属的包为`org.springframework.core.convert.converter`

   ```java
   /**
   *    S: the source type
   *    T: the target type
   */
   @FunctionalInterface
   public interface Converter<S, T> {
       @Nullable
       //该方法就是将从页面上接收的数据(S)转换成我们想要的数据类型(T)返回
       T convert(S source);
   }
   ```

   到了源码页面我们按CTRL+H可以来看看`Converter`接口的层次结构

   这里给我们提供了很多对应`Converter`接口的实现类，用来实现不同数据类型之间的转换

   ![img](https://pic.imgdb.cn/item/631b004216f2c2beb19d8a0a.jpg)

2. `HttpMessageConverter`接口
   该接口是实现对象与JSON之间的转换工作
   注意：需要在SpringMVC的配置类把`@EnableWebMvc`当做标配配置上去，不要省略

### 响应

SpringMVC接收到请求和数据后，需要对数据进行处理，当然这个处理可以是转发给Service，Service层再调用Dao层完成的，不管怎样，处理完以后，都需要将结果**返回**给用户。

比如：根据用户ID查询用户信息、查询用户列表、新增用户等。
对于响应，主要就包含两部分内容：

- 响应页面
- 响应数据
  - 文本数据
  - json数据

因为异步调用是目前常用的主流方式，所以我们需要更关注的就是如何返回JSON数据，对于其他只需要认识了解即可。

#### 响应页面（了解）

- `步骤一：`设置返回页面

  ```java
  @Controller
  public class UserController {
      @RequestMapping("/toJumpPage")
      //注意
      //1.此处不能添加@ResponseBody,如果加了该注入，会直接将page.jsp当字符串返回前端
      //2.方法需要返回String
      public String toJumpPage(){
          System.out.println("跳转页面");
          return "page.jsp";
      }
  }
  ```

- `步骤二：`启动程序测试
  打开浏览器，访问`http://localhost:8080/toJumpPage`
  将跳转到`page.jsp`页面，并展示`page.jsp`页面的内容

#### 返回文本数据（了解）

- `步骤一：`设置返回文本内容

  ```java
  @RequestMapping("toText")
  //此时就需要添加@ResponseBody，将`response text`当成字符串返回给前端
  //如果不写@ResponseBody，则会将response text当成页面名去寻找，找不到报404
  @ResponseBody
  public String toText(){
      System.out.println("返回纯文本数据");
      return "response text";
  }
  ```

- `步骤二：`启动程序测试
  浏览器访问`http://localhost:8080/toText`
  页面上出现`response text`文本数据

#### 响应JSON数据

- 响应POJO对象

  ```java
  @RequestMapping("toJsonPojo")
  @ResponseBody
  public User toJsonPojo(){
      System.out.println("返回json对象数据");
      User user = new User();
      user.setName("Helsing");
      user.setAge(9527);
      return user;
  }
  ```

  返回值为实体类对象，设置返回值为实体类类型，即可实现返回对应对象的json数据，需要依赖@ResponseBody注解和@EnableWebMvc注解

- 访问

  ```
  http://localhost:8080/toJsonPojo
  ```

  页面上成功出现JSON类型数据

  > {“name”:”Helsing”,”age”:9527,”address”:null}

此类中**没有直接写如何转为JSON对象**，但返回了JSON数据，是因为`HttpMessageConverter`接口帮我们实现了对象与JSON之间的转换工作，我们只需要在`SpringMvcConfig`配置类上加上`@EnableWebMvc`注解即可。

SpringMVC太厉害了！

- 响应POJO集合对象

  ```java
  @RequestMapping("toJsonList")
  @ResponseBody
  public List<User> toJsonList(){
      List<User> users = new ArrayList<User>();
  
      User user1 = new User();
      user1.setName("马文");
      user1.setAge(27);
      users.add(user1);
  
      User user2 = new User();
      user2.setName("马武");
      user2.setAge(28);
      users.add(user2);
  
      return users;
  }
  ```

- 访问`http://localhost:8080/toJsonList`，页面上成功出现JSON集合类型数据

  > [{“name”:”马文”,”age”:27,”address”:null},{“name”:”马武”,”age”:28,”address”:null}]

知识点：**@ResponseBody**

|   名称   |                        @ResponseBody                         |
| :------: | :----------------------------------------------------------: |
|   类型   |                         方法\类注解                          |
|   位置   |            SpringMVC控制器方法定义上方和控制类上             |
|   作用   | 设置当前控制器返回值作为响应体, 写在类上，该类的所有方法都有该注解功能 |
| 相关属性 |               pattern：指定日期时间格式字符串                |

说明:

- 该注解可以写在类上或者方法上
- 写在类上就是该类下的所有方法都有`@ReponseBody`功能
- 当方法上有@ReponseBody注解后
  - 方法的返回值为字符串，会将其作为文本内容直接响应给前端
  - 方法的返回值为对象，会将对象转换成JSON响应给前端

此处又使用到了类型转换，内部还是通过`HttpMessageConverter`接口完成的，所以`Converter`除了前面所说的功能外，它还可以实现:

- 对象转Json数据(POJO -> json)
- 集合转Json数据(Collection -> json)

## REST风格请求

### 基本介绍

REST(Representational State Transfer)即表征性状态转移，是一种软件架构风格当我们想表示一个网络资源时，可以使用两种方式：

- 传统风格资源描述形式
  - `http://localhost/user/getById?id=1` 查询id为1的用户信息
  - `http://localhost/user/saveUser` 保存用户信息
- REST风格描述形式
  - `http://localhost/user/1`
  - `http://localhost/user`

很明显，传统风格一般是**一个请求url对应一种操作**，这样做不仅麻烦，而且也不安全，通过请求的`URL`地址，就大致能推测出该`URL`实现的是什么操作。

反观REST风格的描述，请求地址变简洁了，而且只看请求`URL`并不很容易能猜出来该`UR`L的具体功能，明显由更高的**安全性**。

因此REST的优势主要有：

1. 隐藏资源的访问行为，无法通过地址得知该资源是何种服务或操作
2. 书写简化url

那么问题也随之而来，一个相同的`URL`地址既可以是增加操作，也可以是修改或者查询，那么我们该如何区分该请求到底是什么操作呢？

- 按照REST风格访问资源时，使用`行为动作`(即**请求方式**)区分对资源进行了何种操作
  - `http://localhost/users` 查询全部用户信息 `GET`（查询）
  - `http://localhost/users/1` 查询**指定用户**信息 `GET`（查询）
  - `http://localhost/users` 添加用户信息 `POST`（新增/保存）
  - `http://localhost/users` 修改用户信息 `PUT`（修改/更新）
  - `http://localhost/users/1` 删除用户信息 `DELETE`（删除）

注意：

- 上述行为是约定方式，约定不是规范，约定可以打破，所以成为`REST`风格，而不是`REST`规范
  - REST提供了对应的**架构方式**，按照这种架构方式设计项目可以降低开发的复杂性，提高系统的可伸缩性
  - REST中规定`GET`/`POST`/`PUT`/`DELETE`针对的是查询/新增/修改/删除，但如果我们非要使用`GET`请求做删除，这点在程序上运行是可以实现的
  - 但是如果大多数人都遵循这种风格，你不遵循，那你写的代码在别人看来就有点莫名其妙了，所以最好还是遵循REST风格
- 描述模块的名称通常使用复数，也就是加s的格式描述，表示此类的资源，而非单个的资源，例如`users`、`books`、`accounts`..

- 搞清楚了什么是REST分各个后，后面会经常提到一个概念叫`RESTful`，那么什么是`RESTful`呢？

  - 根据REST风格对资源进行访问称为`RESTful`

  在我们后期的开发过程中，大多数都是遵循`REST`风格来访问我们的后台服务。

### 入门案例

#### 配置环境

环境与之前的SpringMVC一致，都需要ServletContainsInitConfig和SpringMvc两个配置类：

```java
public class ServletContainersInitConfig extends AbstractAnnotationConfigDispatcherServletInitializer {
    protected Class<?>[] getRootConfigClasses() {
        return new Class[0];
    }

    protected Class<?>[] getServletConfigClasses() {
        return new Class[]{SpringMvcConfig.class};
    }

    protected String[] getServletMappings() {
        return new String[]{"/"};
    }

    //乱码处理
    @Override
    protected Filter[] getServletFilters() {
        CharacterEncodingFilter filter = new CharacterEncodingFilter();
        filter.setEncoding("utf-8");
        return new Filter[]{filter};
    }
}
```

SpringMvc配置：

```java
@Configuration
@ComponentScan("com.hit.controller")
//开启JSON数据类型自动转换
@EnableWebMvc
public class SpringMvcConfig {
}
```

编写Pojo模型类User：

```java
public class User {
    private String name;
    private int age;

    public User() {
    }

    public User(String name, int age) {
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

    @Override
    public String toString() {
        return "User{" +
                "name='" + name + '\'' +
                ", age=" + age +
                '}';
    }
}
```

关键来了，编写相应Controller的方式与传统不同.

需求:将之前的增删改查替换成`RESTful`的开发方式。

1. 之前不同的**请求有不同的路径**,现在要将其修改为统一的请求路径
   - 修改前: 新增：`/save`，修改: `/update`，删除 `/delete`..
   - 修改后: 增删改查：`/users`
2. 根据`GET`查询、`POST`新增、`PUT`修改、`DELETE`删除**对方法的请求方式**进行限定
3. 发送请求的过程中如何设置请求参数?

#### RESTful风格的Controller

```java
@RequestMapping(value = "/users", method = RequestMethod.POST)
@ResponseBody
public String save(@RequestBody User user){
    System.out.println("user save..." + user);
    return "{'module':'user save''}";
}
```

此时用**POST请求发送带User对象的json数据**会返回module:user save的JSON数据。

注意：此时Controller中的**处理方法save()的参数**即为**请求时需要发送的参数**。

或者delete：

```java
@RequestMapping(value = "/delete", method = RequestMethod.DELETE)
@ResponseBody
public String delete(@RequestBody User user){
    System.out.println("user delete..." + user);
    return "{'module':'user delete''}";
}
```

但是现在的删除方法没有携带所要删除数据的id，所以针对RESTful的开发，如何携带**数据参数**?

答案是修改RequestMapping的value参数，将其与路径匹配：

```java
@RequestMapping(value = "/users/{id}",method = RequestMethod.DELETE)
@ResponseBody
public String delete(@PathVariable Integer id){
    System.out.println("user delete ..." + id);
    return "{'module':'user delete'}";
}
```

注意：此时形参需要加**@PathVariable**注解。

发送`DELETE`请求访问`localhost/users/9421`即可。

##### 方法参数与请求参数不同

此时delete方法的参数形参必须为url最后的参数名即id，若想要这两个参数名不同，需要使用注解参数：

```java
@RequestMapping(value = "/users/{id}",method = RequestMethod.DELETE)
@ResponseBody
public String delete(@PathVariable("id") Integer userId){
    System.out.println("user delete ..." + userId);
    return "{'module':'user delete'}";
}
```

##### 一次请求**多个参数**

直接在url最后加/即可。

```java
@RequestMapping(value = "/users/{id}/{name}",method = RequestMethod.DELETE)
@ResponseBody
public String delete(@PathVariable("id") Integer userId,@PathVariable String name){
    System.out.println("user delete ..." + userId + ":" + name);
    return "{'module':'user delete'}";
}
```

##### 修改请求PUT

```java
@RequestMapping(value = "/users",method = RequestMethod.PUT)
@ResponseBody
public String update(@RequestBody User user){
    System.out.println("user update ..." + user);
    return "{'module':'user update'}";
}
```

##### 根据ID查询(重要)

将请求路径更改为`/users/{id}`，并设置当前请求方法为`GET`

```java
@RequestMapping(value = "/users/{id}",method = RequestMethod.GET)
@ResponseBody
public String getById(@PathVariable Integer id){
    System.out.println("user getById ..." + id);
    return "{'module':'user getById'}";
}
```

##### 查询所有

将请求路径更改为`/users`，并设置当前请求方法为`GET`

```java
@RequestMapping(value = "/users",method = RequestMethod.GET)
@ResponseBody
public String getAll(){
    System.out.println("user getAll ...");
    return "{'module':'user getAll'}";
}
```

#### 小结

RESTful入门案例，我们需要记住的内容如下:

1. 设定**Http请求方式**

   ```java
   @RequestMapping(value="",method = RequestMethod.POST|GET|PUT|DELETE)
   ```

2. 设定请求参数(**路径变量**)

   ```java
   @RequestMapping(value="/users/{id}",method = RequestMethod.DELETE)
   @ReponseBody
   public String delete(@PathVariable Integer id){
   }
   ```

知识点：`@PathVariable`

| 名称 |                        @PathVariable                         |
| :--: | :----------------------------------------------------------: |
| 类型 |                           形参注解                           |
| 位置 |               SpringMVC控制器方法形参定义前面                |
| 作用 | 绑定路径参数与处理器方法形参间的关系，要求路径参数名与形参名一一对应 |

关于接收参数，我们学过三个注解`@RequestBody`、`@RequestParam`、`@PathVariable`，这**三个注解之间的区别和应用**分别是什么?

- 区别
  - `@RequestParam`用于接收url地址传参或表单传参
  - `@RequestBody`用于接收JSON数据
  - `@PathVariable`用于接收路径参数，使用{参数名称}描述路径参数
- 应用
  - 后期开发中，发送请求参数超过1个时，以JSON格式为主，`@RequestBody`应用较广
  - 如果发送非JSON格式数据，选用`@RequestParam`接收请求参数
  - 采用`RESTful`进行开发，当参数数量较少时，例如1个，可以采用`@PathVariable`接收请求路径变量，通常用于传递id值

### RESTful风格快速开发

做完了上面的`RESTful`的开发，发现有大量代码冗余，非常麻烦，主要体现在以下三部分：

- 每个方法的`@RequestMapping`注解中都定义了访问路径`/users`，重复性太高。
  - 解决方案：将`@RequestMapping`提到类上面，用来**定义所有方法共同的访问路径**。
- 每个方法的`@RequestMapping`注解中都要使用method属性定义请求方式，重复性太高。
  - 解决方案：使用`@GetMapping`、`@PostMapping`、`@PutMapping`、`@DeleteMapping`代替（**重要**）
- 每个方法响应json都需要加上`@ResponseBody`注解，重复性太高。
  - 解决方案：
    - 将`@ResponseBody`提到类上面，让所有的方法都有`@ResponseBody`的功能
    - 使用`@RestController`注解替换`@Controller`与`@ResponseBody`注解，简化书写

 修改后的RESTful风格代码：

```java
@RestController
@RequestMapping("/users")
public class UserController {
    @PostMapping
    public String save(@RequestBody User user) {
        System.out.println("user save ..." + user);
        return "{'module':'user save'}";
    }

    @DeleteMapping("/{id}/{name}")
    public String delete(@PathVariable("id") Integer userId, @PathVariable String name) {
        System.out.println("user delete ..." + userId + ":" + name);
        return "{'module':'user delete'}";
    }

    @PutMapping()
    public String update(@RequestBody User user) {
        System.out.println("user update ..." + user);
        return "{'module':'user update'}";
    }

    @GetMapping("/{id}")
    public String getById(@PathVariable Integer id) {
        System.out.println("user getById ..." + id);
        return "{'module':'user getById'}";
    }

    @GetMapping
    public String getAll() {
        System.out.println("user getAll ...");
        return "{'module':'user getAll'}";
    }
}
```

