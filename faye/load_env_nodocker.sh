#!/bin/bash

export REDIS_HOST=localhost
export REDIS_PORT=6379
# REDIS_REQUIREPASS=strong-requirepass-password
export FAYE_REDIS_DATABASE=6

export FAYE_TAG=faye
export FAYE_MOUNT=/faye
export FAYE_TIMEOUT=60

export FAYE_TOKENS_DIR=../tokens
export FAYE_TOKENS_JSON_FILE=development.json

export FAYE_THREADS_MIN=3
export FAYE_THREADS_MAX=6
export FAYE_WORKERS=9
export FAYE_PRELOAD_APP=1
export FAYE_ENVIRONMENT=development
export FAYE_BIND=0.0.0.0
export FAYE_HTTP_PORT=4242

export FAYE_ENABLE_SSL=1
export FAYE_BIND_SSL=0.0.0.0
export FAYE_HTTPS_PORT=4443
export FAYE_SSL_DIR=../ssl
export FAYE_SSL_CRT_FILE=development.crt
export FAYE_SSL_KEY_FILE=development.key
export FAYE_SSL_CIPHER_FILTER=HIGH:!aNULL:!eNULL:!PSK:!RC4:!MD5:!aDH:!DH
export FAYE_SSL_VERIFY_MODE=none
# FAYE_SSL_NO_TLSV1=true
# FAYE_SSL_NO_TLSV11=true
# FAYE_SSL_CA_FILE
