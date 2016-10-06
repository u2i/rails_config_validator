FROM ruby:2.3
MAINTAINER Michał Knapik <michal.knapik@u2i.com>

RUN wget --quiet --output-document=dumb-init.deb \
      https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64.deb && \
  dpkg --install dumb-init.deb && \
  rm dumb-init.deb

ARG host_uid
RUN (getent passwd $host_uid > /dev/null) || adduser  --quiet --disabled-password --gecos '' dummy --uid $host_uid

RUN mkdir -p /gems && chown $host_uid /gems
VOLUME /gems

USER $host_uid

RUN bundle config --global jobs 4

WORKDIR /code

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["tail", "-f", "/dev/null"]
