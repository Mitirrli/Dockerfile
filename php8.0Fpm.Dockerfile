# ------------------------------------------------------------------------------------
#                                  Local Dockerfile
# ------------------------------------------------------------------------------------
# @build-example docker-compose up -d
# ------------------------------------------------------------------------------------
FROM php:8.0.0alpha1-fpm-alpine

# 使用国内镜像
RUN echo http://mirrors.aliyun.com/alpine/v3.12/main>/etc/apk/repositories \
    && echo  http://mirrors.aliyun.com/alpine/v3.12/community>>/etc/apk/repositories

# 安装必须的包
 RUN apk add --no-cache icu-dev \
    oniguruma-dev \
    zlib-dev \
    curl-dev \
    libxml2-dev \
    libzip-dev \
    libpng-dev freetype \
    libpng \
    openssl-dev \
    libffi-dev \
    libjpeg-turbo \
    freetype-dev \
    libpng-dev \
    jpeg-dev \
    libjpeg \
    libjpeg-turbo-dev \
    gcc \
    g++ \
    make \
    autoconf

# 增加GD库
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/

# 安装一些必备的扩展
RUN docker-php-ext-install gd bcmath pdo_mysql mysqli opcache zip

# 安装composer
RUN wget https://mirrors.aliyun.com/composer/composer.phar -O /usr/local/bin/composer \
    && chmod a+x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer \
    && composer self-update --clean-backups

# phpredis及xlswriter版本
ENV PHPREDIS_VERSION=5.3.0RC2 \
    XLSWRITER_VERSION=1.3.6

# 安装redis扩展
RUN curl -fsSL "https://pecl.php.net/get/redis-${PHPREDIS_VERSION}.tgz" -o /tmp/redis.tgz \
    && mkdir -p /tmp/phpredis \
    && tar -xf /tmp/redis.tgz -C /tmp/phpredis --strip-components=1 \
    && rm /tmp/redis.tgz \
    && cd /tmp/phpredis \
    && phpize \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/phpredis \
    && docker-php-ext-enable redis \
# 安装xlswriter扩展
    && curl -fsSL "https://pecl.php.net/get/xlswriter-${XLSWRITER_VERSION}.tgz" -o /tmp/xlswriter.tgz \
    && mkdir -p /tmp/xlswriter \
    && tar -xf /tmp/xlswriter.tgz -C /tmp/xlswriter --strip-components=1 \
    && rm /tmp/xlswriter.tgz \
    && cd /tmp/xlswriter \
    && phpize \
    && ./configure --enable-reader \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/xlswriter \
    && docker-php-ext-enable xlswriter

# 设置工作目录
WORKDIR /opt/www

EXPOSE 5200
