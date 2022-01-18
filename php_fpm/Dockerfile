FROM php:7.4-fpm
ENV LANG C.UTF-8
MAINTAINER kwinwong kwinwong@foxmail.com

#change timezone to Asia/Shanghai
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN echo -e "alias ls='ls --color=auto'\nalias ll='ls -al'" >> /etc/bash.bashrc


#配置apt阿里云源
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list && rm -Rf /var/lib/apt/lists/* && cat /etc/apt/sources.list

RUN set -xe \
	&& apt-get update 

RUN sh -c '/bin/echo -e "\nyes\n\nyes" | apt-get upgrade'

# 
RUN set -xe \
  && apt-get install -y libfreetype6 libfreetype6-dev libjpeg-dev libpng-dev libjpeg62-turbo-dev 

RUN set -xe \  
	&& docker-php-ext-configure gd \
        	--with-freetype \
        	--with-jpeg

RUN set -xe \
	&& apt-get install -y git vim iputils-ping net-tools cron libssl-dev libzip-dev zlib1g-dev libmcrypt-dev


RUN set -xe \
	&& docker-php-ext-install zip pdo_mysql gd mysqli bcmath

# 配置opcache
RUN set -xe \
docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache

  #安装igbinary扩展
  RUN set -xe \
  && pecl install -o -f igbinary \ 
  && rm -rf /tmp/pear \ 
  && docker-php-ext-enable igbinary

  #安装redis扩展
  RUN set -xe \
  && pecl install -o -f redis \ 
  && rm -rf /tmp/pear \ 
  && docker-php-ext-enable redis

  #安装mongodb扩展
  RUN set -xe \
  && pecl install -o -f mongodb \ 
  && rm -rf /tmp/pear \ 
  && docker-php-ext-enable mongodb

# Install swoole
# RUN cd /root && pecl download swoole && \
# tar -zxvf swoole-4* && cd swoole-4* && \
# phpize && \
# ./configure --enable-openssl && \
# make && make install && \
# docker-php-ext-enable swoole


RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

#install composer
RUN php -r "copy('https://install.phpcomposer.com/installer', 'composer-setup.php');" \
  && php composer-setup.php \
	&& mv composer.phar /usr/local/bin/composer \
	&& composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

EXPOSE 9000 