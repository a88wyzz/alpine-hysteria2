# alpine-hysteria2
在alpine中安装hysteria2

## 一键食用
```
wget -O hy2.sh https://raw.githubusercontent.com/a88wyzz/alpine-hysteria2/main/hy2.sh  && sh hy2.sh
```
重复执行，会覆盖密码。  

## 说明：  
配置文件：/etc/hysteria/config.yaml  
使用自签名证书，默认端口13588，安全tls，SNI为：空
跳过证书验证 true
随系统自启动

以下是基于Alpine Linux系统、使用自签证书并集成OpenRC进程守护的Hysteria2服务端脚本实现方案:

核心功能说明：
1.自动生成ECDSA自签证书，有效期10年

2.集成Salamander混淆协议增强隐蔽性

3.通过OpenRC实现进程守护和开机自启

4.支持带宽限制配置（默认1Gbps）

5.自动生成16位随机认证密码和混淆密码

6.输出完整客户端连接参数

使用说明：
直接运行脚本完成安装
客户端需关闭证书验证（自签证书特性）
通过rc-service hysteria restart管理服务
配置文件路径：/etc/hysteria2/config.yaml





