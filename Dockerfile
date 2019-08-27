FROM ruby:2.6.3
MAINTAINER Andrei Merlescu <andrei+github@merlescu.net>
RUN bundle config --global frozen 1
WORKDIR /usr/src/app
COPY faye/Gemfile Gemfile
COPY faye/Gemfile.lock Gemfile.lock
RUN gem install bundler
RUN bundle install
COPY faye/. .
CMD ["/usr/src/app/entrypoint.sh"]
