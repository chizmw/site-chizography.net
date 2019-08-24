FROM jekyll/jekyll:latest as jekyll

# for the tag script
# presumably we could write in in ruby, but meh
RUN apk add --no-cache python3

WORKDIR             /srv/jekyll/

COPY bin/jekyll-tagger /srv/jekyll/bin/jekyll-tagger

ENV GEM_HOME        /tmp/gems
ENV PATH            /tmp/gems/bin:$PATH

COPY    Gemfile     /srv/jekyll/
RUN     bundle install

COPY    .            /srv/jekyll/

# regenerate tags
RUN rm -v /srv/jekyll/tag/*md \
 && /srv/jekyll/bin/jekyll-tagger \
 && ls -l /srv/jekyll/tag

ENV     JEKYLL_ENV      production
RUN     jekyll build --destination /tmp/site
RUN     ls -larth /tmp/site

RUN apk add tree && tree /srv/jekyll && tree /tmp/site

#-----
FROM    kyma/docker-nginx

COPY --from=jekyll /tmp/site/ /var/www
RUN     ls -l /var/www

CMD     'nginx'
