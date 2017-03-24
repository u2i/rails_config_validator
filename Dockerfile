FROM ruby:2.3
MAINTAINER Michał Knapik <michal.knapik@u2i.com>

RUN wget --quiet --output-document=dumb-init.deb \
      https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64.deb && \
  dpkg --install dumb-init.deb && \
  apt-get update && apt-get --yes install cmake && \
  rm dumb-init.deb

RUN bundle config --global jobs 4

WORKDIR /code

ADD Gemfile /code
ADD rails_config_validator.gemspec /code
ADD lib/rails_config_validator/version.rb /code/lib/rails_config_validator/version.rb
RUN bundle install
ADD . /code

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["tail", "-f", "/dev/null"]
