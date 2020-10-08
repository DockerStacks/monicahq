FROM dockerstacks/php-fpm
LABEL maintainer="Naba Das(nabad600@gmail.com)"

RUN apt-get update && apt-get install -y sudo \
    && apt-get install -y git \
    && apt-get install -y nano \
    && apt-get install -y nodejs \
    && apt-get install -y npm \
    && apt-get install -y wget

RUN apt-get update && apt-get install -y libmagickwand-dev --no-install-recommends
RUN printf "\n" | pecl install imagick
RUN docker-php-ext-enable imagick

RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini && \
    { \
        echo 'upload_max_filesize = 10M'; \
        echo 'post_max_size = 10M'; \
    } > /usr/local/etc/php/conf.d/upload-size.ini && \
    echo 'extension=imagick.so' > /usr/local/etc/php/conf.d/imagick.ini


VOLUME /var/www
COPY docker-entrypoint.sh \
     .env \
    /usr/local/bin/
#RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh
#ENTRYPOINT ["sh", "/usr/local/bin/docker-entrypoint.sh"]
#ENTRYPOINT ["docker-entrypoint.sh"]
#CMD ["run"]
ENTRYPOINT ["sh", "/usr/local/bin/docker-entrypoint.sh"]
CMD ["php-fpm"]

#WORKDIR /var/www
#EXPOSE 9000
