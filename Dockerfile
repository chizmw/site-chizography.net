FROM jekyll/jekyll:4 as jekyll

# for the tag script
# presumably we could write in in ruby, but meh
RUN apk add --no-cache python3 tree

# DO NOT USE /srv/jekyll
# THERE'S A VOLUME in jekyll/jekyll:latest
# USING THAT LOCATION IS LIKE A BLACK HOLE FOR ANY FILES
# IN THERE
# we are building under our own rules, so we just work somewhere else
ENV TZ=UTC
ENV JEKYLL_ENV      production
ENV JEKYLL_SRC      /tmp/jekyll/src/
ENV JEKYLL_DEST     /tmp/jekyll/dest/

RUN sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd
RUN useradd --create-home --shell /bin/bash jsite
USER jsite

WORKDIR             ${JEKYLL_DEST}
WORKDIR             ${JEKYLL_SRC}

COPY    Gemfile*    ${JEKYLL_SRC}
RUN     bundle install --full-index

# copy in all the local things
COPY    .           ${JEKYLL_SRC}

USER root
RUN  chown -R jsite: ${JEKYLL_SRC}
RUN  chown -R jsite: ${JEKYLL_DEST}
USER jsite

# regenerate tags
RUN     bin/update-tags
RUN     tree ${JEKYLL_SRC}

ARG jekyll_overrides
# set a default (of nothing) in case the ARG isn't passed
ENV JEKYLL_OVERRIDES=${jekyll_overrides:-}

# JEKYLL_OVERRIDES is set where required in 01.nginx.proxy/docker-compose.yml
RUN     echo Using: --config _config.yml,${JEKYLL_OVERRIDES}
RUN     jekyll build --trace --destination ${JEKYLL_DEST} --config _config.yml,${JEKYLL_OVERRIDES}
RUN     tree ${JEKYLL_DEST}
RUN     date

###
### Next part of the multi-stage build
###

#-----
FROM    kyma/docker-nginx
COPY --from=jekyll /tmp/jekyll/dest /var/www
CMD     'nginx'
