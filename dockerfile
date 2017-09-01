FROM ubuntu:14.04
MAINTAINER Linhtq <linhtq@topica.edu.vn>

ENV DEBIAN_FRONTEND noninteractive
WORKDIR /var/www/html



ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

EXPOSE 80
RUN apt-get update && \
	apt-get -y install mysql-client pwgen python-setuptools curl git unzip apache2 php5 \
		php5-gd libapache2-mod-php5 postfix wget supervisor php5-pgsql curl libcurl3 \
		libcurl3-dev php5-curl php5-xmlrpc php5-intl php5-mysql php5-mcrypt git-core wget && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html 
#Install google mod_pagespeed 
RUN wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb
RUN dpkg -i mod-pagespeed-*.deb
RUN apt-get -f install
RUN apt-get -y remove wget
RUN rm mod-pagespeed-*.deb
RUN apt-get clean
RUN /bin/ln -sf ../sites-available/default-ssl /etc/apache2/sites-enabled/001-default-ssl
RUN /bin/ln -sf ../mods-available/ssl.conf /etc/apache2/mods-enabled/
RUN /bin/ln -sf ../mods-available/ssl.load /etc/apache2/mods-enabled/
RUN /bin/ln -sf ../mods-available/socache_shmcb.load /etc/apache2/mods-enabled/
RUN sed -i "s/upload_max_filesize.*/upload_max_filesize = 30M/g" /etc/php5/apache2/php.ini
RUN sed -i "s/short_open_tag = Off/short_open_tag = On/g" /etc/php5/apache2/php.ini
RUN echo "extension=mcrypt.so" > /etc/php5/mods-available/mcrypt.ini

#RUN touch /usr/local/etc/php/conf.d/upload-limit.ini \ && echo "upload_max_filesize = 32M" >> /usr/local/etc/php/conf.d/upload-limit.ini \ && echo "post_max_size = 32M" >> /usr/local/etc/php/conf.d/upload-limit.ini
RUN a2enmod rewrite && a2enmod ssl
RUN php5enmod mcrypt
RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf
COPY boot.sh /home/
RUN chmod +x /home/boot.sh
CMD ["/home/boot.sh"]
