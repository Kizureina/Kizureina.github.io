---
title: 基于JavaWeb的文件管理系统+OrangePi+内网穿透实现不限速大容量网盘
date: 2022-11-18 16:53:14
tags: 
- web
- java
---
## 0x00 前言

今年四月某日，我正写完大部分[python qqbot插件](/2022/01/30/qqbot-y2b-pusher/)，为该做什么发愁。刚好那时有社团展示，我百无聊赖在银杏大道散步闲逛时遇到了一个有趣的web开发向实验室。和摆摊的学长聊天之后，我才发现之前自己写的插件实际上就是web后端开发，而开发或许是比安全更有趣的领域，和他聊了好久之后，我回宿舍开始学Java，直到这学期开始写JavaWeb项目加入了他们实验室。总体还是很有趣的经历。在写文件管理系统项目的时候，有了如下的想法和经历。

## 0x01 思路

十月份某日，*Java老师提到他的网站是跑在作为服务器的树莓派上的*，说者无心听者有意，我那时不知道脑子怎么一抽，对树莓派突然来了兴趣。刚好那时我在写[基于原生JavaWeb+Mybatis+Vue+ElementUI的文件管理系统](https://github.com/Kizureina/java_web_file_manger)，如果能和基于树莓派的服务器结合，就能解决租借服务器硬盘容量太少的问题，实现不限速的大容量网盘（如果在同一内网内，网速仅取决于硬盘的IO读写极限，而容量限制也可以通过硬盘阵列解决）。这个想法实在非常非常有趣，如果有足够稳定的内网穿透服务，实现的效果会比组NAS更好而成本也低得多。



在花了一点功夫之后，我成功用裸板149的orangepi几乎完美实现了上述功能，文件管理系统的JavaWeb项目顺便让我加了web开发向的实验室，不过对现在的我有点进退维谷。![image-20221211213748592](https://files.catbox.moe/twnxf9.png)

Java以面向对象编程著称，确实是很有意思的编程思想，其实我总感觉核心就是**面向“东西”编程，把需求对象分解为一个又一个东西，然后用这些东西的属性和方法实现业务**。听起来很容易，但其实写起项目来并不是容易的事。对于麻烦的需求，可能还要用到spring等框架解耦合，不过我更喜欢用简单的知识解决问题。而且文件管理系统不算复杂，实际上只有两个关键的业务对象，也就是**用户对象和文件/文件夹对象**，其他全是这两个对象的方法和属性。

## 0x02 实现

### 业务层

文件对象

```java
package com.hit.service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class FileService {
    public static String ROOT_PATH = "/home/orangepi";
    public static String HOST = "localhost";
    private String path;
    public static List<String> CURRENT_FOLDER = new ArrayList<>();
    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public FileService() {
    }

    public FileService(String path) {
        this.path = path;
    }

    public static List<com.hit.pojo.File> getFileInfo(File file){
        List<com.hit.pojo.File> fileList = new ArrayList<>();
        //1、判断传入的是否是目录
        if(!file.isDirectory()){
            //不是目录直接退出
            return null;
        }
        //已经确保了传入的file是目录
        File[] files = file.listFiles();
        //遍历files
        assert files != null;
        for (File f: files) {
            //如果该目录下文件还是个文件夹就再进行递归遍历其子目录
            if(f.isDirectory()){
                long lastModified = f.lastModified();
                Date date = new Date(lastModified);
                com.hit.pojo.File file1 = new com.hit.pojo.File(0,f.getName(), date);
                fileList.add(file1);
            }else {
                long lastModified = f.lastModified();
                Date date = new Date(lastModified);
                com.hit.pojo.File file1 = new com.hit.pojo.File(f.length(),f.getName(), date);
                fileList.add(file1);
            }
        }
        return fileList;
    }
    public void createIndex(){
        Path path = Paths.get(FileService.ROOT_PATH + getPath());
        try {
            Path pathCreate = Files.createDirectory(path);
            System.out.println(pathCreate);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
    public boolean deleteFile(){
        try {
            Path path1 = Paths.get(FileService.ROOT_PATH + path);
            if (Files.exists(path1)){
                Files.delete(path1);
                return true;
            }
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
        return false;
    }
    public boolean renameFile(String oldName, String newName){
        try {
            File newFile = new File(path + newName);
            if (newFile.exists()) {
                //  确保新的文件名不存在
                throw new java.io.IOException("file exists");
            }
            return new File(path + oldName).renameTo(new File(path + newName));
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
    }
//    public boolean downloadFile(File file){
//        if(file.isDirectory()){
//            //是目录直接退出
//            return false;
//        }
//
//        return true;
//    }
}

```

用户对象

```java
package com.hit.service;

import com.hit.mapper.UserMapper;
import com.hit.pojo.User;
import com.hit.util.CheckCodeUtil;
import com.hit.util.MailUtil;
import com.hit.util.SqlSessionFactoryUtils;
import com.hit.web.Servlet.Checkcode;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.testng.annotations.Test;

import java.util.List;

/**
 * @author Yoruko
 */
public class UserService {
    public static String code;
    static SqlSessionFactory sqlSessionFactory = SqlSessionFactoryUtils.getSqlSessionFactory();

    public List<User> selectAllUsers(){
        SqlSession sqlSession = sqlSessionFactory.openSession();
        UserMapper mapper = sqlSession.getMapper(UserMapper.class);

        return mapper.selectAllUsers();
    }
    public int insertUser(String username, String password, int status){
        SqlSession sqlSession = sqlSessionFactory.openSession();
        UserMapper mapper = sqlSession.getMapper(UserMapper.class);
        int result = mapper.insertUserByName(username, password, status);
        sqlSession.commit();
        return result;
    }
    public static void editUserStatus(String username, int status){
        SqlSession sqlSession = sqlSessionFactory.openSession();
        UserMapper mapper = sqlSession.getMapper(UserMapper.class);
        mapper.editUserStatus(username, status);
        sqlSession.commit();
    }
    public boolean doRegister(String userName, String email) {
        code = Checkcode.getCodeString();
        //保存成功则通过线程的方式给用户发送一封邮件
        try {
            MailUtil.CODE.put(userName, code);
            new Thread(new MailUtil(email, userName)).start();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        return true;
    }
    public int selectUserStatusByName(String username){
        SqlSession sqlSession = sqlSessionFactory.openSession();
        UserMapper mapper = sqlSession.getMapper(UserMapper.class);
        return mapper.selectUserStatusByName(username);
    }
    public boolean changePasswordByName(String username, String password){
        SqlSession sqlSession = sqlSessionFactory.openSession();
        UserMapper mapper = sqlSession.getMapper(UserMapper.class);
        boolean b = mapper.changePasswordByName(username, password);
        sqlSession.commit();
        return b;
    }
}

```

### 实现层

因为是原生Javaweb所以就是一堆Servlet，虽然我也写了Filiter和Listener，但后来发现其实是鸡肋，这里为了实现功能写了十几个servlet，这里列几个比较麻烦的：

**文件下载**

```java
package com.hit.web.Servlet;

import com.alibaba.fastjson.JSON;
import com.hit.service.FileService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/fileDownloadServlet")
public class FileDownloadServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(FileDownloadServlet.class);
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/multipart/form-data;charset=utf-8");
        // 用于文件传输
        String fileName = new String(request.getParameter("fileName").getBytes(StandardCharsets.ISO_8859_1), StandardCharsets.UTF_8);
        response.setHeader("Content-Disposition", "attachment;filename*=UTF-8''" + URLEncoder.encode(fileName,"UTF-8"));
        // 强制浏览器下载文件，解决中文乱码
        HttpSession session = request.getSession();
        String userName = (String) session.getAttribute("username");
        String currentIndex = (String) session.getAttribute("index");

        File file = currentIndex == null ?
                new File(FileService.ROOT_PATH + userName + "/" + fileName):
                new File(FileService.ROOT_PATH + userName + "/" + currentIndex + "/" + fileName);
        if (file.isDirectory()){
            String s = JSON.toJSONString(false);
            response.getWriter().write(s);
            logger.error("下载对象不可为文件夹" + fileName);
            return;
        }
        try (FileInputStream fileInputStream = new FileInputStream(file)) {
            ServletOutputStream outputStream = response.getOutputStream();
            byte[] buffer = new byte[1024];
            int len = 0;
            while ((len = fileInputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, len);
            }
            logger.info(fileName + "文件下载成功");
        } catch (FileNotFoundException e) {
            logger.error(fileName + "文件下载失败！");
            throw new RuntimeException(e);
        }


    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doGet(request, response);
    }
}

```

**打开文件夹**

```java
package com.hit.web.Servlet;

import com.alibaba.fastjson.JSON;
import com.hit.pojo.File;
import com.hit.service.FileService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/getSubFilesServlet")
public class GetSubFilesServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(GetSubFilesServlet.class);
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/json;charset=utf-8");
        HttpSession session = request.getSession();
        String userName = (String) session.getAttribute("username");
        String currentIndex = (String) session.getAttribute("index");

        String indexName = new String(request.getParameter("indexName").getBytes(StandardCharsets.ISO_8859_1), StandardCharsets.UTF_8);
        FileService.CURRENT_FOLDER.add(indexName);
        List<File> fileInfo;
        if (currentIndex == null){
            session.setAttribute("index",indexName);
            fileInfo = FileService.getFileInfo(new java.io.File(FileService.ROOT_PATH + userName + "/" + indexName));
            if (fileInfo == null){
                response.getWriter().write(JSON.toJSONString(0));
                return;
            }
        } else {
            session.setAttribute("index",currentIndex + "/" + indexName);

            fileInfo = FileService.getFileInfo(new java.io.File(FileService.ROOT_PATH + userName + "/" + currentIndex + "/" + indexName));
            if(fileInfo == null){
                response.getWriter().write(JSON.toJSONString(0));
                return;
            }
        }
        String s = JSON.toJSONString(fileInfo);
        response.getWriter().write(s);
        logger.info("进入子目录" + indexName);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doGet(request, response);
    }
}

```

**返回上一级文件夹**

```java
package com.hit.web.Servlet;

import com.alibaba.fastjson.JSON;
import com.hit.pojo.File;
import com.hit.service.FileService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;

/**
 * @author Yoruko
 */
@WebServlet("/backSuperFolderServlet")
public class BackSuperFolderServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(BackSuperFolderServlet.class);
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String currentFolder = FileService.CURRENT_FOLDER.get(FileService.CURRENT_FOLDER.size() - 1);
        HttpSession session = request.getSession();
        String userName = (String) session.getAttribute("username");
        if(currentFolder.equals(userName)){
            String s = JSON.toJSONString(null);
            response.getWriter().write(s);
            return;
        }
        String currentIndex = (String) session.getAttribute("index");
        response.setContentType("text/json;charset=utf-8");

        List<File> fileInfo;
        if(currentIndex.equals(currentFolder)){
            FileService.CURRENT_FOLDER.clear();
            FileService.CURRENT_FOLDER.add(userName);
            session.removeAttribute("index");
            try {
                fileInfo = FileService.getFileInfo(new java.io.File(FileService.ROOT_PATH + userName));
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write(JSON.toJSONString(0));
                return;
            }
        }else {
            String nowIndex = currentIndex.replace("/" + currentFolder,"");
            session.setAttribute("index",nowIndex);
            try {
                fileInfo = FileService.getFileInfo(new java.io.File(FileService.ROOT_PATH + userName + "/" + nowIndex));
            } catch (Exception e) {
                e.printStackTrace();
                String s = JSON.toJSONString(0);
                response.getWriter().write(s);
                return;
            }
        }
        String s = JSON.toJSONString(fileInfo);
        response.getWriter().write(s);
        logger.info("返回了" + currentIndex + "的上一级目录");
        FileService.CURRENT_FOLDER.remove(currentFolder);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doGet(request, response);
    }
}

```

**文件上传**

其实这个是最复杂的功能，还要和前端对接，所以干脆用common-upload包了

```java
package com.hit.web.Servlet;

import com.hit.service.FileService;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;

@WebServlet("/fileUploadServlet")
public class FileUploadServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(FileUploadServlet.class);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 获取当前目录
        response.setContentType("text/html;charset=utf-8");
        HttpSession session = request.getSession();
        String currentIndex = (String) session.getAttribute("index");
        String userName = (String) session.getAttribute("username");

        String path = currentIndex == null ? userName: userName + "/" + currentIndex;

        String savePath = FileService.ROOT_PATH + path;
        File file = new File(savePath);
        //判断上传文件的保存目录是否存在
        if (!file.exists() && !file.isDirectory()) {
            logger.error(savePath+"目录不存在，需要创建");
            //创建目录
            if(file.mkdir()){
                logger.info("新建文件夹成功");
            }else {
                logger.error("新建文件夹失败");
            }
        }
        //消息提示
        String message = "";
        try{
            //使用Apache文件上传组件处理文件上传步骤：
            //1、创建一个DiskFileItemFactory工厂
            DiskFileItemFactory factory = new DiskFileItemFactory();
            //2、创建一个文件上传解析器
            ServletFileUpload upload = new ServletFileUpload(factory);
            //解决上传文件名的中文乱码
            upload.setHeaderEncoding("UTF-8");
            //3、判断提交上来的数据是否是上传表单的数据
            if(!ServletFileUpload.isMultipartContent(request)){
                //按照传统方式获取数据
                return;
            }
            //4、使用ServletFileUpload解析器解析上传数据，解析结果返回的是一个List<FileItem>集合，每一个FileItem对应一个Form表单的输入项
            List<FileItem> list = upload.parseRequest(request);
            for(FileItem item : list){
                //如果fileitem中封装的是普通输入项的数据
                if(item.isFormField()){
                    String name = item.getFieldName();
                    //解决普通输入项的数据的中文乱码问题
                    String value = item.getString("UTF-8");
                    value = new String(value.getBytes("ISO8859-1"), StandardCharsets.UTF_8);
                    System.out.println(name + "=" + value);
                }else{
                    //如果fileitem中封装的是上传文件
                    //得到上传的文件名称，
                    String filename = item.getName();
                    System.out.println(filename);
                    if(filename == null || "".equals(filename.trim())){
                        continue;
                    }
                    //注意：不同的浏览器提交的文件名是不一样的，有些浏览器提交上来的文件名是带有路径的，如：  c:\a\b\1.txt，而有些只是单纯的文件名，如：1.txt
                    //处理获取到的上传文件的文件名的路径部分，只保留文件名部分
                    filename = filename.substring(filename.lastIndexOf("/")+1);
                    //获取item中的上传文件的输入流
                    InputStream in = item.getInputStream();
                    //创建一个文件输出流
                    FileOutputStream out = new FileOutputStream(savePath + "/" + filename);
                    //创建一个缓冲区
                    byte buffer[] = new byte[1024];
                    //判断输入流中的数据是否已经读完的标识
                    int len = 0;
                    //循环将输入流读入到缓冲区当中，(len=in.read(buffer))>0就表示in里面还有数据
                    while((len = in.read(buffer))>0){
                        //使用FileOutputStream输出流将缓冲区的数据写入到指定的目录(savePath + "\\" + filename)当中
                        out.write(buffer, 0, len);
                    }
                    //关闭输入流
                    in.close();
                    //关闭输出流
                    out.close();
                    //删除处理文件上传时生成的临时文件
                    item.delete();
                    message = "文件上传成功！";
                }
            }
        }catch (Exception e) {
            message= "文件上传失败！";
            e.printStackTrace();

        }
        request.setAttribute("message",message);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        this.doGet(request, response);
    }
}

```



前端也是自己写的，其实Vue写起来还是挺舒服的，不过有Element也不用写css，其实就是Javascript：

```javascript
vm = new Vue({
    el:"#app",
    data() {
        return {
            editdate: '',
            filename: '',
            size: '',
            username:"",
            tableData:{},
            multipleSelection: [],
            fileList: []
        }
    },
    methods: {
        download(){
            if (this.multipleSelection.length !== 1){
                alert("请只选择一个文件进行操作>_<");
                return;
            }
            let fileName = this.multipleSelection[0].name;
            if (fileName.indexOf(".") !== -1){
                let url = "/fileDownloadServlet?fileName=" + fileName;
                window.location.href = encodeURI(url);
            }else {
                this.$message.error('不可下载文件夹！');
            }

            // axios.get("http://localhost/fileDownloadServlet?fileName=" + fileName)
            //     .then(resp => {
            //         console.log("下载请求成功");
            //         if (resp.data !== false){
            //             window.location.href = "/fileDownloadServlet?fileName=" + fileName;
            //         }else{
            //             this.$message.error('不可下载文件夹！');
            //         }
            //     })
            //     .catch(e =>{
            //         alert("出错了！");
            //     })
        },

        backFolder(){
            axios.get("https://192.168.1.220:8080/backSuperFolderServlet")
                .then(resp => {
                    var obj = resp.data;
                    if (obj == null){
                        this.$message.error('已为根目录！');
                        return;
                    }
                    this.tableData = Array(obj.length);

                    for (let i = 0; i < obj.length; i++){
                        let f = obj[i];
                        let rawDate = new Date(f.editTime);
                        let size = f.filesize > 0 ? f.filesize : "-";
                        if (size > 1024*1024 && size < 1024*1024*1024){
                            size = Number(size / (1024 * 1024)).toFixed(2) + "M";
                        }else if (size > 1024*1024*1024){
                            size = Number(size / (1024 * 1024 * 1024)).toFixed(2) + "G";
                        }else if (size < 1024*1024){
                            size = Number(size / 1024).toFixed(2) + "K";
                        }else {
                        }
                        d = dateFormat("YYYY-mm-dd HH:MM", rawDate);
                        this.tableData.push({
                            name: f.fileName,
                            date: d,
                            size: size
                        })
                    }
                });
        },
        openFolder(){
            if (this.multipleSelection.length !== 1){
                alert("请只选择一个文件进行操作>_<");
                return;
            }
            let folderName = this.multipleSelection[0].name;
            if (this.multipleSelection[0].size !== '-'){
                let url = "/" + folderName;
                window.location.href = encodeURI(url);
                return;
            }
            axios.get("https://192.168.1.220:8080/getSubFilesServlet?indexName=" + folderName)
                .then(resp => {
                    const obj = resp.data;
                    this.tableData = Array(obj.length);
                    let d;
                    for (let i = 0; i < obj.length; i++) {
                        let f = obj[i];
                        let rawDate = new Date(f.editTime);
                        let size = f.filesize > 0 ? f.filesize : "-";
                        if (size > 1024 * 1024 && size < 1024 * 1024 * 1024) {
                            size = Number(size / (1024 * 1024)).toFixed(2) + "M";
                        } else if (size > 1024 * 1024 * 1024) {
                            size = Number(size / (1024 * 1024 * 1024)).toFixed(2) + "G";
                        } else if (size < 1024 * 1024) {
                            size = Number(size / 1024).toFixed(2) + "K";
                        } else {
                        }
                        d = dateFormat("YYYY-mm-dd HH:MM", rawDate);
                        this.tableData.push({
                            name: f.fileName,
                            date: d,
                            size: size
                        })
                    }
                });
        },

        deleteConfirm() {
            if (this.multipleSelection.length < 1){
                alert("请选择文件>_<");
                return;
            }
            this.$confirm('此操作将永久删除该文件, 是否继续?', '警告', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning'
            }).then(() => {
                this.deleteFile();
            }).catch(e => {
                console.log(e);
                this.$message({
                    type: 'info',
                    message: '已取消删除'
                });
            });
        },
        deleteFile(){
            for(let i = 0; i < this.multipleSelection.length; i++) {
                let url = "https://192.168.1.220:8080/deleteFileServlet?indexName=" + this.multipleSelection[i].name;
                axios.get(encodeURI(url))
                    .then(resp => {
                        // console.log(resp.data);
                        if(resp.data === true){
                            this.$message({
                                type: 'success',
                                message: '删除成功!'
                            });
                        }else {
                            this.$message.error('删除失败！不可删除非空文件夹！');
                        }
                    })
                    .catch(error => {
                        console.log(error);
                        this.deleteFlag = false;
                    })
            }
        },
        toggleSelection(rows) {
            if (rows) {
                rows.forEach(row => {
                    this.$refs.multipleTable.toggleRowSelection(row);
                });
            } else {
                this.$refs.multipleTable.clearSelection();
            }
        },
        handleSelectionChange(val) {
            this.multipleSelection = val;
        },
        handleCommand(command){
            if (command === "b"){
                axios.get("https://192.168.1.220:8080/destroySessionServlet")
                    .then(resp => {
                        alert("注销成功！");
                        window.location.href='/login.html';
                    })
                    .catch(e =>{
                        alert("注销失败!请重试！");
                    });
            }else{
                this.$prompt('请输入修改后的密码', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    inputPattern: /^\w+$/,
                    inputErrorMessage: '密码格式不正确，密码只能由数字字母和下划线'
                }).then(({ value }) => {
                    if (value.length > 20){
                        this.$message({
                            type: 'error',
                            message: '新密码过长'
                        });
                        return;
                    }
                    axios({
                        method : "POST",
                        url : "https://192.168.1.220:8080/changePasswordServlet",
                        data : "password=" + value
                    })
                        .then(resp=>{
                            this.$message({
                                type: 'success',
                                message: '密码修改成功'
                            });
                        })
                        .catch(error=>{
                            console.log(error);
                            this.$message.error('出错了!请重试');
                        })
                }).catch(() => {
                    this.$message({
                        type: 'info',
                        message: '取消输入'
                    });
                });
            }
        },
        getFileInfo(){
            axios.get("https://192.168.1.220:8080/fileInfoServlet")
                .then(resp=>{
                    console.log(resp.data);
                    var obj = resp.data;
                    this.tableData = Array(obj.length);
                    for (let i = 0; i < obj.length; i++){
                        let f = obj[i];
                        let size = f.filesize > 0 ? f.filesize : "-";
                        if (size > 1024*1024 && size < 1024*1024*1024){
                            size = Number(size / (1024*1024)).toFixed(2) + "M";
                        }else if (size > 1024*1024*1024){
                            size = Number(size / (1024 * 1024 * 1024)).toFixed(2) + "G";
                        }else if (size < 1024*1024){
                            size = Number(size / 1024).toFixed(2) + "K";
                        }else {
                        }
                        let rawDate = new Date(f.editTime);
                        d = dateFormat("YYYY-mm-dd HH:MM", rawDate);
                        this.tableData.push({
                            name: f.fileName,
                            date: d,
                            size: size
                        })
                    }
                });
        },

        getUserName() {
            axios.get("https://192.168.1.220:8080/userInfo")
                //then获取成功；response成功后的返回值（对象）
                .then(response=>{
                    this.username = response.data;
                })
                //获取失败
                .catch(error=>{
                    console.log(error);
                    alert('网络错误!');
                })
        },
        open() {
            this.$prompt('请输入文件夹名', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消'
                // inputPattern: /\\*\/\\*/,
                // inputErrorMessage: '文件名格式不正确'
            }).then(({ value }) => {
                if (value.length > 64){
                    this.$message({
                        type: 'error',
                        message: '文件名过长'
                    });
                    return;
                }
                let url = "https://192.168.1.220:8080/createIndexServlet?indexName=" + value;
                // console.log(encodeURI(url));
                axios.get(encodeURI(url))
                    .then(resp=>{
                        this.$message({
                            type: 'success',
                            message: '新建文件夹名为: ' + value
                        });
                    })
                    .catch(error=>{
                        console.log(error);
                        this.$message.error('出错了!请检查文件名！');
                    })
            }).catch(() => {
                this.$message({
                    type: 'info',
                    message: '取消输入'
                });
            });
        },
        upload() {
            this.$alert('<template><el-upload\n' +
                '  class="upload-demo"\n' +
                '  drag\n' +
                '  action="https://192.168.1.220:8080/fileUploadServlet"\n' +
                '  multiple>\n' +
                '  <i class="el-icon-upload"></i>\n' +
                '  <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>\n' +
                '  <div class="el-upload__tip" slot="tip">只能上传jpg/png文件，且不超过500kb</div>\n' +
                '</el-upload></template>', 'HTML 片段', {
                dangerouslyUseHTMLString: true
            })
            this.$message({
                type: 'success',
                message: '已上传'
            });
        }
    },
    mounted(){
        axios.defaults.withCredentials = true;
        this.getUserName();
        this.getFileInfo();
    }
});
function dateFormat(fmt, date) {
    let ret;
    const opt = {
        "Y+": date.getFullYear().toString(),        // 年
        "m+": (date.getMonth() + 1).toString(),     // 月
        "d+": date.getDate().toString(),            // 日
        "H+": date.getHours().toString(),           // 时
        "M+": date.getMinutes().toString(),         // 分
        "S+": date.getSeconds().toString()          // 秒
        // 有其他格式化字符需求可以继续添加，必须转化成字符串
    };
    for (let k in opt) {
        ret = new RegExp("(" + k + ")").exec(fmt);
        if (ret) {
            fmt = fmt.replace(ret[1], (ret[1].length === 1) ? (opt[k]) : (opt[k].padStart(ret[1].length, "0")))
        }
    }
    return fmt;
}
```

主页面是自己拼凑的：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>FileMangerSystemDemo</title>
    <link rel="icon" href="img/login.ico" type="image/x-icon">
    <link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
    <style>
        .el-header {
            background-color: #B3C0D1;
            color: #333;
            line-height: 60px;
        }
        .el-aside {
            color: #333;
        }
    </style>
</head>
<body style="background-color: #a6c1ee">
    <div id="app">
        <el-container style="height: 100%; border: 5px solid #eee">
            <el-container>
                <el-header style="text-align: right; font-size: 30px">
                    <el-dropdown @command="handleCommand" style="font-size: 100%">
                        <i class="el-icon-user" style="margin-right: 5px"></i>
                        <el-dropdown-menu slot="dropdown">
                            <el-dropdown-item command="a">修改密码</el-dropdown-item>
                            <el-dropdown-item command="b">注销账号</el-dropdown-item>
                        </el-dropdown-menu>
                    </el-dropdown>
                    <span style="font-family: 'Adobe Caslon Pro Bold',serif ;background-color: #03e6f4">{{username}}</span>


                </el-header>
                <template >
                    <el-button type="primary"
                               @click="open"
                               style="position: absolute;
                               top: 25px;
                               left: 35px;">
                        新建文件夹
                        <i class="el-icon-folder-add"></i>
                    </el-button>

                    <el-popover
                            placement="right"
                            width="380"
                            trigger="click">
                        <el-upload
                                class="upload-demo"
                                drag
                                action="http://localhost/fileUploadServlet"
                                multiple>
                            <i class="el-icon-upload"></i>
                            <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
                            <div class="el-upload__tip" slot="tip">只能上传jpg/png文件，且不超过500kb</div>
                        </el-upload>
                        <el-button slot="reference"
                                type="primary"
                                style="position: absolute;
                                top: 25px;
                                left: 180px;">
                            上传
                            <i class="el-icon-upload el-icon--right"></i>
                        </el-button>
                    </el-popover>

                    <el-button type="primary"
                               @click="deleteConfirm"
                               style="position: absolute;
                               top: 25px;
                               left: 290px;">
                        删除
                        <i class="el-icon-delete"></i>
                    </el-button>

                    <el-button type="primary"
                               @click="backFolder"
                               style="position: absolute;
                               top: 25px;
                               left: 380px;">
                        后退
                        <i class="el-icon-back"></i>
                    </el-button>

                    <el-button type="primary"
                               @click="openFolder"
                               style="position: absolute;
                               top: 25px;
                               left: 480px;">
                        打开
                        <i class="el-icon-right"></i>
                    </el-button>

                    <el-button type="primary"
                               @click="download"
                               style="position: absolute;
                               top: 25px;
                               left: 580px;">
                        下载
                        <i class="el-icon-link"></i>
                    </el-button>

                </template>
                <el-main>
                    <el-table
                            ref="multipleTable"
                            :data="tableData"
                            tooltip-effect="dark"
                            style="width: 100%"
                            @selection-change="handleSelectionChange">
                        <el-table-column
                                type="selection"
                                width="55">
                        </el-table-column>
                        <el-table-column
                                prop="name"
                                label="文件名"
                                width="540">
                        </el-table-column>
                        <el-table-column
                                label="修改日期"
                                width="500">
                            <template slot-scope="scope">{{ scope.row.date }}</template>
                        </el-table-column>
                        <el-table-column
                                prop="size"
                                label="文件大小"
                                show-overflow-tooltip>
                        </el-table-column>
                    </el-table>
                </el-main>
            </el-container>
        </el-container>

    </div>
</body>
<script src="js/vue.min.js"></script>
<script src="js/axois.min.js"></script>
<script src="js/element-ui@2.15.10.js"></script>
<script src="js/index.js"></script>
</html>
```

登录注册则是用的开源模板：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1.0" />
    <title>用户注册</title>
    <link rel="stylesheet"  href="css/style.css" />
    <link rel="icon" href="img/login.ico" type="image/x-icon">

<body>
<div id="app">
    <div class="login">
        <template>
            <el-alert style="display: none" id="success"
                      title="This username is not registered.OvO"
                      type="success"
                      center
                      show-icon>
            </el-alert>

            <el-alert style="display: none" id="error"
                      title="Username has been registered,please retry.>_<"
                      type="error"
                      center
                      show-icon>
            </el-alert>
        </template>
        <h2>Register</h2>
        <form action="/register" method="post">
            <div class="login_box">
                <input type="text" name='username' id='username' required onblur="inputonblur(this.value)"/>
                <label for="username" >Username</label>
            </div>

            <div id="err" style="background-color: white"></div>
            <div class="login_box">
                <input type="password" name='password' id='password' required="required">
                <label for="password">Password</label>
            </div>
            <div class="login_box">
                <input type="text" name='email' id='email' required/>
                <label for="email" >Email</label>
            </div>
            <div class="login_box">
                <input type="text" name='check' id='check' required="required">
                <label for="check">Verification Code</label>
                <img src="/checkcode" onclick="changeImg(this)" style="display:block;margin:0 auto;width:245px;height:45px;"/>

            </div>
            <br>
            <button type="submit" style="display:block;margin:0 auto;width:245px;height:45px;">
                Register!
            </button>
            <div class="msg">
                Already own an account?  <a href="/login.html">Log in</a>
            </div>
        </form>
    </div>
</div>
<script src="js/axois.min.js"></script>
<script src="js/vue.min.js"></script>
<link rel="stylesheet" href="https://unpkg.com/element-ui/lib/theme-chalk/index.css">
<script src="https://unpkg.com/element-ui/lib/index.js"></script>
<script>
    new Vue({
        el:"#app"
    });
    function changeImg(obj) {
        obj.src = "/checkcode?t=" + Date.now();
    }
    function inputonblur(e){
        axios({
            method : "GET",
            url : "http://192.168.1.220/selectAllUser?username=" + e
        }).then(function (resq){
            if (e !== ""){
                if(resq.data === "yes"){
                    document.getElementById("error").style.display = "";
                    //document.getElementById("err").innerHTML = "This username has been registered,please retry.>_<";
                }else{
                    document.getElementById("success").style.display = "";
                    //document.getElementById("err").innerHTML = "This username is not registered.OvO";
                }
            }
        })
    }
</script>
</body>
</html>

```

### 持久层

数据库操作就是mybatis那一套，就懒得细写了：

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<!--
namespace
-->
<mapper namespace="com.hit.mapper.UserMapper">
    <resultMap id="userResultMap" type="com.hit.pojo.User">
        <result column="username" property="userName"/>
        <result column="password" property="passWord"/>
    </resultMap>
    <insert id="insertUserByName">
        insert into user(username,password,status)
        values (#{username},#{password},#{status});
    </insert>

    <update id="editUserStatus">
        update user
        set
            status = #{status}
        where username = #{username};
    </update>

    <update id="changePasswordByName">
        update user
        set
            password = #{password}
        where username = #{username};
    </update>

    <select id="selectAllUsers" resultMap="userResultMap">
        select *
        from user;
    </select>

    <select id="selectUserStatusByName" resultType="java.lang.Integer">
        select status
        from user
        where username = #{username};
    </select>
</mapper>
```

## 0x03 项目细节

实现*视频在线播放的进度条拖动需要用到断点续传和分块传输*，原生JavaWeb实现非常麻烦（当然用第三方播放器也不怎么方便），而且需要与前端进行HTTP协议的对接，对于前端出了Javascript全用ElementUI的我非常呃呃，权衡之下我把在线播放改成用web容器来干断点续传的活。但tomcat相对路径已经写死，并且一般用户没有上传文件的权限，传输文件很麻烦。因此我换了个思路，改用在另外端口跑nginx，再把servlet直接跳转至对应nginx服务的url，轻松解决视频播放问题。

```javascript
 openFolder(){
            if (this.multipleSelection.length !== 1){
                alert("请只选择一个文件进行操作>_<");
                return;
            }
            let folderName = this.multipleSelection[0].name;
            if (this.multipleSelection[0].size !== '-'){
                let url = "/" + folderName;
                window.location.href = encodeURI(url);
                return;
            }
            axios.get("https://192.168.1.220:8080/getSubFilesServlet?indexName=" + folderName)
                .then(resp => {
                    const obj = resp.data;
                    this.tableData = Array(obj.length);
                    let d;
                    for (let i = 0; i < obj.length; i++) {
                        let f = obj[i];
                        let rawDate = new Date(f.editTime);
                        let size = f.filesize > 0 ? f.filesize : "-";
                        if (size > 1024 * 1024 && size < 1024 * 1024 * 1024) {
                            size = Number(size / (1024 * 1024)).toFixed(2) + "M";
                        } else if (size > 1024 * 1024 * 1024) {
                            size = Number(size / (1024 * 1024 * 1024)).toFixed(2) + "G";
                        } else if (size < 1024 * 1024) {
                            size = Number(size / 1024).toFixed(2) + "K";
                        } else {
                        }
                        d = dateFormat("YYYY-mm-dd HH:MM", rawDate);
                        this.tableData.push({
                            name: f.fileName,
                            date: d,
                            size: size
                        })
                    }
                });
        },
```

如上是Vue的打开文件夹的方法，加一个判断是否为文件夹然后跳转即可。

## 0x04 SSH连接OrangePi

香橙派与单片机不同，5vUSB供电不足以支撑运行，因此需要用HDMI线连接屏幕才能初始化，但我当然既没有屏幕也没有HDMI线，因此用SSH的方式连接：

1. typec供电，网线接入香橙派，在对应的路由器或交换机后台找到香橙派的内网IP
2. ssh软件（我用的Termius，好看又好用）用对应内网IP作host，默认密码orangepi连接香橙派，成功后即可进行Linux初始化，具体修改配置参考香橙派对应开发板官网。
3. 将联网设置为WIFI，从路由器获取此时内网IP
4. 设置静态IP，断开网线后即可之后用此IP来SSH连接香橙派

注：之所以不用有线连接主要是校园网锐捷的认证客户端Linux版本不支持arm架构，没办法=_=

## 0x05 部署

把项目部署到orangepi的Linux服务器又踩了不少坑。

1. 第一个麻烦的问题是跨域，查了半天改了半天又请教了学长半天还是跨域不了，只好自己嗯写，突然想到跨域是Ajax（其实我用的axios框架）造成的，在前端获取当前域再动态请求不就可以了？最后在前端几行就搞定了。
2. Linux连接数据库比windows要麻烦，因为权限控制更严格。默认用户的权限不能连接mysql数据库，而直接用root连接后tomcat还是连不上。最后在mysql新建用户，然后赋予root权限就搞定了。
3. 免费内网穿透服务大多很蛋疼，比较好的办法是用frp（当然前提是你有带公网ip的服务器）

![image-20221211223407010](https://files.catbox.moe/7vka37.png)

搞定。