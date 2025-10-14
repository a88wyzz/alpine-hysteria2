
#!/bin/sh
# Hysteria2 Alpine安装脚本 (交互式端口配置+Bing证书伪装)
CONFIG_DIR="/etc/hysteria2"
BIN_PATH="/usr/local/bin/hysteria"

# 检测root权限
if [ "$(id -u)" != "0" ]; then
    echo "错误：必须使用root权限运行此脚本" >&2
    exit 1
fi

# 安装依赖
apk add --no-cache openssl wget curl

# 交互式配置
read -p "请输入监听端口 (默认443): " PORT
PORT=${PORT:-443}

read -p "设置认证密码 (留空自动生成): " AUTH_PWD
if [ -z "$AUTH_PWD" ]; then
    AUTH_PWD=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
fi

# 创建配置目录
mkdir -p $CONFIG_DIR

# 生成Bing伪装证书
openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
    -keyout $CONFIG_DIR/server.key -out $CONFIG_DIR/server.crt \
    -subj "/CN=www.bing.com" -days 3650

# 下载最新二进制
HY2_VER=$(curl -sSL "https://api.github.com/repos/apernet/hysteria/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl -sSL "https://github.com/apernet/hysteria/releases/download/$HY2_VER/hysteria-linux-amd64" -o $BIN_PATH
chmod +x $BIN_PATH

# 生成配置文件
cat > $CONFIG_DIR/config.yaml <<EOF
listen: :$PORT
tls:
  cert: $CONFIG_DIR/server.crt
  key: $CONFIG_DIR/server.key
auth:
  type: password
  password: $AUTH_PWD
obfs:
  type: salamander
  salamander:
    password: $(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
masquerade:
  type: host
  host:
    protocol: https
    host: www.bing.com
    port: 443
EOF

# OpenRC服务配置
cat > /etc/init.d/hysteria <<EOF
#!/sbin/openrc-run
name="Hysteria2 Proxy Server"
command="$BIN_PATH"
command_args="server --config $CONFIG_DIR/config.yaml"
command_background=true
pidfile="/run/hysteria.pid"
start_stop_daemon_args="--make-pidfile"
depend() {
    need net
}
EOF
chmod +x /etc/init.d/hysteria

# 启动服务
rc-update add hysteria default
rc-service hysteria start

# 输出配置信息
IP=$(curl -4sSL ifconfig.me)
echo "=== 安装完成 ==="
echo "服务器IP: $IP"
echo "端口: $PORT"
echo "密码: $AUTH_PWD"
echo "混淆密码: $(grep salamander -A2 $CONFIG_DIR/config.yaml | tail -n1 | awk '{print $2}')"
echo "证书伪装: www.bing.com"
echo "服务管理: rc-service hysteria [start|stop|restart]"
