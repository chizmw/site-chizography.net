FROM jekyll/jekyll:latest as jekyll

# for the tag script
# presumably we could write in in ruby, but meh
RUN apk add --no-cache python3 tree

WORKDIR             /srv/jekyll/

ENV GEM_HOME        /tmp/gems
ENV PATH            /tmp/gems/bin:$PATH

COPY    Gemfile     /srv/jekyll/
RUN     bundle install

COPY    .           /srv/jekyll/

# regenerate tags
RUN echo weird shit happening - need to investigate
RUN bin/update-tags

ENV     JEKYLL_ENV      production
RUN     jekyll build --verbose --destination /tmp/site

RUN tree /srv/jekyll && tree /tmp/site

#-----
FROM    kyma/docker-nginx
COPY --from=jekyll /tmp/site/ /var/www
CMD     'nginx'
