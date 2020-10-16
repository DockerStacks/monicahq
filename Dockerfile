FROM dockerstacks/php-fpm:7.3
LABEL maintainer="Naba Das(nabad600@gmail.com)"

RUN apt-get update && apt-get install -y sudo \
    && apt-get install -y git \
    && apt-get install -y nano \
    && apt-get install -y nodejs \
    && apt-get install -y npm \
    && apt-get install -y wget

RUN apt-get update && apt-get install -y libmagickwand-dev --no-install-recommends

#memory resize
RUN cd /usr/local/etc/php/conf.d/ && \
  echo 'memory_limit = -1' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini

VOLUME /var/www
COPY docker-entrypoint.sh \
     cron.sh \
     queue.sh \
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
