FROM lisotton/php-apache:5.6.7

RUN a2enmod rewrite
RUN a2enmod ssl

RUN mv /etc/apache2/mods-available/ssl.conf /etc/apache2/mods-available/ssl.conf.dist \
  && mkdir -p /etc/apache2/ssl
COPY ssl.conf /etc/apache2/mods-available/
COPY localhost.* /etc/apache2/ssl/
COPY drupal.ini /usr/local/etc/php/conf.d/

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev libmcrypt-dev libxml2-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-configure mcrypt --with-mcrypt \
	&& docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql zip mcrypt soap

WORKDIR /var/www/html

# https://www.drupal.org/node/3060/release
ENV DRUPAL_VERSION 6.38
ENV DRUPAL_MD5 2ece34c3bb74e8bff5708593fa83eaac

RUN curl -fSL "http://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz" -o drupal.tar.gz \
	&& echo "${DRUPAL_MD5} *drupal.tar.gz" | md5sum -c - \
	&& tar -xz --strip-components=1 -f drupal.tar.gz \
	&& rm drupal.tar.gz \
	&& chown -R www-data:www-data sites

EXPOSE 80 443
CMD ["apache2-foreground"]
