FROM alpine:3.9

ENV LANG=C.UTF-8

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.

RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.29-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    echo \
        "-----BEGIN PUBLIC KEY-----\
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApZ2u1KJKUu/fW4A25y9m\
        y70AGEa/J3Wi5ibNVGNn1gT1r0VfgeWd0pUybS4UmcHdiNzxJPgoWQhV2SSW1JYu\
        tOqKZF5QSN6X937PTUpNBjUvLtTQ1ve1fp39uf/lEXPpFpOPL88LKnDBgbh7wkCp\
        m2KzLVGChf83MS0ShL6G9EQIAUxLm99VpgRjwqTQ/KfzGtpke1wqws4au0Ab4qPY\
        KXvMLSPLUp7cfulWvhmZSegr5AdhNw5KNizPqCJT8ZrGvgHypXyiFvvAH5YRtSsc\
        Zvo9GI2e2MaZyo9/lvb+LbLEJZKEQckqRj4P26gmASrZEPStwc+yqy1ShHLA0j6m\
        1QIDAQAB\
        -----END PUBLIC KEY-----" | sed 's/   */\n/g' > "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"

COPY ./instantclient /

ENV ORACLE_BASE /usr/lib/instantclient_12_1
ENV LD_LIBRARY_PATH /usr/lib/instantclient_12_1
ENV TNS_ADMIN /usr/lib/instantclient_12_1
ENV ORACLE_HOME /usr/lib/instantclient_12_1

RUN apk update \
    && apk add libaio \
    && unzip instantclient_12_1.zip \
    && mv instantclient_12_1/ /usr/lib/ \
    && rm instantclient_12_1.zip \
    && cp /usr/lib/instantclient_12_1/libclntsh.so.12.1 /usr/lib/instantclient_12_1/libclntsh.so \
    && cp /usr/lib/instantclient_12_1/libclntsh.so.12.1 /usr/lib/libclntsh.so \
    && cp /usr/lib/instantclient_12_1/libocci.so.12.1 /usr/lib/libocci.so \
    && cp /usr/lib/instantclient_12_1/libociei.so /usr/lib/libociei.so \
    && cp /usr/lib/instantclient_12_1/libnnz12.so /usr/lib/libnnz12.so \
    && cp /usr/lib/instantclient_12_1/libnnz12.so /usr/lib/instantclient_12_1/libnsl.so.1 \
    && apk add --no-cache \
        php7 \
        php7-phar \
        php7-dom \
        php7-dev \
        php7-pear \
        gcc musl-dev make \
    && php --version

COPY oci8-2.2.0.tgz .
RUN tar -xzvf oci8-2.2.0.tgz && cd oci8-2.2.0 && phpize && ./configure --with-oci8=shared,instantclient,/usr/lib/instantclient_12_1 && make && make install

COPY ./volume /

ENV ORACLE_BASE /usr/lib/instantclient_12_1
ENV LD_LIBRARY_PATH /usr/lib/instantclient_12_1
ENV TNS_ADMIN /usr/lib/instantclient_12_1
ENV ORACLE_HOME /usr/lib/instantclient_12_1

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache \
        libaio \
        nginx \
        nano \
        curl \
        supervisor \
        git \
        zip \
        unzip \
        php7 \
        php7-phar \
        php7-dom \
        php7-fpm \
        php7-mbstring \
        php7-mcrypt \
        php7-opcache \
        php7-pdo \
#        php7-pdo_mysql \
#        php7-pdo_pgsql \
        php7-pdo_sqlite \
        php7-pdo_odbc \
        php7-pdo_dblib \
#        php7-mongodb \
        php7-json \
        php7-xml \
        php7-xmlwriter \
        php7-xmlrpc \
        php7-xmlreader \
        php7-simplexml \
        php7-soap \
        php7-tokenizer \
        php7-openssl \
        php7-json \
        php7-curl \
        php7-ctype \
        php7-zlib \
        php7-posix \
        php7-pcntl \
        php7-iconv \
        php7-session \
    && echo 'extension=oci8.so' > /etc/php7/conf.d/oracle.ini \
    && addgroup -g 1000 -S www \
    && adduser -u 1000 -D -S -G www -h /app -g www www \
    && chown -R www:www /var/lib/nginx \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer \
    && php -m

WORKDIR /app

# portal
EXPOSE 80

# start
CMD ["/start.sh"]
