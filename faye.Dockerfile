FROM ruby:2.6
MAINTAINER Andrei Merlescu <andrei+github@merlescu.net>
# RUN bundle config --global frozen 1 # uncomment for production
RUN mkdir -p /usr/local/faye/{app,tokens} && mkdir -p /etc/ssl/certs/faye
WORKDIR /usr/local/faye/app
COPY faye/Gemfile Gemfile
COPY faye/Gemfile.lock Gemfile.lock
RUN gem install bundler
RUN bundle install
COPY faye/. .
CMD ["/usr/local/faye/app/entrypoint.sh"]
