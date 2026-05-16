#!/bin/bash
set -e

# 自动生成数据库配置文件（从环境变量读取）
DB_CONFIG="/var/www/html/config/database.php"
if [ ! -f "$DB_CONFIG" ]; then
    echo ">>> 自动创建 config/database.php ..."
    cat > "$DB_CONFIG" << 'DATABASEEOF'
<?php
return [
    'host'     => 'DB_HOST_PLACEHOLDER',
    'port'     => 3306,
    'dbname'   => 'DB_NAME_PLACEHOLDER',
    'charset'  => 'utf8mb4',
    'username' => 'DB_USER_PLACEHOLDER',
    'password' => 'DB_PASS_PLACEHOLDER',
];
DATABASEEOF

    sed -i "s/DB_HOST_PLACEHOLDER/${DB_HOST:-db}/g" "$DB_CONFIG"
    sed -i "s/DB_NAME_PLACEHOLDER/${DB_NAME:-love_story}/g" "$DB_CONFIG"
    sed -i "s/DB_USER_PLACEHOLDER/${DB_USER:-love_story}/g" "$DB_CONFIG"
    sed -i "s/DB_PASS_PLACEHOLDER/${DB_PASS:-love_story_dev}/g" "$DB_CONFIG"
    echo ">>> database.php 已生成。"
fi

# 标记已安装
if [ ! -f "/var/www/html/.installed" ]; then
    touch /var/www/html/.installed
    echo ">>> .installed 标记已创建。"
fi

# 确保 uploads 目录可写
mkdir -p /var/www/html/uploads
chown -R www-data:www-data /var/www/html/uploads

exec apache2-foreground
