FROM phusion/baseimage:jammy-1.0.0

CMD ["/sbin/my_init"]

RUN add-apt-repository -uy ppa:ondrej/php \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive \
  apt-get upgrade -y -o Dpkg::Options::="--force-confold" \
  && DEBIAN_FRONTEND=noninteractive \
  apt-get install -y \
  wget rsync \
  nginx mysql-client \
  git \
  unzip \
  php7.4-fpm php7.4-cli php7.4-curl php7.4-gd php7.4-imagick php7.4-mcrypt php7.4-mysql \
  php7.4-oauth php7.4-json php7.4-zip php7.4-opcache php7.4-mbstring php7.4-soap php7.4-xml \
  php7.4-xmlrpc php7.4-sybase php7.4-redis php7.4-xdebug php7.4-intl php7.4-imap \
  --no-install-recommends \
  && phpenmod opcache \
  && phpenmod redis \
  && phpenmod xdebug \
  && wget -O /tmp/composer-setup.php https://getcomposer.org/installer \
  && php /tmp/composer-setup.php --filename=composer --install-dir=/usr/local/bin \
  && apt-get clean \
  && echo "daemon off;" >> /etc/nginx/nginx.conf \
  && echo 'DAEMON_ARGS="-F --fpm-config /etc/php/7.4/fpm/php-fpm.conf"' > /etc/default/php-fpm7.4 \
  && mkdir -p /etc/service/nginx \
  && mkdir -p /etc/service/php-fpm \
  && mkdir -p /etc/php/7.4/local \
  && mkdir -p /var/www/html/sites \
  && chown -R root:root /var/www \
  && chmod -R go+rX-w /var/www

ADD start-nginx.sh /etc/service/nginx/run
ADD start-php-fpm.sh /etc/service/php-fpm/run
RUN chmod +x /etc/service/nginx/run /etc/service/php-fpm/run

RUN mkdir -p /etc/www-local-config
RUN ln -sf /etc/www-local-config/99-aaa-local.ini /etc/php/7.4/fpm/conf.d/99-aaa-local.ini \
 && ln -sf /etc/www-local-config/99-fpm-local.ini /etc/php/7.4/fpm/conf.d/99-fpm-local.ini \
 && ln -sf /etc/www-local-config/99-aaa-local.ini /etc/php/7.4/cli/conf.d/99-aaa-local.ini \
 && ln -sf /etc/www-local-config/99-cli-local.ini /etc/php/7.4/cli/conf.d/99-cli-local.ini \
 && rm -f /etc/php/7.4/fpm/php-fpm.conf \
 && ln -s /etc/www-local-config/php-fpm.conf /etc/php/7.4/fpm/php-fpm.conf \
 && rm -f /etc/nginx/sites-available/default \
 && ln -sf /etc/www-local-config/default-site.conf /etc/nginx/sites-available/default \
 && mkdir -p /run/php  
  
EXPOSE 80
