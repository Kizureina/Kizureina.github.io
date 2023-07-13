---
title: Java Web学习笔记v3
date: 2022-09-28 20:53:14
tags: 
- java
- web
- JavaScript
---

# Java Web

## JDBC

## JDBC驱动连接Mysql数据库8.0

***MySQL 8.0 以上版本的数据库连接有所不同：***

- *1、MySQL 8.0 以上版本驱动包版本 [mysql-connector-java-8.0.16.jar](https://static.runoob.com/download/mysql-connector-java-8.0.16.jar)。*
- *2、**com.mysql.jdbc.Driver** 更换为 **com.mysql.cj.jdbc.Driver**。*
- *MySQL 8.0 以上版本不需要建立 SSL 连接的，需要显示关闭。*
- *allowPublicKeyRetrieval=true 允许客户端从服务器获取公钥。*
- *最后还需要设置 CST。*
- url = "jdbc:mysql:///teaching?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true"

```java
public class jdbcdmo {
    public static void main(String[] args) throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
				// 可省略
        **String url = "jdbc:mysql://127.0.0.1:3306/teaching?useSSL=false&serverTimezone=UTC";**
        // 可简写:String url = "jdbc:mysql:**///**teaching?useSSL=false&serverTimezone=UTC";
				// 注：为三个斜杠
				String username = "root";
        String password = "Hck282018";
        Connection conn = DriverManager.getConnection(url, username, password);

        String sql = "update stu set age = 20 where id = 2;";

        Statement stmt = conn.createStatement();

        int count = stmt.executeUpdate(sql);

        System.out.println(count);
        stmt.close();
        conn.close();

    }
}
```

## JDBC API

### Connection处理事务

```java
public class jdbcdmo {
    public static void main(String[] args) throws Exception {
        // Class.forName("com.mysql.cj.jdbc.Driver");

        String url = "jdbc:mysql:///teaching?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
        String username = "root";
        String password = "Hck282018";
        Connection conn = DriverManager.getConnection(url, username, password);

        String sql1 = "update stu set age = 20 where id = 1";
        String sql2 = "update stu set age = 20 where id = 2";

        Statement stmt = conn.createStatement();

        **try {
            conn.setAutoCommit(false);
            // 开启事务
            int count = stmt.executeUpdate(sql1);
            System.out.println(count);

            int count1 = stmt.executeUpdate(sql2);
            System.out.println(count1);
            conn.commit();
        } catch (Exception e) {
            // 回滚事务
            conn.rollback();
            throw new RuntimeException(e);
        }**

        stmt.close();
        conn.close();

    }
}
```

```java
@Test
    public void testjdbc1() throws SQLException {
        String url = "jdbc:mysql:///teaching?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
        String username = "root";
        String password = "Hck282018";
        Connection conn = DriverManager.getConnection(url, username, password);

        String sql1 = "create database db2";

        Statement stmt = conn.createStatement();

        int count = stmt.executeUpdate(sql1);
        // executeUpdate返回值为修改的行数
        System.out.println(count);
        if (count > 0){
            System.out.println("修改成功！");
        } else {
            System.out.println("修改失败!");
        }

        stmt.close();
        conn.close();

    }
```

### ResultSet执行查询语句

**ResultSet.next()会返回一个布尔值，为是否查询到数据。**

```java
@Test
    public void testjdbc() throws SQLException {
        String url = "jdbc:mysql:///teaching?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
        String username = "root";
        String password = "Hck282018";
        Connection conn = DriverManager.getConnection(url, username, password);

        String sql = "select * from stu";
        // 查询语句
        Statement stmt = conn.createStatement();

        ResultSet rs = stmt.executeQuery(sql);
        // 封装成Set
        while(rs.next()){
            System.out.println(rs.getInt(1));
            System.out.println(rs.getString(2));
						// 也可用System.out.println(rs.getInt("id"));
            // System.out.println(rs.getString("name"));
            System.out.println(rs.getInt(3));
            System.out.println(rs.getString(4));
            System.out.println("======================");
        }
        rs.close();

        stmt.close();
        conn.close();

    }
```

## PreparedStatement

*作用：预编译sql语句，防止sql注入*

```java
@Test
    public void testjdbc2() throws SQLException {
        String url = "jdbc:mysql:///teaching?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
        String username = "root";
        String password = "Hck282018";
        Connection conn = DriverManager.getConnection(url, username, password);

        String name = "mayun";
        String address = "hangzhou";

        String sql = "select * from stu where name = **?** and address = **?**";
				// 不能直接拼接，会造成sql注入风险
        // 查询语句
        PreparedStatement pstmt = conn.prepareStatement(sql);

        **pstmt.setString(1,name);
				// 注意：配置参数为从1开始
        pstmt.setString(2,address);**

        ResultSet rs = pstmt.executeQuery();
        // 执行查询语句，将结果封装成Set
        if (rs.next()){
						// 判断是否查询到数据
            System.out.println("登录成功");
        }else {
            System.out.println("登陆失败！");
        }
        rs.close();

        pstmt.close();
        conn.close();

    }
```

## 数据库连接池

```java
public class druidDemo {
    public static void main(String[] args) throws Exception {
        // 导入jar包
        // 定义配置文件
        // 加载配置
        Properties properties = new Properties();
        properties.load(new FileInputStream("E:\\Java_IDEA\\jdbc\\jdbc-demo\\src\\druid.properties"));
        // 获取连接池对象
        DataSource dataSource = DruidDataSourceFactory.createDataSource(properties);
        // 获取对应的数据库连接
        Connection connection = dataSource.getConnection();
        System.out.println(connection);
    }
}
/*
"C:\Program Files (x86)\Java\jdk1.8.0_333\bin\java.exe" "-javaagent:E:\IntelliJ IDEA 2022.1\lib\idea_rt.jar=54151:E:\IntelliJ IDEA 2022.1\bin" -Dfile.encoding=UTF-8 -classpath "C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\charsets.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\deploy.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\access-bridge-32.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\cldrdata.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\dnsns.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\jaccess.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\jfxrt.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\localedata.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\nashorn.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunec.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunjce_provider.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunmscapi.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\sunpkcs11.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\ext\zipfs.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\javaws.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jce.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jfr.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jfxswt.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\jsse.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\management-agent.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\plugin.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\resources.jar;C:\Program Files (x86)\Java\jdk1.8.0_333\jre\lib\rt.jar;E:\Java_IDEA\jdbc\out\production\jdbc-demo;E:\Java_IDEA\jdbc\jdbc-demo\lib\mysql-connector-java-8.0.16.jar;C:\Users\Yoruko\.m2\repository\org\testng\testng\7.1.0\testng-7.1.0.jar;C:\Users\Yoruko\.m2\repository\com\beust\jcommander\1.72\jcommander-1.72.jar;C:\Users\Yoruko\.m2\repository\com\google\inject\guice\4.1.0\guice-4.1.0-no_aop.jar;C:\Users\Yoruko\.m2\repository\javax\inject\javax.inject\1\javax.inject-1.jar;C:\Users\Yoruko\.m2\repository\aopalliance\aopalliance\1.0\aopalliance-1.0.jar;C:\Users\Yoruko\.m2\repository\com\google\guava\guava\19.0\guava-19.0.jar;C:\Users\Yoruko\.m2\repository\org\yaml\snakeyaml\1.21\snakeyaml-1.21.jar;E:\Java_IDEA\jdbc\jdbc-demo\lib\druid-1.2.9.jar" com.hit.jdbc.druidDemo
十月 03, 2022 6:35:52 下午 com.alibaba.druid.pool.DruidDataSource info
信息: {dataSource-1} inited
com.mysql.cj.jdbc.ConnectionImpl@1be0360

进程已结束,退出代码0
*/
```

## SQL实例

### 查询

```java
public class brandTest {
    /*
    查询所有：select * from tb_brand
    * */
    @Test
    public void testSelectAll() throws Exception {
        Properties properties = new Properties();
        properties.load(new FileInputStream("E:\\Java_IDEA\\jdbc\\jdbc-demo\\src\\druid.properties"));
        // 获取连接池对象
        DataSource dataSource = DruidDataSourceFactory.createDataSource(properties);
        // 获取对应的数据库连接
        Connection connection = dataSource.getConnection();

        String sql = "select * from tb_brand";

        PreparedStatement preparedStatement = connection.prepareStatement(sql);

        ResultSet rs = preparedStatement.executeQuery();

        Brand brand = null;
        List<Brand> brandList = new ArrayList<>();
        while(rs.next()){
            int id = rs.getInt("id");
            String brand_name = rs.getString("brand_name");
            String company_name = rs.getString("company_name");
            int ordered = rs.getInt("ordered");
            String description = rs.getString("description");
            int status = rs.getInt("status");

            brand = new Brand(id, brand_name, company_name, ordered, description, status);
            **brandList.add(brand);**
            System.out.println(brand);

        }
        System.out.println(brandList);

        rs.close();
        preparedStatement.close();
        connection.close();
    }
}
```

### 添加

```java
@Test
    public void testSelectAll() throws Exception {

        String brandName = "香飘飘";
        String companyName = "香飘飘";
        int ordered = 1;
        String description = "绕地球一圈";
        int status = 1;

        Properties properties = new Properties();
        properties.load(new FileInputStream("E:\\Java_IDEA\\jdbc\\jdbc-demo\\src\\druid.properties"));
        // 获取连接池对象
        DataSource dataSource = DruidDataSourceFactory.createDataSource(properties);
        // 获取对应的数据库连接
        Connection connection = dataSource.getConnection();

        String sql = "insert into tb_brand(brand_name, company_name, ordered, description, status) values(?,?,?,?,?)";

        PreparedStatement preparedStatement = connection.prepareStatement(sql);

        preparedStatement.setString(1,brandName);
        preparedStatement.setString(2,companyName);
        preparedStatement.setInt(3,ordered);
        preparedStatement.setString(4,description);
        preparedStatement.setInt(5,status);

        int count = preparedStatement.executeUpdate();

        System.out.println(count > 0);

        /*释放资源*/
        preparedStatement.close();
        connection.close();
    }
```

### 修改

```java
@Test
    public void testUpdate() throws Exception {

        String brandName = "香飘飘";
        String companyName = "香飘飘";
        int ordered = 1;
        String description = "销量不好";
        int status = 1;
        int id = 3;

        Properties properties = new Properties();
        properties.load(new FileInputStream("E:\\Java_IDEA\\jdbc\\jdbc-demo\\src\\druid.properties"));
        // 获取连接池对象
        DataSource dataSource = DruidDataSourceFactory.createDataSource(properties);
        // 获取对应的数据库连接
        Connection connection = dataSource.getConnection();

        **String sql = "update tb_brand " +
                "set brand_name = ?," +
                " company_name = ?," +
                " ordered = ?," +
                " description = ?," +
                " status = ? " +
                "where id = ?";
				// 注意换行时要保持字符串不变**

        PreparedStatement preparedStatement = connection.prepareStatement(sql);

        preparedStatement.setString(1,brandName);
        preparedStatement.setString(2,companyName);
        preparedStatement.setInt(3,ordered);
        preparedStatement.setString(4,description);
        preparedStatement.setInt(5,status);
        preparedStatement.setInt(6,id);

        int count = preparedStatement.executeUpdate();

        System.out.println(count > 0);

        /*释放资源*/
        preparedStatement.close();
        connection.close();
    }
```

### 删除

```java
@Test
    public void testDelete() throws Exception {

        int id = 3;

        Properties properties = new Properties();
        properties.load(new FileInputStream("E:\\Java_IDEA\\jdbc\\jdbc-demo\\src\\druid.properties"));
        // 获取连接池对象
        DataSource dataSource = DruidDataSourceFactory.createDataSource(properties);
        // 获取对应的数据库连接
        Connection connection = dataSource.getConnection();

        String sql = "DELETE FROM tb_brand WHERE id = ?";

        PreparedStatement preparedStatement = connection.prepareStatement(sql);

        preparedStatement.setInt(1,id);

        int count = preparedStatement.executeUpdate();

        System.out.println(count > 0);

        /*释放资源*/
        preparedStatement.close();
        connection.close();
    }
```

## Maven

**是一套专门用于管理和构建Java项目的工具**

**Maven还提供了一套标准化的构建流程和依赖管理。**

可以非常方便的打包构建项目与导入jar包。

### Maven坐标

```xml
<groupId>org.example</groupId>
    <artifactId>maven-demo</artifactId>
    <version>1.0-SNAPSHOT</version>
```

### IDEA导入Maven项目

### Maven依赖管理

```xml
<dependencies>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.30</version>
        </dependency>
    </dependencies>
```

引入依赖需要刷新，才能在远程库下载。

# MyBatis

*持久层框架，用于简化JDBC开发。*

持久层：保存到数据库的操作代码

**JavaEE开发：表现层，业务层，持久层**

使用流程：

```java
public class MybatisDemo {
    public static void main(String[] args) throws Exception{
        //1.加载核心类文件,获取SqlSessionFactory对象
        String resource = "mybatis-config.xml";
        InputStream inputStream = Resources.getResourceAsStream(resource);
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);

        //2.获取工厂对象，以执行sql语句
        SqlSession sqlSession = sqlSessionFactory.openSession();

        List<Brand> brandList = sqlSession.selectList("**test.selectAll**");
				//用命名空间确定唯一的sql语句
        System.out.println(brandList);
    }
}
/*
[Brand{id=1, brandName='null', companyName='null', ordered=1, description='销量不好', status=1}, Brand{id=2, brandName='null', companyName='null', ordered=500, description='are you ok', status=0}, Brand{id=4, brandName='null', companyName='null', ordered=1, description='绕地球一圈', status=1}]
*/
```

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "https://mybatis.org/dtd/mybatis-3-mapper.dtd">
<!--
namespace
-->
<mapper namespace="test">
    <select id="selectAll" resultType="com.itheima.Brand">
        select * from tb_brand;
    </select>
</mapper>
```

### 注意：MyBatis返回的对象中实体类对应属性名必须与数据库字段名完全相同：

```java
public class Brand {
    private  int id;
    private String brand_Name;
    private String company_Name;
    private int ordered;
    private String  description;
    private int status;
}
```

*也可用ResultMap定义结果映射:*

```xml
<resultMap id="brandResultMap" type="com.hit.pojo.Brand">
        **<result column="brand_name" property="brand_Name"/>
        <result column="company_name" property="company_Name"/>**
</resultMap>
<select id="selectAll" resultMap="brandResultMap">
        select *
        from tb_brand;
</select>
```

## Mapper代理开发

### 注意：必须放在同一文件包内，UserMapper.java与UserMapper.xml，且命名空间要写对路径。

**下图为同一路径，另外在resource文件中不能建立软件包，只能用com/itheima/mapper方式建立文件夹结构间接建立包目录。**

```xml
<mapper namespace="**com.itheima.mapper.UserMapper**">
    <select id="selectAll" resultType="com.itheima.Brand">
        select * from tb_brand;
    </select>
</mapper>
```

UserMapper.java

```java
package com.itheima.mapper;

import com.itheima.Brand;

import java.util.List;

/**
 * @author Yoruko
 */
public interface UserMapper {
    List<Brand> selectAll();
}
```

主程序：

```java
public class MybatisDemo2 {
    public static void main(String[] args) throws Exception{
        //1.加载核心类文件,获取SqlSessionFactory对象
        String resource = "mybatis-config.xml";
        InputStream inputStream = Resources.getResourceAsStream(resource);
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);

        //2.获取工厂对象，以执行sql语句
        SqlSession sqlSession = sqlSessionFactory.openSession();

        **UserMapper userMapper = sqlSession.getMapper(UserMapper.class);
        // 获取代理对象
        List<Brand> brands = userMapper.selectAll();**

        System.out.println(brands);
        // List<Brand> brandList = sqlSession.selectList("test.selectAll");
        sqlSession.close();
    }
}
```

### MyBatisX插件无法识别：

```xml
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
```

改成上面这行就ok。

## MyBatis执行流程：

1. 编写接口方法
2. 编写sql
3. 执行

### MyBatis占位符

需要用#{} 否则会有sql注入风险。

```xml
<select id="searchById" resultMap="brandResultMap">
    select *
    from tb_brand where id = **#{id}**;
</select>
```

### 特殊字符处理：

可用**转义字符和CDATA**。

```xml
<select id="searchById" resultMap="brandResultMap">
        select * from tb_brand 
				<![CDATA[
				 <
				]]>
				10;
</select>

```

## MyBatis条件查询

```java
@Test
   public void selectByCondition() throws IOException {
      int status = 1;
      String companyName = "华为";
      String brandName = "华为";

      //模糊处理参数
      companyName = "%" + companyName + "%";

      // 封装对象
//      Brand brand = new Brand();
//      brand.setStatus(status);
//      brand.setBrand_Name(brandName);
//      brand.setCompany_Name(companyName);
      Map map = new HashMap();
      map.put("status",status);
      map.put("company_Name",companyName);
      map.put("brand_Name",brandName);

      // 获取sql工厂对象
      String  resource = "mybatis-config.xml";
      InputStream inputStream = Resources.getResourceAsStream(resource);
      SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);

      //2.获取SqlSession对象
      SqlSession sqlSession = sqlSessionFactory.openSession();

      //3.Mapper接口代理对象
      UserMapper userMapper = sqlSession.getMapper(UserMapper.class);

      //4.执行方法
//      List<Brand> brands = userMapper.selectByCondition(status, companyName, brandName);
//      List<Brand> brands = userMapper.selectByCondition(brand);
      List<Brand> brands = userMapper.selectByCondition(map);
      System.out.println(brands);

      sqlSession.close();

   }
```

映射：

```xml
<select id="selectByCondition" resultMap="brandResultMap">
    select *
    from tb_brand
    where status = #{status}
    and company_name like #{company_Name}
    and brand_name like #{brand_Name};
</select>
```

```java
public interface UserMapper
{
    List<Brand> selectAll();

    Brand searchById(int id);

    /*
    方法中有多个参数，**需要用@Param("SQL占位符名称")***/
    
    List<Brand> selectByCondition(@Param("status")int status, @Param("company_Name")String company_Name, @Param("brand_Name")String brand_name);

//    List<Brand> selectByCondition(Brand brand);
//
  //  List<Brand> selectByCondition(Map map);

}
```

## 动态查询

*会随外部输入而变化的查询*

```xml
<select id="selectByCondition" resultMap="brandResultMap">
    select *
    from tb_brand
    where
    <if test="status != null">
        status = #{status}
    </if>
    #           **此处判断的变量为取到值的实体类中变量名，非sql字段名**
    <if test="company_Name != null and company_Name != ''">
        and company_name like #{company_Name}
    </if>
    <if test="brand_Name != null and brand_Name != ''">
        and brand_name like #{brand_Name};
    </if>
</select>
```

此时三个参数可不全传参，都可完全查询。

```xml
<select id="selectByCondition" resultMap="brandResultMap">
    select *
    from tb_brand
    **where 1=1**
    <if test="status != null">
        and status = #{status}
    </if>
    #           此处判断的变量为取到值的实体类中变量名，非sql字段名
    <if test="company_Name != null and company_Name != ''">
        and company_name like #{company_Name}
    </if>
    <if test="brand_Name != null and brand_Name != ''">
        and brand_name like #{brand_Name};
    </if>
</select>
```

上面写法好看点。

也可用**MyBatis关键字<Where>**（最好用的办法）：

```xml
<select id="selectByCondition" resultMap="brandResultMap">
        select *
        from tb_brand

        **<where>
            <if test="status != null">
                and status = #{status}
            </if>
            #           此处判断的变量为取到值的实体类中变量名，非sql字段名
            <if test="company_Name != null and company_Name != ''">
                and company_name like #{company_Name}
            </if>
            <if test="brand_Name != null and brand_Name != ''">
                and brand_name like #{brand_Name};
            </if>
        </where>**
    </select>
```

```xml
<select id="selectByConditionSingle" resultMap="brandResultMap">
    select *
    from tb_brand
    where
        <choose>
            <when test="status!=null">
                status = #{status}
            </when>
            <when test="brand_Name != null and brand_Name != ''">
                brand_name like #{brand_Name};
             </when>
            <when test="company_Name != null and company_Name != ''">
                company_name like #{company_Name}
            </when>
						<otherwise>
                1=1
            </otherwise>
        </choose>
</select>
```

也可用Where标签：

```xml
<select id="selectByConditionSingle" resultMap="brandResultMap">
    select *
    from tb_brand
    <where>
        <choose>
            <when test="status!=null">
                status = #{status}
            </when>
            <when test="brand_Name != null and brand_Name != ''">
                brand_name like #{brand_Name};
            </when>
            <when test="company_Name != null and company_Name != ''">
                company_name like #{company_Name}
            </when>

        </choose>
    </where>
</select>
```

## 添加字段

```java
@Test
   public void add() throws IOException {
      int status = 1;
      String companyName = "波导手机";
      String brandName = "波导";
      String description = "好手机";
      int ordered = 100;

      //模糊处理参数
      companyName = "%" + companyName + "%";

      // 封装对象
      Brand brand = new Brand();
      brand.setStatus(status);
      brand.setBrand_Name(brandName);
      brand.setCompany_Name(companyName);
      brand.setDescription(description);
      brand.setOrdered(ordered);

//      Map map = new HashMap();
//      map.put("status",status);
//      map.put("company_Name",companyName);
////      map.put("brand_Name",brandName);

      // 获取sql工厂对象
      String  resource = "mybatis-config.xml";
      InputStream inputStream = Resources.getResourceAsStream(resource);
      SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);

      //2.获取SqlSession对象
      SqlSession sqlSession = sqlSessionFactory.openSession();

      //3.Mapper接口代理对象
      UserMapper userMapper = sqlSession.getMapper(UserMapper.class);

      //4.执行方法
      userMapper.add(brand);
			// 5. 提交事务
      **sqlSession.commit();**

      sqlSession.close();
```

映射文件

```xml
<insert id="add">
    insert into tb_brand (**brand_name, company_name, ordered, description, status**)
    values (#{brand_Name},#{company_Name},#{ordered},#{description},#{status} )
</insert>
```

### 主键返回

```xml
<insert id="add" useGeneratedKeys="true" keyProperty="id">
```

## 修改字段

```xml
<update id="update">
    update tb_brand
    set
        brand_name = #{brand_Name},
        company_name = #{company_Name},
        ordered = #{ordered},
        description = #{description},
        status = #{status}
    where id = #{id}
</update>
```

### 修改动态字段

相当于update加if标签:

**用set标签可避免最后一个字段没有参数导致逗号出现在最后，造成语法错误**

### 删除字段

```xml
<delete id="deleteById">
      delete from tb_brand where id = #{id}
</delete>
```

```xml
<delete id="deleteByIds">
    delete
    from tb_brand
    where id
    in (
        **<foreach collection="array" item="id" separator="," open="(" close=")">**
            #{id}
        </foreach>
              );
</delete>
```

```xml
<foreach collection="array" item="id" separator="," open="(" close=")">
```

此句拼接sql参数，默认接收数组参数为array，可用注解改变。

separator分割不同数组，open和close拼接语句首尾。

## MyBatis参数传递

# Web核心

## Tomcat

使用骨架会谜之报错，貌似是[这个原因](https://blog.csdn.net/hys_wxy/article/details/109855966)。

IDEA集成本地Tomcat比较麻烦，但健壮性好于用tomcat maven插件。

**注：在配置tomcat部署前需要用maven run package打包生成snap.war文件**

## Servlet

### 开发流程

**使用插件要注意端口不能被占用**

```java
package com.hit.web;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;

/**
 * @author Yoruko
 */
@WebServlet("/demo1")
public class ServletDemo1 implements Servlet {
    @Override
    public void service(ServletRequest servletRequest, ServletResponse servletResponse) throws ServletException, IOException {
        System.out.println("hello world!");
    }

    @Override
    public String getServletInfo() {
        return null;
    }

    @Override
    public void destroy() {

    }

    @Override
    public void init(ServletConfig servletConfig) throws ServletException {

    }

    @Override
    public ServletConfig getServletConfig() {
        return null;
    }
}
```

Servlet由web服务器创建和调用方法

destroy方法在销毁时执行：

### HttpServlet

```java
@WebServlet("/demo4")
public class ServletDemo4 extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("get...");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("post....");
    }
}
```

### xml配置servlet：

```xml
<!--    servlet全类名-->
    <servlet>
        <servlet-name>demo6</servlet-name>
        <servlet-class>com.hit.web.ServletDemo6</servlet-class>
    </servlet>

<!--访问路径-->
    <servlet-mapping>
        <servlet-name>demo6</servlet-name>
        <url-pattern>/demo6</url-pattern>
    </servlet-mapping>
```

远不如注解方便。

## Request与Response

### getInputSteam()可获取字节输入流，可用于文件上传。

```java
@Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("post....");
        // 1. 获取字符输入流
        BufferedReader br = req.getReader();
        // 2. 读取数据
        String line = br.readLine();
        System.out.println(line);
        //无需关闭流，会由req自动关闭
    }
}
```

### Request通用获取请求参数

```java
@WebServlet("/demo7")
public class ServletDemo7 extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("get.......");

        Map<String, String[]> map = req.getParameterMap();
        for (String key : map.keySet()) {
            System.out.print(key + ":");

            String[] values = map.get(key);
            for (String value : values) {
                System.out.print(value + " ");
            }
            System.out.println();

        }
        System.out.println("==================");
        // 2. 根据key获取参数数组
        String[] hobbies = req.getParameterValues("hobby");
        for (String hobby : hobbies) {
            System.out.println(hobby);
        }

        // 3. **根据key获取单个参数值(最常用)**
        String username = req.getParameter("username");
        System.out.println(username);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        this.doGet(req, resp);
    }
}
```

## 请求中文乱码

Get和Post都存在中文乱码问题。

post用

```java
request.setCharacterEncoding("UTF-8");
```

即可。

GET乱码原因：

```java
@WebServlet("/req")
public class ServletDemo extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
				//1. 乱码数据转为字节数组
        byte[] bytes = username.getBytes(StandardCharsets.ISO_8859_1);
				//2. 字节数组解码成正常数据
        String s = new String(**bytes, StandardCharsets.UTF_8**);
        System.out.println(s);

    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doGet(request, response);
    }
}
```

## Request请求转发

请求转发：在服务器内部实现资源跳转。

```java
request.getRequestDispatcher("/demo7").forward(request,response);
```

**可实现流水线数据处理**

## Response对象

### 重定向

```java
@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        System.out.println("demo1.....");

        **response.setStatus(302);
        response.setHeader("Location", "/resp2");**
    }
```

也可简化：

```java
response.sendRedirect("/resp2");
```

重定向为两次请求，可重定向至外部资源。

## Response响应字符字节数据

```java
@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 获取字符输出流
        response.setHeader("content-type", "text/html");
        PrintWriter writer = response.getWriter();
        writer.write("aaaa");
        System.out.println("aaa");
        writer.write("<h1>aaaa</h1>");
				// 无需关闭输出流
    }
```

解决中文乱码：

```java
@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=utf-8");
        PrintWriter writer = response.getWriter();
        writer.write("aaaa");
        System.out.println("aaa");
        writer.write("<h1>你好</h1>");
    }
```

字节输出流：

```java
public class ResponseDemo4 extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1.读取文件获取字节输入流
        FileInputStream fileInputStream = new FileInputStream("C:\\Users\\Yoruko\\Pictures\\Saved Pictures\\ACG\\4.png");
        // 2.获取字节输出流
        ServletOutputStream outputStream = response.getOutputStream();
        // 3. copy流
//        byte[] buffer = new byte[1024];
//        int len = 0;
//        while((len = fileInputStream.read(buffer)) != -1){
//            outputStream.write(buffer, 0, len);
//        }
        IOUtils.copy(fileInputStream, outputStream);
				//工具类简化copy输入流与输出流的过程。

        fileInputStream.close();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doGet(request, response);
    }
}
```

## 案例

### 注册

### SqlSessionFactory优化

```java
String resource = "mybatis-config.xml";
InputStream is = Resources.getResourceAsStream(resource);
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(is);
```

上面获取sqlSessionFactory对象的代码重复多次，可用静态代码块优化。

写个工具类：

```java
public class SqlSessionFactoryUtils {
    private static SqlSessionFactory sqlSessionFactory;
		// 提升作用域
    static {
        try {
            **String resource = "mybatis-config.xml";
            InputStream is = Resources.getResourceAsStream(resource);
            sqlSessionFactory = new SqlSessionFactoryBuilder().build(is);
						// 赋值而非初始化，作用域为整个方法**
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
		
    public static SqlSessionFactory getSqlSessionFactory(){
        return sqlSessionFactory;
    }
}
```

再调用该工具类即可。

## JSP

```html
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>
<body>
    <h1>Hello jsp</h1>
    <%
        System.out.println("Hello jsp!!");
    %>
</body>
</html>
```

JSP本质是一个servlet，由tomcat封装调用。

## MVC入门 三层架构

**Model-View-Controller**

jsp内标签名与数据字段名不同时需用ResultMap映射：

## 会话追踪技术

原因：HTTP请求是无状态的。

实现方式：

1. 客户端：Cookie
2. 服务端：Session

### Cookie

```java
@WebServlet("/aservlet")
public class aservlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 发送cookie
        // 创建
        Cookie cookie = new Cookie("username","zs");
        // 发送
        response.addCookie(cookie);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doGet(request, response);
    }
}
```

接受cookie：

```java
@WebServlet("/BServlet")
public class BServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Cookie[] cookies = request.getCookies();
				// 只能获取所有cookie，因此需要遍历取值
        for (Cookie cookie : cookies) {
            String name = cookie.getName();
            if ("username".equals(name)){
                String value = cookie.getValue();
                System.out.println(name + ":" + value);
                break;
            }

        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doGet(request, response);
    }
}
```

注： **request.getCookies()只能获取浏览器所有cookie，因此需要遍历寻值。**

### Seesion

实际基于cookie。

```java
HttpSession session = request.getSession();
session.setAttribute("username","zs");
```

获取：

```java
//从session中获取对象
HttpSession session = request.getSession();

Object username = session.getAttribute("username");
System.out.println(username);
```

## cookie与session区别

cookie不安全，session安全。

cookie可长期存储，但session默认30分钟销毁。

cookie最大3kb，session无限制。

**cookie多存储长期数据，session保存登陆后的临时数据**

## Filter——JavaWeb三大组件之二

入门：

1. 定义Filter类，实现接口方法
2. 配置拦截器路径，加@WebFilter注解（”\*”过滤所有）
3. 在doFilter方法内执行逻辑和放行

```java
public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        System.out.println("FilterDemo....");
        //放行
        **filterChain.doFilter(servletRequest,servletResponse);**
    }
```

### 执行流程：

放行前的代码 ⇒ 过滤的页面显示 ⇒ 放行后逻辑

一般流程为：放行前对request进行处理，放行后对response做处理。

注：过滤器只能拦截**资源。**

### 过滤器链

*注意：需要无条件放行与登录相关的资源文件*

```java
@WebFilter("/*")
public class LoginFilter implements Filter {
    public void init(FilterConfig config) throws ServletException {
    }

    public void destroy() {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws ServletException, IOException {
        HttpSession session = ((HttpServletRequest) request).getSession();
        Object user = session.getAttribute("user");

        if (user != null){
            chain.doFilter(request, response);
        }else {
            request.setAttribute("login_msg","您尚未登录！");
            request.getRequestDispatcher("index.html").forward(request,response);
        }
    }
}
```

### Listener

监听服务器变化并调用相关方法。

## AJAX

前端

```jsx
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<script>
    // 1.创建核心对象
    var xhttp;
    if (window.XMLHttpRequest) {
        xhttp = new XMLHttpRequest();
    } else {
        // code for IE6, IE5
        xhttp = new ActiveXObject("Microsoft.XMLHTTP");
    }
    // 2.向服务器发送请求
    xhttp.open("GET","http://localhost/ajax");
    xhttp.send();

    // 3. 获取服务器响应数据
    xhttp.onreadystatechange = function() {
        if (this.readyState === 4 && this.status === 200) {
            alert(this.responseText);
        }
    };
</script>
</body>
</html>
```

后端

```java
@WebServlet("/ajax")
public class AjaxServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.getWriter().write("hello ajax!!");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doGet(request, response);
    }
}

```

实例

```jsx
<script>
    function inputonblur(e) {
        let username = e;
        // 发送Ajax请求
        var xhttp;
        if (window.XMLHttpRequest) {
            xhttp = new XMLHttpRequest();
        } else {
            // code for IE6, IE5
            xhttp = new ActiveXObject("Microsoft.XMLHTTP");
        }
        // 2.向服务器发送请求
        xhttp.open("GET","http://localhost/selectUserServlet?username=" + username);
        xhttp.send();

        // 3. 获取服务器响应数据
        xhttp.onreadystatechange = function() {
            if (this.readyState === 4 && this.status === 200) {
                // alert(this.responseText);
                if(this.responseText === "true"){
                    //显示提示信息
                    document.getElementById("username_err").style.display = '';
                }else{
                    // 清除提示信息
                    document.getElementById("username_err").style.display = 'none';

                }
            }
        };
    }
</script>
```

## Axios

简化Ajax代码

```jsx
<script>
    axios({
        method : "GET",
        url : "http://localhost/axios",
        data : "username=zhangsan"
    }).then(function (resq){
        alert(resq.data);
    })
</script>
```

```java
public class AxiosServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        System.out.println(username);

        response.getWriter().write("hello axios!!");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doGet(request, response);
    }
}
```

## JSON

用于数据传输，可存储对象数据。

### Fastjson

```java
import com.alibaba.fastjson.JSON;

public class JsonTest {
    public static void main(String[] args) {
        User user = new User();
        user.setId(1);
        user.setUsername("zhangsan");
        user.setPassword("123");

        String s = JSON.**toJSONString(user);**
        System.out.println(s);
        // {"id":1,"password":"123","username":"zhangsan"}

        User user1 = JSON.**parseObject**("{\"id\":1,\"password\":\"123\",\"username\":\"zhangsan\"}", User.class);
        System.out.println(user1);

    }
}
```

### 实例：json与axios代替jsp

Brand.html

```jsx
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<a href="addBrand.html"><input type="button" value="新增"></a><br>
<hr>
<table id="brandTable" border="1" cellpadding="0" width="100%">
<!--    <tr>-->
<!--        <th>序号</th>-->
<!--        <th>产品名称</th>-->
<!--        <th>企业</th>-->
<!--        <th>排序</th>-->
<!--        <th>介绍</th>-->
<!--        <th>状态</th>-->
<!--        <th>操作</th>-->
<!--    </tr>-->
<!--    <tr align="center">-->
<!--        <td>1</td>-->
<!--        <td>1</td>-->
<!--        <td>1</td>-->
<!--        <td>1</td>-->
<!--        <td>1</td>-->
<!--        <td>1</td>-->
<!--        <td>1</td>-->

<!--    </tr>-->
</table>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
<script>
    **window.onload = function()**{
			//1.页面加载完成后调用函数
        
        axios({
						//2.发送ajax请求
            method:"get",
            url:"http://localhost/selectAllServlet1"
        }).then(function (resp){
            let data = resp.data;

            let tabledata = "<tr>\n" +
                "        <th>序号</th>\n" +
                "        <th>产品名称</th>\n" +
                "        <th>企业</th>\n" +
                "        <th>排序</th>\n" +
                "        <th>介绍</th>\n" +
                "        <th>状态</th>\n" +
                "        <th>操作</th>\n" +
                "    </tr>";

            for (let i = 0; i < data.length; i++) {
                let brand = data[i];
                tabledata += "<tr align=\"center\">\n" +
                    "        <td>" + (i+1) + "</td>\n" +
                    "        <td>" + brand.brand_Name +"</td>\n" +
                    "        <td>" + brand.company_Name +"</td>\n" +
                    "        <td>" + brand.ordered +"</td>\n" +
                    "        <td>" + brand.description +"</td>\n" +
                    "        <td>" + brand.status +"</td>\n" +
                    "\n" +
                    "        <td><a href=\"#\">修改</a> <a href=\"#\">删除</a></td>\n" +
                    "    </tr>";
            }

            //设置表格数据
            document.getElementById("brandTable").innerHTML = tabledata;

        })
    }
   
</script>
</body>
</html>
```

后端Servlet生成数据

```java
@WebServlet("/selectAllServlet1")
public class SelectAllServlet extends HttpServlet {
    private final BrandService brandService = new BrandService();
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 调用Service层代码完成查询
        List<Brand> brands = brandService.selectAll();
       // 封装成json
        String s = JSON.toJSONString(brands);

        **response.setContentType("text/json;charset=utf-8");
				//有中文数据需要设置utf-8编码
        response.getWriter().write(s);**
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doGet(request, response);
    }
}
```
