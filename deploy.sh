#!/bin/bash

# 一键部署脚本

# 确保脚本在项目根目录下运行
if [ ! -f "docker-compose.yaml" ]; then
  echo "请在项目根目录下运行该脚本！"
  exit 1
fi

# 提示用户配置 .env 文件
echo "请输入数据库相关配置："
read -p "数据库名称 (DB_NAME) [wordpress_db]: " DB_NAME
DB_NAME=${DB_NAME:-wordpress_db}

read -p "数据库用户名 (DB_USER) [wordpress_user]: " DB_USER
DB_USER=${DB_USER:-wordpress_user}

read -p "数据库密码 (DB_PASSWORD): " DB_PASSWORD

read -p "数据库根用户(root)密码 (DB_ROOT_PASSWORD): " DB_ROOT_PASSWORD

# 提示用户配置 SSL 信息
echo "请输入 SSL 配置："
read -p "请输入域名 (DOMAIN_NAME) [example.com]: " DOMAIN_NAME
DOMAIN_NAME=${DOMAIN_NAME:-example.com}

read -p "请输入邮箱 (EMAIL): " SSL_EMAIL

# 创建 .env 文件
echo "生成 .env 文件..."
cat <<EOL > .env
# WordPress 数据库配置
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}

# 域名配置
DOMAIN_NAME=${DOMAIN_NAME}
SSL_EMAIL=${SSL_EMAIL}
EOL

echo ".env 文件创建完成！"

# 检查 .env 文件是否生成成功
if [ ! -f ".env" ]; then
  echo "错误：.env 文件创建失败！"
  exit 1
else
  echo ".env 文件生成成功。"
fi

# 生成 nginx.conf 文件
echo "生成 nginx.conf 文件..."
cp ./nginx.conf.sample ./nginx.conf
sed -i "s/\${DOMAIN_NAME}/$DOMAIN_NAME/g" ./nginx.conf
if [ $? -ne 0 ]; then
  echo "错误：修改 nginx.conf 文件失败！"
  exit 1
else
  echo "nginx.conf 文件已成功生成。"
fi

# 检查是否存在所需镜像
required_images=("nginx" "wordpress" "mysql" "certbot")

for image in "${required_images[@]}"; do
  # 检查镜像是否存在
  if ! docker images "$image" | grep -q "$image"; then
    echo "镜像 $image 不存在，正在拉取镜像..."
    docker-compose pull "$image"
    if [ $? -ne 0 ]; then
      echo "错误：拉取镜像 $image 失败！"
      exit 1
    fi
  else
    echo "镜像 $image 已存在，跳过拉取。"
  fi
done

# 启动 Docker 容器
echo "启动 Docker 容器..."
docker-compose up -d
if [ $? -ne 0 ]; then
  echo "错误：启动 Docker 容器失败！"
  exit 1
fi

# 检查容器是否启动成功
docker ps | grep "nginx\|wordpress_tagword\|db_tagword"
if [ $? -ne 0 ]; then
  echo "错误：容器启动失败！"
  exit 1
else
  echo "Docker 容器已成功启动！"
fi

# 获取 SSL 证书
echo "生成 SSL 证书..."
docker exec -it certbot certbot certonly --webroot --webroot-path=/var/www/certbot --email ${SSL_EMAIL} --agree-tos --no-eff-email -d ${DOMAIN_NAME} -d www.${DOMAIN_NAME}
if [ $? -ne 0 ]; then
  echo "错误：获取 SSL 证书失败！"
  exit 1
fi

# 修改 nginx.conf 启用 HTTPS 配置
echo "启用 Nginx 443 HTTPS 配置..."

# 使用 sed 删除注释符号（#）并启用 443 配置
sed -i 's/#\s*\(listen 443 ssl http2;\)/\1/' ./nginx.conf
sed -i 's/#\s*\(ssl_certificate\)/\1/' ./nginx.conf
sed -i 's/#\s*\(ssl_certificate_key\)/\1/' ./nginx.conf

# 重新加载 Nginx 配置
echo "重新加载 Nginx 配置..."
docker exec -it nginx nginx -s reload
if [ $? -ne 0 ]; then
  echo "错误：重新加载 Nginx 配置失败！"
  exit 1
fi

# 提示部署完成
echo "一键部署完成！访问 https://${DOMAIN_NAME} 即可查看您的网站。"

