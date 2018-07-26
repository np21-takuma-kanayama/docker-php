FROM php:5.6-apache

# install gd
RUN apt-get update && apt-get install -y \
    libpng-dev \
    wget \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 \
 && cd /usr/local/src \
 && wget http://www.ijg.org/files/jpegsrc.v9b.tar.gz \
 && tar -zxvf jpegsrc.v9b.tar.gz \
 && rm jpegsrc.v9b.tar.gz \
 && cd jpeg-9b/ \
 && ./configure --enable-shared \
 && make \
 && make install \
 && cd /var/www/html \
 && rm -rf /usr/local/src/jpeg-9b/ \
 \
 && docker-php-ext-configure gd --with-jpeg-dir=/usr/local/lib/ \
 && docker-php-ext-install gd \
 \
 && apt-get purge -y \
    wget \
    libpng-dev

# install other
RUN docker-php-ext-install \
    mbstring \
    pdo_mysql \
    zip

# apache2
COPY ./init/default.conf /etc/apache2/sites-available/default.conf
RUN a2ensite default \
 && a2dissite 000-default
COPY ./init/ssi.conf /etc/apache2/conf-available/ssi.conf
RUN a2enconf ssi \
 && a2enmod rewrite

# start
EXPOSE 80
CMD ["apache2-foreground"]
