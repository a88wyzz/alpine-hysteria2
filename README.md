本脚本使用AI生成：

以下是基于Alpine Linux系统、集成OpenRC进程守护、使用Bing.com伪装域名的自签证书，并支持交互式端口配置的Hysteria2服务端完整实现方案：

核心功能说明：

交互式配置端口和密码，支持默认值自动填充

使用Bing.com作为伪装域名生成自签证书，增强隐蔽性

集成Salamander混淆协议防止UDP QoS限制

通过OpenRC实现进程守护和开机自启

自动输出包含IPv4地址的完整客户端配置信息

使用流程：

通过执行脚本

```
wget -O hy2.sh https://raw.githubusercontent.com/a88wyzz/alpine-hysteria2/main/hy2.sh  && sh hy2.sh
```

按提示输入端口和密码（直接回车使用默认值）

客户端配置时需关闭证书验证（自签证书特性）

服务状态可通过rc-service hysteria status查看

