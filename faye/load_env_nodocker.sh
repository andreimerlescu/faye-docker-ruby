#!/bin/bash

# Redis
export REDIS_HOST=localhost
export REDIS_PORT=6379
# REDIS_REQUIREPASS=strong-requirepass-password
export FAYE_REDIS_DATABASE=6

# Rack
export FAYE_TAG=faye
export FAYE_MOUNT=/faye
export FAYE_TIMEOUT=60

# Tokens
export FAYE_TOKENS_DIR=../tokens
export FAYE_TOKENS_JSON_FILE=development.json

# Thin
export FAYE_MAX_CONNECTIONS=512
export FAYE_MAX_PERSISTENT_CONNECTIONS=512
export RACK_ENV=development

# HTTP
export FAYE_BIND=0.0.0.0
export FAYE_HTTP_PORT=4242

# HTTPS
export FAYE_ENABLE_SSL=1
export FAYE_BIND_SSL=0.0.0.0
export FAYE_HTTPS_PORT=4443
export FAYE_SSL_DIR=../ssl
export FAYE_SSL_CRT_FILE=development.crt
export FAYE_SSL_KEY_FILE=development.key
export FAYE_SSL_CIPHER_FILTER=HIGH:!aNULL:!eNULL:!PSK:!RC4:!MD5:!aDH:!DH
export FAYE_SSL_DISABLE_VERIFY=1

