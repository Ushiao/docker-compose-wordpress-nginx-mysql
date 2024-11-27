#!/bin/bash

# 一键部署脚本

# 确保脚本在项目根目录下运行
if [ ! -f "docker-compose.yaml" ]; then
  echo "请在项目根目录下运行该脚本！"
  exit 1
fi

# 提示用户配置 .env 文件
echo "请输入数据库相关配置："
read -p "数据库名称 (TAGWORD_DB_NAME) [wordpress_tagword]: " TAGWORD_DB_NAME
TAGWORD_DB_NAME=${TAGWORD_DB_NAME:-wordpress_tagword}

read -p "数据库用户名 (TAGWORD_DB_USER) [wordpress_user]: " TAGWORD_DB_USER
TAGWORD_DB_USER=${TAGWORD_DB_USER:-wordpress_user}

read -p "数据库密码 (TAGWORD_DB_PASSWORD): " TAGWORD_DB_PASSWORD

read -p "数据库根密码 (TAGWORD_DB_ROOT_PASSWORD): " TAGWORD_DB_ROOT_PASSWORD

# 提示用户配置 SSL 信息
echo "请输入 SSL 配置："
read -p "请输入域名 (DOMAIN_NAME) [tagword.tech]: " DOMAIN_NAME
DOMAIN_NAME=${DOMAIN_NAME:-tagword.tech}

read -p "请输入 SSL 邮箱 (SSL_EMAIL): " SSL_EMAIL

# 创建 .env 文件
echo "生成 .env 文件..."
cat <<EOL > .env
# WordPress 数据库配置
TAGWORD_DB_NAME=${TAGWORD_DB_NAME}
TAGWORD_DB_USER=${TAGWORD_DB_USER}
TAGWORD_DB_PASSWORD=${TAGWORD_DB_PASSWORD}
TAGWORD_DB_ROOT_PASSWORD=${TAGWORD_DB_ROOT_PASSWORD}

# 域名配置
DOMAIN_NAME=${DOMAIN_NAME}
SSL_EMAIL=${SSL_EMAIL}
EOL

echo ".env 文件创建完成！"

# 拉取最新镜像并启动容器
echo "启动 Docker 容器..."
docker-compose up -d

# 获取 SSL 证书
echo "生成 SSL 证书..."
docker exec -it certbot certbot certonly --webroot --webroot-path=/var/www/certbot --email ${SSL_EMAIL} --agree-tos --no-eff-email -d ${DOMAIN_NAME} -d www.${DOMAIN_NAME}

# 提示部署完成
echo "一键部署完成！访问 https://${DOMAIN_NAME} 即可查看您的网站。"

