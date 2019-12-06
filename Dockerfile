FROM jekyll-base:composed as jekyll-composed

# inherit lots of ONBUILD magic
# if we haven't changed anything upstream our generated site will be output to
# /tmp/jekyll/dest/

# for the tag script
# presumably we could write in in ruby, but meh
USER root
RUN apk add --no-cache python3 tree
USER jsite

# regenerate tags
RUN     bin/update-tags
RUN     tree ${JEKYLL_SRC}

#-----
FROM    kyma/docker-nginx

COPY --from=jekyll-composed /tmp/jekyll/dest/ /var/www
RUN     ls -lah /var/www

CMD     'nginx'
