
#!/bin/sh
# Hysteria2服务端安装脚本 for Alpine Linux
# 功能：自签证书+OpenRC守护进程+多端口跳跃
CONFIG_DIR="/etc/hysteria2"
BIN_PATH="/usr/local/bin/hysteria"

# 安装依赖
apk add --no-cache openssl wget

# 创建自签证书
mkdir -p $CONFIG_DIR
openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
    -keyout $CONFIG_DIR/server.key -out $CONFIG_DIR/server.crt \
    -subj "/CN=hy2-server" -days 3650

# 下载最新二进制
HY2_VER=$(wget -qO- "https://api.github.com/repos/apernet/hysteria/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
wget -O $BIN_PATH "https://github.com/apernet/hysteria/releases/download/$HY2_VER/hysteria-linux-amd64"
chmod +x $BIN_PATH

# 生成配置文件
cat > $CONFIG_DIR/config.yaml <<EOF
listen: :36712
tls:
  cert: $CONFIG_DIR/server.crt
  key: $CONFIG_DIR/server.key
auth:
  type: password
  password: $(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
obfs:
  type: salamander
  salamander:
    password: $(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
bandwidth:
  up: 1 gbps
  down: 1 gbps
EOF

# 创建OpenRC服务
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

# 输出客户端配置
echo "=== 客户端配置 ==="
echo "服务器IP: $(wget -qO- ifconfig.me)"
echo "端口: 36712"
echo "密码: $(grep password $CONFIG_DIR/config.yaml | awk '{print $2}')"
echo "混淆密码: $(grep salamander -A2 $CONFIG_DIR/config.yaml | tail -n1 | awk '{print $2}')"
echo "自签证书需手动关闭验证"
