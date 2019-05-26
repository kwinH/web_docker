FROM php:7.3-apache
ENV LANG C.UTF-8
MAINTAINER kwinwong kwinwong@foxmail.com


#change timezone to Asia/Shanghai
#RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN echo -e "alias ls='ls --color=auto'\nalias ll='ls -al'" >> /etc/bash.bashrc

#runtime deps
RUN set -xe \
	&& apt-get update \
	&& apt-get install -y git vim iputils-ping net-tools cron libssl-dev libzip-dev zlib1g-dev mysql-client libfreetype6 libfreetype6-dev libmcrypt-dev libjpeg-dev libpng-dev

RUN set -xe \
	&& docker-php-ext-configure gd \
#        	--enable-gd-native-ttf \
        	--with-freetype-dir=/usr/include/freetype2 \
        	--with-png-dir=/usr/include \
        	--with-jpeg-dir=/usr/include \
	&& docker-php-ext-install zip pdo_mysql gd mysqli



# ENV APACHE_DOCUMENT_ROOT /var/www/html/public
#
RUN set -xe \
	&& sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
	&& sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf 

RUN set -xe \
	&& ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/

#install composer
RUN && curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/local/bin/composer


EXPOSE 80 443