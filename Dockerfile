FROM php:7.3-apache
ENV LANG C.UTF-8
MAINTAINER kwinwong kwinwong@foxmail.com

#change timezone to Asia/Shanghai
#RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN echo -e "alias ls='ls --color=auto'\nalias ll='ls -al'" >> /etc/bash.bashrc


#RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
#ADD sources.list etc/apt/sources.list

#配置apt阿里云源
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak
RUN sed -i "s@http://deb.debian.org@http://mirrors.aliyun.com@g" /etc/apt/sources.list && rm -Rf /var/lib/apt/lists/* && cat /etc/apt/sources.list

RUN set -xe \
	&& apt-get update 

RUN sh -c '/bin/echo -e "\nyes\n\nyes" | apt-get upgrade'
#runtime deps
RUN set -xe \
	&& apt-get install -y git vim iputils-ping net-tools cron libssl-dev libzip-dev zlib1g-dev libfreetype6 libfreetype6-dev libmcrypt-dev libjpeg-dev libpng-dev

RUN set -xe \
	&& docker-php-ext-configure gd \
#        	--enable-gd-native-ttf \
        	--with-freetype-dir=/usr/include/freetype2 \
        	--with-png-dir=/usr/include \
        	--with-jpeg-dir=/usr/include \
	&& docker-php-ext-install zip pdo_mysql gd mysqli bcmath

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


# Install swoole
RUN cd /root && pecl download swoole && \
tar -zxvf swoole-4* && cd swoole-4* && \
phpize && \
./configure --enable-openssl && \
make && make install && \
docker-php-ext-enable swoole


# ENV APACHE_DOCUMENT_ROOT /var/www/html/public
#
RUN set -xe \
	&& sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
	&& sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf 

RUN set -xe \
	&& ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/

#install composer
RUN curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer \
	&& composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

EXPOSE 80 443