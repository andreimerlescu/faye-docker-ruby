# Faye Docker (Ruby)

I spent a lot of time looking around the internet for a solution to using Faye in a manner that is scalable, separate from my existing application/service, and secure. Many examples I saw lacked supporting Faye behind SSL and even fewer projects openly supported SSL with Faye. Enter this project. I build this project for another project that I'm working on, but wanted to share the work I've done to offer a solution to getting a secure Faye setup for your system. Here's the architecture: 

## 1. Overview

1) **Redis**: Used for storing persistent information about clients<->subscriptions/channels. Setup includes support `requirepass` authentication into Redis.
2) **Faye**: Ruby based bayeaux with custom ServerAuth plugin that accepts publish messages with attached tokens (defined as JSON), host origin, and service name that boot into a thin client that has customizable options.
3) **Nginx**: Custom nginx configuration file that enables SSL proxy forwarding for the **Faye** service with HTTP/2 support.
4) **Docker**: Built a custom docker container for the **Faye** service and **Nginx** service.
5) **Docker Compose**: Included a deployable buildable (from source) copy of the entire project with example environment configuration files easily deployable using `Makefile` command `make run` (which is an alias for `docker-compose up -d --force-recreate --build`)

## 2. Configurations

### 2.1 Tokens

Tokens are effectively a JSON record that is used to add a layer of authentication between publishers and Faye itself. When using the docker container [amerlescucodez/docker-faye-ruby](https://hub.docker.com/r/amerlescucodez/docker-faye-ruby/tags) `docker pull amerlescucodez/docker-faye-ruby:latest` and tokens together, you must mount a directory into the configured *Faye* container. The structure of that file needs to appear as such: 

```json
{
  "ServiceName": {
    "origin": "http://localhost:3000",
    "auth_token": "yourSecretAuthToken"
  }
}
```

If you have a need for multiple tokens, then you would separate them out by `ServiceName` as such: 

```json
{
  "MyServiceOne": {
    "origin": "http://localhost:3000",
    "auth_token": "yourSecretAuthToken"
  },
  "MyServiceTwo": {
    "origin": "http://localhost:4000",
    "auth_token": "yourSecretAuthToken"
  }
}
```

In this package, the `docker-compose` file mounts the local `tokens/` directory relative to this project into the container as a volume.

This project is not configured to automatically detect token definitions, mounted volume locations, etc., therefore the use of the Docker Compose `env_file` directive is used. 

### 2.2 Dot ENV Files

Both **Nginx** and **Faye** containers rely on a series of environment variables that configure the respective services as you see fit. While using `docker-compose`, passing a `.env` file directly into the service definition is the fastest way to supply each and every variable. It is not required though, you can use `docker run ... -e VARIABLE=value ...` if you choose too, just note that all declared variables in this documentation are required. If any are omitted or misconfigured, the container may crash and cause problems. It is best to test the service completely prior to deploying it. 

#### 2.2.1 Faye `.env` Configuration

```
# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_REQUIREPASS=strong-requirepass-password # optional
FAYE_REDIS_DATABASE=6

# Application Environment
FAYE_ENVIRONMENT=development
RACK_ENV=development

# Rackup 
FAYE_TAG=faye
FAYE_MOUNT=/faye
FAYE_TIMEOUT=60

# Patching / Non-Docker (Local Only) Variable Loading Hack
FAYE_IS_DOCKER=1

# ServerAuth Tokens
FAYE_TOKENS_DIR=/path/to/your/tokens/relative/to/the/running/container
FAYE_TOKENS_JSON_FILE=your-tokens-filename.json

# Thin
FAYE_MAX_CONNECTIONS=1024
FAYE_MAX_PERSISTENT_CONNECTIONS=1024
FAYE_BIND=0.0.0.0
FAYE_HTTP_PORT=4242
```

#### 2.2.2 Nginx `.env` Configuration

```
# Host Related
FAYE_HOST=faye
FAYE_INTERNAL_PORT=4242
FAYE_HTTP_PORT=80
FAYE_SERVER_HOSTNAME=yourdomain.com

# Nginx
FAYE_WORKER_PROCESSES=9
FAYE_WORKER_CONNECTIONS=4096
FAYE_SENDFILE=off
FAYE_TCP_NOPUSH=on
FAYE_SERVER_NAMES_HASH_BUCKET_SIZE=128

# SSL Related
FAYE_USE_SSL=1
FAYE_HTTPS_PORT=443
FAYE_SSL_DIR=/root
FAYE_SSL_CERT_FILE=development.crt
FAYE_SSL_KEY_FILE=development.key
FAYE_SSL_PROTOCOLS=SSLv2 SSLv3 TLSv1
FAYE_SSL_CIPHERS=HIGH:!aNULL:!eNULL:!PSK:!RC4:!MD5:!aDH:!DH
FAYE_SSL_PREFER_SERVER_CIPHERS=on
```

> `FAYE_HOST` is the hostname of the *Faye* container. If you're using `docker-compose`, then specify the name of the service as it appears in the `links` configuration.

> If using SSL, ensure that the `FAYE_SSL_PROTOCOLS` and `FAYE_SSL_CIPHERS` match the specifications required by your Certificate Authority.

> If you're using a self signed certificate, don't bother. Faye won't establish a connection to a self signed certificate. If you need a cheap SSL certificate, I recommend using [SSLs.com](https://ssls.com/). They have a basic PositiveSSL certificate for sale for $3.77/Year and you can pay with Bitcoin. I do not make any commission on this message or recommendation. I am simply sharing with you a cheap solution to getting an SSL Certificate that you can use for development purposes that's signed and trusted by regular devices without requiring any special hacking on your part. 

> If your SSL certificate has a `ca-bundle` associated with it, you need to combine them into one file and use that combined file as the `FAYE_SSL_CERT_FILE`. For example: `cat mydomain.crt mydomain.ca-bundle > mydomain.combined.crt` then use the `mydomain.combined.crt` file for `FAYE_SSL_CERT_FILE`, just make sure you mount it into your container first.

## 3. Deployment

If you're looking to deploy this package into Docker Compose, then this compose template is a good place to start.

```yaml
version: '3.7'

services:
  redis:
    image: redis:alpine
    expose:
      - 6379
    restart: unless-stopped
    networks:
      - private

  faye:
    image: amerlescucodez/docker-faye-ruby:latest
    links:
      - redis
    depends_on:
      - redis
    expose:
      - 4242
    env_file:
      - ./faye/.env
    volumes:
      - ./tokens:/usr/local/faye/tokens
    networks:
      - private

  nginx:
    image: amerlescucodez/docker-faye-nginx:latest
    links:
      - faye
    depends_on:
      - faye
    ports:
      - 8080:80
      - 8443:443
    env_file:
      ./nginx/.env
    volumes:
      - ./ssl:/opt/ssl
    networks:
      - public
      - private

networks:
  public:
  private:
```

A couple of important things to note: 

1) `Redis` and `Faye` containers will not be accessible from outside of the defined `private` network as their ports are not being exposed to the host machine (or to the world for that matter).
2) Only the `Nginx` container is accessible to the rest of the world. Depending on how you want to connect to your faye instance, the nginx `.env` configurations should reflect the structure of the URL you use when connecting to faye. In this example the HTTPS port is 8443, and the `.env` domain is `yourdomain.com`, therefore when connecting to Faye you'd need to connect against `https://yourdomain.com:8443/faye`. If your `FAYE_MOUNT` is not `/faye`, and is something like `/bayeaux`, then you'd connect to `https://yourdomain.com:8443/bayeaux`.
2) SSL certificates are mounted directly into the Ngnix container. 
3) The Ngninx container is based on `nginx:1.17` (debian).
4) Do not use upstream nginx's container as it does not contain the required `entrypoint.sh` script that reads and generates your nginx config file based on the environment variables supplied in your `.env`.
5) In this example compose file, redis is not secured using `requirepass`, although this could be accomplished by mounting a config file via `docker-compose` as 

```
volumes:
- ./relative/path/to/redis.conf:/usr/local/etc/redis/redis.conf

OR

-v /myredis/conf/redis.conf:/usr/local/etc/redis/redis.conf
```

## 4. Use In Production

I am not offering any warranty or guarantee that this will work or be safe/secure in any kind of production environment. Please treat this project as a good place to start, and not the finished end-product that will serve all of your production needs. If you need something quick for a production environment, Faye may not be the best solution on the market. [Pusher](https://pusher.com) is an excellent service, but it is expensive. In my opinion $50/month for 500 connections is steep. That being said, if you are using this solution in production and would like free kudos or a shout out on this page, feel free to edit this page and submit a PR with your link below and I'll get it reviewed and approved for you. 

**Sites Using This Project**

1. <nothing yet - this is brand new>

## 5. Contributions

If you find a bug in this system, or have a recommendation/enhancement, etc. then please fork this respository, perform the necessary changes you wish to introduce in your own copy of the project, then when its ready submit a PR.

**Contributors**

1. [James Coglan](https://faye.jcoglan.com/)
2. [aMerlescuCodez](https://github.com/amerlescucodez)

