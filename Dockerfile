FROM php:8.1-apache

# 系统依赖（Bullseye 源仍活跃）
RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libonig-dev \
    && rm -rf /var/lib/apt/lists/*

# PHP 扩展：GD（含 WebP / JPEG / PNG / FreeType）
RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg \
    --with-webp \
    && docker-php-ext-install -j$(nproc) gd

# PHP 扩展：数据库与常用
RUN docker-php-ext-install -j$(nproc) \
    pdo_mysql \
    mbstring \
    fileinfo

# Apache 重写模块
RUN a2enmod rewrite

# 允许 .htaccess 覆盖
RUN echo '<Directory /var/www/html>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' > /etc/apache2/conf-available/allow-override.conf \
    && a2enconf allow-override

# PHP 上传大小限制
RUN echo "upload_max_filesize = 50M\n\
post_max_size = 55M\n\
max_execution_time = 120\n\
memory_limit = 256M" > /usr/local/etc/php/conf.d/uploads.ini

# 清理 PHP 8.1 默认的 DocumentRoot 硬编码（使 ENV APACHE_DOCUMENT_ROOT 生效）
RUN sed -ri -e 's!/var/www/html!/var/www/html!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf 2>/dev/null; exit 0

# 启动时自动生成数据库配置
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /var/www/html
EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
