# httpd
Docker image with some httpd modules :

  - proxy_module
  - proxy_connect_module
  - proxy_http_module
  - proxy_fcgi_module
  - vhost_alias_module
  - ssl_module
  - socache_shmcb_module
  - rewrite_module

Add your Apache configuration files according to needs into :

  - $HTTPD_PREFIX/conf/extra
  - $HTTPD_PREFIX/conf-enabled

## Usage

```
docker run -d \
           --name myHttpdContainer
           -e SERVERNAME=foo
           -e SERVERADMIN=admin@foo
           -p 80:80
           -p 443:443
           --volumes-from otherContainer
           flem/httpd
```


```
docker cp httpd-vhosts.conf myHttpdContainer:/usr/local/apache2/conf/extra/
docker cp 020-httpd-ssl-dokuwiki.conf myHttpdContainer:/usr/local/apache2/conf-enabled/
docker stop myHttpdContainer
docker start myHttpdContainer
```
