FROM jekyll/jekyll:latest as jekyll

# for the tag script
# presumably we could write in in ruby, but meh
RUN apk add --no-cache python3 tree

# DO NOT USE /srv/jekyll
# THERE'S A VOLUME in jekyll/jekyll:latest
# USING THAT LOCATION IS LIKE A BLACK HOLE FOR ANY FILES
# IN THERE
# we are building under our own rules, so we just work somewhere else
ENV JEKYLL_ENV      production

WORKDIR             /tmp/jekyll/
COPY    Gemfile*    /tmp/jekyll/
RUN     bundle install

# copy in all the local things
COPY    .           /tmp/jekyll/

# regenerate tags
RUN     bin/update-tags
RUN     tree /tmp/jekyll/

ARG jekyll_overrides
# set a default (of nothing) in case the ARG isn't passed
ENV JEKYLL_OVERRIDES=${jekyll_overrides:-}

# JEKYLL_OVERRIDES is set where required in 01.nginx.proxy/docker-compose.yml
RUN     echo Using: --config _config.yml,${JEKYLL_OVERRIDES}
RUN     jekyll build --destination /tmp/site --config _config.yml,${JEKYLL_OVERRIDES}
RUN     tree /tmp/site
RUN     date

###
### Next part of the multi-stage build
###

#-----
FROM    kyma/docker-nginx
COPY --from=jekyll /tmp/site/ /var/www
CMD     'nginx'
