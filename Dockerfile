FROM ruby:2.6-alpine
MAINTAINER Andrei Merlescu <andrei+github@merlescu.net>
RUN bundle config --global frozen 1
WORKDIR /usr/src/app
COPY faye/Gemfile Gemfile
RUN bundle install
COPY faye/. .
CMD ["/usr/src/app/entrypoint.sh"]
