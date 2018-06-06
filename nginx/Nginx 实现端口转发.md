## 什么是端口转发

当我们在服务器上搭建一个图书以及一个电影的应用，其中图书应用启动了 8001 端口，电影应用启动了 8002 端口。此时如果我们可以通过

```
localhost:8001    //图书
localhost:8002    //电影
 ```

但我们一般访问应用的时候都是希望不加端口就访问域名，也即两个应用都通过 80 端口访问。但我们知道服务器上的一个端口只能被一个程序使用，这时候如何该怎么办呢？一个常用的方法是用 Nginx 进行端口转发。Nginx 的实现原理是：用 Nginx 监听 80 端口，当有 HTTP 请求到来时，将 HTTP 请求的 HOST 等信息与其配置文件进行匹配并转发给对应的应用。例如当用户访问 book.douban.com 时，Nginx 从配置文件中知道这个是图书应用的 HTTP 请求，于是将此请求转发给 8001 端口的应用处理。当用户访问 movie.douban.com 时，Nginx 从配置文件中知道这个是电影应用的 HTTP 请求，于是将此请求转发给 8002 端口的应用处理。一个简单的 Nginx 配置文件（部分）如下面所示：

```
#配置负载均衡池
#Demo1负载均衡池
upstream book_pool{
    server 127.0.0.1:8001;
}
#Demo2负载均衡池
upstream movie_pool{
    server 127.0.0.1:8002;
}

#Demo1端口转发
server {
    listen       80;
    server_name  book.chanshuyi.com;
    access_log logs/book.log;
    error_log logs/book.error;
    
    #将所有请求转发给demo_pool池的应用处理
    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://book_pool;
    }
}
#Demo2端口转发
server {
    listen       80;
    server_name  movie.chanshuyi.com;
    access_log logs/movie.log;
    error_log logs/movie.error;
    
    #将所有请求转发给demo_pool池的应用处理
    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://movie_pool;
    }
}
```
 
上面这段配置实现了：

* 当用户访问的域名是：http://book.chanshuyi.com 时，我们自动将其请求转发给端口号为 8001 的 Tomcat 应用处理。

* 当用户访问的域名是：http://movie.chanshuyi.com 时，我们自动将其请求转发给端口号为 8002 的 Tomcat 应用处理。

上面的这种技术实现就是端口转发。端口转发指的是由软件统一监听某个域名上的某个端口（一般是80端口），当访问服务器的域名和端口符合要求时，就按照配置转发给指定的 Tomcat 服务器处理。我们常用的 Nginx 也有端口转发功能。
