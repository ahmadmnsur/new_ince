FROM debian:bookworm

RUN sed -i 's|deb.debian.org|ftp.de.debian.org|g' /etc/apt/sources.list.d/debian.sources

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-intl \
    php8.2-mbstring \
    php8.2-soap \
    php8.2-xml \
    php8.2-zip \
    gosu \
    curl \
    mariadb-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o wp-cli.phar https://github.com/wp-cli/wp-cli/releases/download/v2.8.0/wp-cli-2.8.0.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN mkdir -p /var/www/html /var/log /run/php && \
    chown -R www-data:www-data /var/www/html /var/log /run/php && \
    touch /var/log/php8.2-fpm.log && \
    chown www-data:www-data /var/log/php8.2-fpm.log && \
    chmod 664 /var/log/php8.2-fpm.log

EXPOSE 9000

WORKDIR /var/www/html

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm8.2", "-F", "-R"]
