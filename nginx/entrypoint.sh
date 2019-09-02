#!/bin/bash
set +x 

mkdir -p /var/www/faye

cat >/var/www/faye/index.html <<'EOF'
<!html>
<html>
<head>
<title>403 Forbidden</title>
</head>
<body>
<h1>403 Forbidden</h1>
</body>
</html>
EOF

cat >/var/www/faye/500.html <<'EOF'
<!html>
<html>
<head>
<title>500 System Error</title>
</head>
<body>
<h1>500 System Error</h1>
</body>
</html>
EOF

ssl_configurations=""
if [ "${FAYE_USE_SSL}" -eq "1" ]; then
	read -r -d '' ssl_configurations << EOF
		ssl_certificate ${FAYE_SSL_DIR}/${FAYE_SSL_CERT_FILE};
		ssl_certificate_key ${FAYE_SSL_DIR}/${FAYE_SSL_KEY_FILE};
		ssl_session_timeout  5m;
		ssl_protocols  ${FAYE_SSL_PROTOCOLS};
		ssl_ciphers  ${FAYE_SSL_CIPHERS};
		ssl_prefer_server_ciphers   ${FAYE_SSL_PREFER_SERVER_CIPHERS};
		ssl_session_cache shared:SSL:10m;

EOF
fi

read -r -d '' faye_proxy_configurations << EOF
		location @faye_puma {
			# Proxy Configurations
			proxy_http_version 1.1;
			proxy_redirect off;
			proxy_pass http://faye_puma;

			# Proxy Headers
			proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
			proxy_set_header X-Real-IP \$remote_addr;
			proxy_set_header X-Forwarded-Host \$server_name;
			proxy_set_header Host \$host;
			proxy_set_header X-Forwarded-Proto https;
			proxy_set_header Upgrade \$http_upgrade;
			proxy_set_header Connection \$connection_upgrade;
			
			# Request Headers
			add_header X-location websocket always;
			set \$cors '';
			if (\$http_origin ~ '${FAYE_HTTP_ORIGIN_REGEX}') {
				set \$cors 'true';
			}

			if (\$cors = 'true') {
				add_header 'Access-Control-Allow-Origin' "${FAYE_CORS_ORIGIN_URL}" always;
				add_header 'Access-Control-Allow-Credentials' 'true' always;
				add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS' always;
				add_header 'Access-Control-Allow-Headers' 'Accept,Authorization,Cache-Control,Content-Type,DNT,If-Modified-Since,Keep-Alive,Origin,User-Agent,X-Requested-With' always;
				
				# required to be able to read Authorization header in frontend
				#add_header 'Access-Control-Expose-Headers' 'Authorization' always;
			}
		}

EOF

read -r -d '' general_configurations << EOF
		add_header X-Content-Type-Options nosniff;
		add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
		
		error_page 500 502 503 504 /500.html;
		client_max_body_size 4G;
		keepalive_timeout 10;

		try_files \$uri/index.html \$uri @faye_puma;

EOF

ssl_server=""
if [ "${FAYE_USE_SSL}" -eq "1" ]; then
	read -r -d '' ssl_server << EOF
	server {
		listen  ${FAYE_HTTPS_PORT} http2 ssl;
		listen  [::]:${FAYE_HTTPS_PORT} http2 ssl;
		server_name ${FAYE_SERVER_HOSTNAME};
		root /var/www/faye;
	
		${ssl_configurations}

		${general_configurations}

		${faye_proxy_configurations}

	}

EOF
fi

cat >/root/nginx.conf <<EOF

worker_processes  ${FAYE_WORKER_PROCESSES};

daemon off;

events {
  worker_connections  ${FAYE_WORKER_CONNECTIONS};
}

http {

	map \$http_upgrade \$connection_upgrade {
		default upgrade;
		'' close;
	}

	sendfile     ${FAYE_SENDFILE};
	tcp_nopush   ${FAYE_TCP_NOPUSH};
	server_names_hash_bucket_size ${FAYE_SERVER_NAMES_HASH_BUCKET_SIZE};

	gzip              on;
	gzip_http_version 1.0;
	gzip_proxied      any;
	gzip_min_length   500;
	gzip_disable      "MSIE [1-6]\.";
	gzip_types        text/plain text/xml text/css
										text/comma-separated-values
										text/javascript
										application/x-javascript
										application/atom+xml;


	upstream faye_puma {
	  server ${FAYE_HOST}:${FAYE_INTERNAL_PORT} fail_timeout=0;
	}

	server {
	    listen ${FAYE_HTTP_PORT} http2;
	    listen [::]:${FAYE_HTTP_PORT} http2;
	    server_name ${FAYE_SERVER_HOSTNAME};
	    return 301 https://\$host\$request_uri;
	}

	${ssl_server}
}

EOF

cat /root/nginx.conf

nginx -v
nginx -t -c /root/nginx.conf
nginx -c /root/nginx.conf


