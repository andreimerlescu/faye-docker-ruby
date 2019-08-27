# Faye Docker (Ruby)


### Environment Variables

| **Variable Name** | Default Value | _Purpose_ |
|-------------------|---------------|-----------|
| `FAYE_THREADS_MIN` | `3` | How many threads do you want puma to run on (minimum)? |
| `FAYE_THREADS_MAX` | `6` | How many threads are too many? |
| `FAYE_WORKERS` | `9` | How many workers do you want processing requests into Faye? |
| `FAYE_PRELOAD_APP` | `YES` | Do you want to preload the application into memory so it runs faster? |
| `FAYE_TAG` | `faye` | What do you want to call this instance of `puma`? |
| `FAYE_ENVIRONMENT` | `development` | Useful for debugging or logging purposes. |
| `FAYE_BIND` | `0.0.0.0` | Which IP address do you want the service to bind to? Default is `0.0.0.0` which is externally accessible. For localhost only, use `127.0.0.1` |
| `FAYE_HTTP_PORT` | `4242` | Default `tcp` port of `4242` for non-encrypted Faye communication. |
| `FAYE_ENABLE_SSL` | `NO` | Optional flag. When enabled, requires a majority of the options below. Checked for `YES` values including `%w{YES Yes Y yes y 1 true si da ja}` |
| `FAYE_BIND_SSL` | `0.0.0.0` | **Required if `FAYE_ENABLE_SSL=1`** Which IP address do you want the service to bind to? Default is `0.0.0.0` which is externally accessible. For localhost only, use `127.0.0.1` |
| `FAYE_HTTPS_PORT` | `4443` | **Required if `FAYE_ENABLE_SSL=1`** |
| `FAYE_SSL_CRT_FILE` | `nil` | **Required if `FAYE_ENABLE_SSL=1`** |
| `FAYE_SSL_KEY_FILE` | `nil` | **Required if `FAYE_ENABLE_SSL=1`** |
| `FAYE_SSL_CIPHER_FILTER` | `nil` | For security purposes, you may want to block unsafe ciphers. Possible setting (not recommended for liability purposes) is `HIGH:!aNULL:!eNULL:!PSK:!RC4:!MD5:!aDH:!DH`. |
| `FAYE_SSL_VERIFY_MODE` | `none` | Will fail if left to default and certificate is self-signed. |
| `FAYE_SSL_NO_TLSV1` | `false` | Optional flag. Checked for `YES` values including `%w{YES Yes Y yes y 1 true si da ja}` |
| `FAYE_SSL_NO_TLSV11` | `false` | Optional flag. Checked for `YES` values including `%w{YES Yes Y yes y 1 true si da ja}` |
| `FAYE_SSL_CA_FILE` | `nil` | Required if `FAYE_SSL_VERIFY_MODE` is `peer` or `force_peer`. |

