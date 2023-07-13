---
title:
  SpringBoot学习笔记
date:
  2023-03-22 20:49:40
tags:
  java
---

本文摘要：

- 掌握基于SpringBoot框架的程序开发步骤
- 熟练使用SpringBoot配置信息修改服务器配置
- 基于SpringBoot的完成SSM整合项目开发

# SpringBoot简介

SpringBoot是由Pivotal团队提供的全新框架，其设计目的是用来`简化`Spring应用的`初始搭建`以及`开发过程`。

使用了SpringMVC框架后已经简化了我们的开发，而SpringBoot又是对SpringMVC开发进行简化的，可想而知SpringBoot使用的简单及广泛性，这就是所谓的项目迭代吧。

既然SpringBoot是用来简化Spring开发的，那我们就先回顾一下，以SpringMVC开发为例

1. 创建一个maven工程，并在pom.xml中导入所需依赖的坐标

   ```xml
   <dependencies>
       <dependency>
           <groupId>org.springframework</groupId>
           <artifactId>spring-webmvc</artifactId>
           <version>5.2.10.RELEASE</version>
       </dependency>
   
       <dependency>
           <groupId>org.springframework</groupId>
           <artifactId>spring-jdbc</artifactId>
           <version>5.2.10.RELEASE</version>
       </dependency>
   
       <dependency>
           <groupId>org.springframework</groupId>
           <artifactId>spring-test</artifactId>
           <version>5.2.10.RELEASE</version>
       </dependency>
   
       <dependency>
           <groupId>org.mybatis</groupId>
           <artifactId>mybatis</artifactId>
           <version>3.5.6</version>
       </dependency>
   
       <dependency>
           <groupId>org.mybatis</groupId>
           <artifactId>mybatis-spring</artifactId>
           <version>1.3.0</version>
       </dependency>
   
       <dependency>
           <groupId>mysql</groupId>
           <artifactId>mysql-connector-java</artifactId>
           <version>5.1.46</version>
       </dependency>
   
       <dependency>
           <groupId>com.alibaba</groupId>
           <artifactId>druid</artifactId>
           <version>1.1.16</version>
       </dependency>
   
       <dependency>
           <groupId>junit</groupId>
           <artifactId>junit</artifactId>
           <version>4.12</version>
           <scope>test</scope>
       </dependency>
   
       <dependency>
           <groupId>javax.servlet</groupId>
           <artifactId>javax.servlet-api</artifactId>
           <version>3.1.0</version>
           <scope>provided</scope>
       </dependency>
   
       <dependency>
           <groupId>com.fasterxml.jackson.core</groupId>
           <artifactId>jackson-databind</artifactId>
           <version>2.9.0</version>
       </dependency>
   </dependencies>
   ```

2. 编写web3.0的配置类

   ```java
   public class ServletContainersInitConfig extends AbstractAnnotationConfigDispatcherServletInitializer {
       protected Class<?>[] getRootConfigClasses() {
           return new Class[]{SpringConfig.class};
       }
   
       protected Class<?>[] getServletConfigClasses() {
           return new Class[]{SpringMvcConfig.class};
       }
   
       protected String[] getServletMappings() {
           return new String[]{"/"};
       }
   
       @Override
       protected Filter[] getServletFilters() {
           CharacterEncodingFilter filter = new CharacterEncodingFilter();
           filter.setEncoding("utf-8");
           return new Filter[]{filter};
       }
   }
   ```

3. 编写SpringMvc配置类

   ```java
   @Configuration
   @ComponentScan("com.blog.controller")
   @EnableWebMvc
   public class SpringMvcConfig implements WebMvcConfigurer {
   
   }
   ```

4. 编写Controller类

   ```java
   @RestController
   @RequestMapping("/books")
   public class BookController {
       @Autowired
       private BookService bookService;
   
       @PostMapping
       public boolean save(@RequestBody Book book) {
           return bookService.save(book);
       }
   
       @PutMapping
       public boolean update(@RequestBody Book book) {
           return bookService.update(book);
       }
   
       @DeleteMapping("/{id}")
       public boolean delete(@PathVariable Integer id) {
           return bookService.delete(id);
       }
   
       @GetMapping("/{id}")
       public Book getById(@PathVariable Integer id) {
           return bookService.getById(id);
       }
   
       @GetMapping
       public List<Book> getAll() {
           return bookService.getAll();
       }
   }
   ```

从上面的 `SpringMVC` 程序开发可以看到，**前三步都是在搭建环境，而且这三步基本都是固定的**。`SpringBoot` 就是对这三步进行简化了。接下来我们通过一个入门案例来体现 `SpingBoot` 简化 `Spring` 开发。

## SpringBoot快速入门

### 开发步骤

`SpringBoot` 开发起来特别简单，分为如下几步：

- 创建新模块，选择Spring初始化，并配置模块相关基础信息
- 选择当前模块需要使用的技术集
- 开发控制器类
- 运行自动生成的Application类
  知道了 `SpringBoot` 的开发步骤后，下面我们进行具体的操作

`步骤一：`创建新模块
在IDEA下创建一个新模块，选择Spring Initializr，用来创建SpringBoot工程。

注意jdk**版本必须对应**，否则会报错。

[![img](https://pic.imgdb.cn/item/6321bfb816f2c2beb1ec4523.jpg)](https://pic.imgdb.cn/item/6321bfb816f2c2beb1ec4523.jpg)
选中 `Web`，然后勾选 `Spring Web`，由于我们需要开发一个 `web` 程序，使用到了 `SpringMVC` 技术，所以按照下图红框进行勾选
[![img](https://pic.imgdb.cn/item/6321c02316f2c2beb1ecf3f8.jpg)](https://pic.imgdb.cn/item/6321c02316f2c2beb1ecf3f8.jpg)
最后点击创建，就大功告成了，经过以上步骤后就创建了如下结构的模块，它会帮我们自动生成一个 `Application` 类，而该类一会再启动服务器时会用到

注意：

1. 在创建好的工程中不需要创建配置类
2. 创建好的项目会自动生成其他的一些文件，而这些文件目前对我们来说没有任何作用，所以可以将这些文件删除。
3. 可以删除的目录和文件如下：
   - `.mvn`
   - `.gitignore`
   - `HELP.md`
   - `mvnw`
   - `mvnw.cmd`

`步骤二：`创建Controller

注意：IDEA创建项目时会在com.hit下自动生成一个**与项目名同名的包**，其中有SpringBoot核心的**Application类**，因此为了SpringBoot能扫描到你的controller包，需要**将controller包放到该目录下**：

![image-20230322230426331](https://s1.ax1x.com/2023/03/22/ppd5g3t.png)

创建BookController，代码如下

```java
@RestController
@RequestMapping("/books")
public class BookController {
    @GetMapping("/{id}")
    public String getById(@PathVariable Integer id) {
        System.out.println("get id ==> " + id);
        return "hello,spring boot!";
    }
}
```

`步骤三：`启动服务器
运行 `SpringBoot` 工程不需要使用本地的 `Tomcat` 和 插件，只运行项目 `com.hit` 包下的 `Application` 类，我们就可以在控制台看出如下信息

```plaintext
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v2.7.9)

2023-03-22 23:06:52.243  INFO 22508 --- [           main] c.h.s.SpringBootTestApplication          : Starting SpringBootTestApplication using Java 1.8.0_333 on DESKTOP-PIMTV3L with PID 22508 (E:\Java_IDEA\SpringBoot_test\target\classes started by Yoruko in E:\Java_IDEA\SpringBoot_test)
2023-03-22 23:06:52.250  INFO 22508 --- [           main] c.h.s.SpringBootTestApplication          : No active profile set, falling back to 1 default profile: "default"
2023-03-22 23:06:53.205  INFO 22508 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 8080 (http)
2023-03-22 23:06:53.213  INFO 22508 --- [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2023-03-22 23:06:53.213  INFO 22508 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet engine: [Apache Tomcat/9.0.71]
2023-03-22 23:06:53.367  INFO 22508 --- [           main] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2023-03-22 23:06:53.368  INFO 22508 --- [           main] w.s.c.ServletWebServerApplicationContext : Root WebApplicationContext: initialization completed in 993 ms
2023-03-22 23:06:53.697  INFO 22508 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8080 (http) with context path ''
2023-03-22 23:06:53.705  INFO 22508 --- [           main] c.h.s.SpringBootTestApplication          : Started SpringBootTestApplication in 2.095 seconds (JVM running for 2.783)
2023-03-22 23:07:06.874  INFO 22508 --- [nio-8080-exec-2] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring DispatcherServlet 'dispatcherServlet'
2023-03-22 23:07:06.874  INFO 22508 --- [nio-8080-exec-2] o.s.web.servlet.DispatcherServlet        : Initializing Servlet 'dispatcherServlet'
2023-03-22 23:07:06.874  INFO 22508 --- [nio-8080-exec-2] o.s.web.servlet.DispatcherServlet        : Completed initialization in 0 ms
get id ==> 2333
```

测试发现能返回`hello,spring boot!`

SpringBoot太神了！

### SpringBoot访问静态资源

注意：SpringBoot默认配置会访问classpath:/resources/resources目录，但**IDEA自动生成的项目结构只有最上层的classpath:/resources目录**，因此直接在生成的resources根目录或子目录static和templates目录中写静态资源无法访问到！

项目结构实例：

​	![resource.png](https://ucc.alicdn.com/images/user-upload-01/2021011020395564.png)

这个麻烦的问题困扰了半天，最后在[这里](https://developer.aliyun.com/article/886374)才找到答案.
