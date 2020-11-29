FROM chizcw/jekyll-site-base:54e93166 as jekyll-composed

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

# tag "debugging"
RUN ls -lah /tmp/jekyll/dest/tag

#-----
FROM    kyma/docker-nginx

COPY --from=jekyll-composed /tmp/jekyll/dest/ /var/www
RUN     ls -lah /var/www
# tag "debugging"
RUN     ls -lah /var/www/tag

CMD     'nginx'
