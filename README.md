
使用流程只支持Alpine系统：

通过执行脚本

```
wget -O hy2.sh https://raw.githubusercontent.com/a88wyzz/alpine-hysteria2/main/hy2.sh  && sh hy2.sh
```

说明：

配置文件路径：/etc/hysteria/config.yaml

传输安全TLS，使用自签名证书，SNI为：bing.com

客户端配置时需关闭证书验证（自签证书特性）

默认端口19520 (可自行修改配置文件的端口后执行重启生效)

随系统自启动

查看状态 service hysteria status

执行重启 service hysteria restart



