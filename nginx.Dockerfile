FROM nginx:1.17
MAINTAINER Andrei Merlescu <andrei+github@merlescu.net>
RUN mkdir -p /opt/{nginx,ssl}
WORKDIR /opt/nginx
COPY nginx/entrypoint.sh entrypoint.sh
CMD ["/opt/nginx/entrypoint.sh"]