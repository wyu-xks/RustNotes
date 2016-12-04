---
title: mybatis 快速入门 - 查表
date: 2017-04-06 19:58:09
category: Database
tag: [Java, mybatis]
toc: true
---

* win7_x64
* MySQL
* IntelliJ IDEA 

## mybatis简介
MyBatis是一个支持普通SQL查询，存储过程和高级映射的优秀持久层框架。MyBatis消除
了几乎所有的JDBC代码和参数的手工设置以及对结果集的检索封装。MyBatis可以使用简
单的XML或注解用于配置和原始映射，将接口和Java的POJO
（Plain Old Java Objects，普通的Java对象）映射成数据库中的记录。

参见 http://www.mybatis.org/mybatis-3/zh/index.html

## Java Application 中使用 mybatis
### 创建工程
新建一个普通Java工程，以下为主要文件
```
MybatisDemo/
|-- libs
|   |-- mybatis-3.2.1.jar
|   `-- mysql-connector-java-5.1.7-bin.jar
`-- src
    |-- com
    |   `-- rustfisher
    |       |-- Demo.java
    |       |-- mapping // 映射文件
    |       |   |-- bigstu_mapper.xml
    |       |   `-- small_table_mapper.xml
    |       `-- pojo
    |           |-- SmallUser.java
    |           `-- User.java
    `-- res
        `-- conf.xml  // 配置文件
```

#### 添加相应的jar包
需要2个jar包。可以手动将这两个包添加到工程的依赖里。
```
mybatis-3.2.1.jar
mysql-connector-java-5.1.7-bin.jar
```

#### 准备数据库
这里使用的是以前建立好的本地的MySQL数据库`localhost:3306/samp_db1`，数据库中有2张表  
可参见： http://rustfisher.github.io/2017/02/25/backend/MySQL_manipulate/  

表 `bigstu` 结构如下
```
+----+------+-----+-----+----------+-------------+---------+
| id | name | sex | age | birthday | tell        | address |
+----+------+-----+-----+----------+-------------+---------+
......
+----+------+-----+-----+----------+-------------+---------+
```

表 `small_table` 结构如下
```
+----+------+
| id | name |
+----+------+
......
+----+------+
```

### 使用xml中的SQL语句查询数据库中的数据
#### 准备mybatis的配置文件conf.xml
`conf.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN" "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <environments default="development">
        <environment id="development">
            <transactionManager type="JDBC"/>
            <!-- 配置数据库连接信息 -->
            <dataSource type="POOLED">
                <property name="driver" value="com.mysql.jdbc.Driver"/>
                <property name="url" value="jdbc:mysql://localhost:3306/samp_db1"/>
                <property name="username" value="root"/>
                <property name="password" value="a123"/>
            </dataSource>
        </environment>
    </environments>
    <mappers>
        <!-- 注册mapper文件 -->
        <mapper resource="com/rustfisher/mapping/bigstu_mapper.xml"/>
        <mapper resource="com/rustfisher/mapping/small_table_mapper.xml"/>
    </mappers>
</configuration>
```
连接的数据库是`samp_db1`  
注册2个mapper文件，对应数据库中的两张表。这两个文件在下文会提到。

#### 定义模型类 POJO
这里有2个POJO
```java
/**
 * POJO
 * Created by Rust on 2017/4/6.
 */
public final class User {
    private int id;
    private String name;
    private String sex;
    private int age;
    private Date birthday;
    private String mobile;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public int getAge() {
        return age;
    }

    public void setAge(int age) {
        this.age = age;
    }

    public Date getBirthday() {
        return birthday;
    }

    public String getBirthDayStr() {
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
        return simpleDateFormat.format(birthday);
    }

    public void setBirthday(Date birthday) {
        this.birthday = birthday;
    }

    public String getMobile() {
        return mobile;
    }

    public void setMobile(String mobile) {
        this.mobile = mobile;
    }

    @Override
    public String toString() {
        return buildStr(getId(), getName(), getSex(), getAge(), getBirthDayStr(), getMobile());
    }

    private String buildStr(Object... inputs) {
        StringBuilder sb = new StringBuilder();
        for (Object s : inputs) {
            sb.append(s).append(" ");
        }
        return sb.toString();
    }
}

public class SmallUser {
    private int id;
    private String name;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @Override
    public String toString() {
        return id + " " + name;
    }
}
```

#### 定义SQL映射文件
`bigstu_mapper.xml` 这里的namespace定义成了文件的路径
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.rustfisher.mapping.bigstu_mapper">

    <!-- 根据id查询得到一个user对象 -->
    <select id="getUserById" parameterType="int" resultType="com.rustfisher.pojo.User">
        select * from bigstu where id=#{id}
    </select>

    <select id="getAllUser" resultType="com.rustfisher.pojo.User"> select * from bigstu </select>
</mapper>
```
定义了2个查询方法，均对应User类


`small_table_mapper.xml` 
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.rustfisher.mapping.small_table_mapper">

    <select id="getAllUser" resultType="com.rustfisher.pojo.SmallUser"> select * from small_table </select>
</mapper>
```

#### 测试代码

```java
public class Demo {
    public static void main(String[] args) throws IOException {
        String resource = "res/conf.xml";//mybatis的配置文件

        //使用类加载器加载mybatis的配置文件（它也加载关联的映射文件）
        InputStream is = Demo.class.getClassLoader().getResourceAsStream(resource);
        SqlSessionFactory sessionFactory = new SqlSessionFactoryBuilder().build(is);

        // 添加Java定义的mapper
        //sessionFactory.getConfiguration().addMapper(IUserMapper.class);

        SqlSession session = sessionFactory.openSession();

        //testMapper(session);

        testXMLFunction(session);

        session.close();
    }

    private static void testMapper(SqlSession session) {
        IUserMapper mapper = session.getMapper(IUserMapper.class);
        User user1 = mapper.selectUserById(1);
        System.out.println("\n------- testMapper --------");
        System.out.println(user1);
        System.out.println("------- testMapper getAllUser--------");
        List bigUserList = mapper.getAllUser();
        printList(bigUserList);
    }

    private static void testXMLFunction(SqlSession session) {
        String bigSelectOneCMD = "com.rustfisher.mapping.bigstu_mapper.getUserById"; // 映射sql的标识字符串
        String bigSelectAllUserCMD = "com.rustfisher.mapping.bigstu_mapper.getAllUser";
        //执行查询返回一个唯一user对象的sql
        User user = session.selectOne(bigSelectOneCMD, 5);
        List allUsers = session.selectList(bigSelectAllUserCMD);
        List smallAllUsers = session.selectList("com.rustfisher.mapping.small_table_mapper.getAllUser");
        System.out.println(user);
        System.out.println("\n------- big stu -------");
        printList(allUsers);
        System.out.println("\n------ small table ------");
        printList(smallAllUsers);
    }

    private static void printList(List list) {
        for (Object obj : list) {
            System.out.println(obj.toString());
        }
    }
}

```

输出
```
5 王五 男 22 2017-03-13 666666666 

------- big stu -------
1 张三 男 24 2017-03-29 13666665555 
2 李四 女 21 2017-03-06 13900001111 
4 小强 男 22 1994-06-29 336699111 
5 王五 男 22 2017-03-13 666666666 
6 小刚 男 23 2017-03-11 778899888 
8 小霞 女 20 2017-03-13 13712345678 
12 小智 男 21 2017-03-07 13787654321 

------ small table ------
1 Tom
2 Jerry
```

至此，可以使用xml中的语句来查询数据

### 使用Java代码编写Mapper文件
以上文工程为例，使用注解的形式，添加一个接口
```java
/**
 * DAO
 */
public interface IUserMapper {
    String TABLE_BIG = "bigstu"; // 需要查询的表

    @Select("select * from " + TABLE_BIG + " where id = #{id}")
    User selectUserById(int id);

    @Select("select * from " + TABLE_BIG)
    List<User> getAllUser();
}
```

在加载mybatis时将自定义的mapper类添加进去
```java
sessionFactory.getConfiguration().addMapper(IUserMapper.class);
```

测试新添加的代码
```java
    IUserMapper mapper = session.getMapper(IUserMapper.class);
    User user1 = mapper.selectUserById(1); // 根据id查询用户
    System.out.println("\n------- testMapper --------");
    System.out.println(user1);
    System.out.println("------- testMapper getAllUser--------");
    List bigUserList = mapper.getAllUser(); // 获取所有用户
    printList(bigUserList);
```

## 简易封装mybatis
使用了spring框架，在maven中添加
```xml
    <dependency>
        <groupId>org.mybatis</groupId>
        <artifactId>mybatis</artifactId>
        <version>3.2.8</version>
    </dependency>

    <dependency>
        <groupId>mysql</groupId>
        <artifactId>mysql-connector-java</artifactId>
        <version>6.0.6</version>
    </dependency>
```

使用单例的`DBManager`
```java
/**
 * 数据库控制中心
 */
public final class DBManager {

    private static DBManager manager = new DBManager();
    private SqlSessionFactory sessionFactory;

    public static DBManager getManager() {
        if (manager == null) {
            manager = new DBManager();
        }
        return manager;
    }

    private DBManager() {
        InputStream is = 
        Bootstrap.class.getClassLoader().getResourceAsStream("db_conf.xml"); // 直接使用文件名
        sessionFactory = new SqlSessionFactoryBuilder().build(is);
        sessionFactory.getConfiguration().addMapper(IDeveloperMapper.class);
    }

    public SqlSession openSession() {
        return this.sessionFactory.openSession();
    }
}
```

`db_conf.xml`中的url需要指定时区`jdbc:mysql://localhost:3306/samp_db1?serverTimezone=UTC`

在服务器启动的地方初始化一下mybatis
```java
public class Bootstrap implements WebApplicationInitializer {
    @Override
    public void onStartup(ServletContext container) throws ServletException {
        // spring配置........
        initMybatis();
    }

    /**
     * 初始化数据库管理中心
     */
    private void initMybatis() {
        DBManager.getManager();
    }
}
```
