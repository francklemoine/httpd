FROM httpd:2.4.25
MAINTAINER Franck Lemoine <franck.lemoine@flem.fr>

ENV HTTPD_PREFIX /usr/local/apache2
ENV HTTPD_LOGDIR /var/log/httpd
ENV SSL_PREFIX /etc/apache2/ssl

RUN set -x \
	&& sed -ri ' \
	   s!^(\s*User\s+)\S+!\1www-data!g; \
	   s!^(\s*Group\s+)\S+!\1www-data!g; \
	   s!^#\s*(LoadModule proxy_module modules/mod_proxy\.so)!\1!g; \
	   s!^#\s*(LoadModule proxy_connect_module modules/mod_proxy_connect\.so)!\1!g; \
	   s!^#\s*(LoadModule proxy_http_module modules/mod_proxy_http\.so)!\1!g; \
	   s!^#\s*(LoadModule proxy_fcgi_module modules/mod_proxy_fcgi\.so)!\1!g; \
	   s!^#\s*(LoadModule vhost_alias_module modules/mod_vhost_alias\.so)!\1!g; \
	   s!^#\s*(LoadModule ssl_module modules/mod_ssl\.so)!\1!g; \
	   s!^#\s*(LoadModule socache_shmcb_module modules/mod_socache_shmcb\.so)!\1!g; \
	   s!^#\s*(LoadModule rewrite_module modules/mod_rewrite\.so)!\1!g; \
	   s!^#\s*(Include conf/extra/httpd-ssl.conf)!\1!g; \
	   s!^#\s*(Include conf/extra/httpd-default.conf)!\1!g; \
	   s!^#\s*(Include conf/extra/httpd-vhosts.conf)!\1!g; \
	   ' $HTTPD_PREFIX/conf/httpd.conf \
	&& sed -ri " \
	   s#^(\s*ErrorLog\s+)\S+#\1$HTTPD_LOGDIR/error_log#g; \
	   s#^(\s*CustomLog\s+)\S+#\1$HTTPD_LOGDIR/access_log#g; \
	   " $HTTPD_PREFIX/conf/httpd.conf \
	&& sed -ri ' \
	   $aIncludeOptional conf-enabled/*.conf \
	   ' $HTTPD_PREFIX/conf/httpd.conf \
	&& sed -ri ' \
	   s!^(\s*ServerTokens\s+)\S+!\1Prod!g; \
	   ' $HTTPD_PREFIX/conf/extra/httpd-default.conf \
	&& sed -ri ' \
	   /^<VirtualHost/,/<\/VirtualHost/{s/(.+)/#\1/g}; \
	   ' $HTTPD_PREFIX/conf/extra/httpd-ssl.conf \
	&& sed -ri ' \
	   /^<VirtualHost/,/<\/VirtualHost/{s/(.+)/#\1/g}; \
	   ' $HTTPD_PREFIX/conf/extra/httpd-vhosts.conf \
	&& mkdir -p $HTTPD_PREFIX/conf-enabled \
	&& mkdir -p $SSL_PREFIX \
	&& chown root:root $SSL_PREFIX \
	&& chmod 755 "$SSL_PREFIX" \
	&& mkdir -p "$HTTPD_LOGDIR" \
	&& chown root:root "$HTTPD_LOGDIR" \
	&& chmod 755 "$HTTPD_LOGDIR" \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/*

RUN chown root:www-data $HTTPD_PREFIX/conf-enabled

COPY httpd-foreground /usr/local/bin/
RUN chmod 755 /usr/local/bin/httpd-foreground

COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh

VOLUME ["$HTTPD_LOGDIR"]

EXPOSE 80 443

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["httpd-foreground"]

