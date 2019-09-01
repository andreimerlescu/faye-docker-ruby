#!/bin/bash

if [ -z "${FAYE_IS_DOCKER}" ]; then
	echo "Loading env vars locally since not docker"
	source load_env_nodocker.sh
else
	echo "Need to patch a bug inside rack_adapter"
	PATCH_FILE=`find /. -type f -name 'rack_adapter.rb'`

	# sed -i 's/      hijack.close_write/      hijack.close_write if hijack.respond_to? :close_write/g' $PATCH_FILE
	# cat $PATCH_FILE
	echo "Done patching!"
fi 

# sed -i.bak s/hijack.close_write/hijack.close_write if hijack.respond_to? :close_write/g 

# thin --address "${FAYE_BIND}" \
# 		 --port "${FAYE_HTTP_PORT}" \
# 		 --environment "${FAYE_ENVIRONMENT}" \
# 		 --timeout "${FAYE_TIMEOUT}" \
# 		 --max-conns "${FAYE_MAX_CONNECTIONS}" \
# 		 --max-persistent-conns "${FAYE_MAX_CONCURRENT_CONNECTIONS}" \
# 		 -D start


# if [ "${FAYE_ENABLE_SSL}" -eq "1" ]; then
# 	if [ "${FAYE_SSL_DISABLE_VERIFY}" -eq "1" ]; then
# 		echo "SSL Enabled / Verify Disabled"
# 		thin --address ${FAYE_BIND} \
# 				 --port ${FAYE_HTTPS_PORT} \
# 				 --ssl \
# 				 --ssl-key-file "${FAYE_SSL_DIR}/${FAYE_SSL_KEY_FILE}" \
# 				 --ssl-cert-file "${FAYE_SSL_DIR}/${FAYE_SSL_CRT_FILE}" \
# 				 --ssl-disable-verify \
# 				 --environment "${FAYE_ENVIRONMENT}" \
# 				 --timeout ${FAYE_TIMEOUT} \
# 				 --max-conns ${FAYE_MAX_CONNECTIONS} \
# 				 --max-persistent-conns ${FAYE_MAX_CONCURRENT_CONNECTIONS} \
# 				 -D start
# 	else
# 		echo "SSL Enabled / Verify Enabled"
# 		thin --address "${FAYE_BIND}" \
# 				 --port "${FAYE_HTTPS_PORT}" \
# 				 --ssl \
# 				 --ssl-key-file "${FAYE_SSL_DIR}/${FAYE_SSL_KEY_FILE}" \
# 				 --ssl-cert-file "${FAYE_SSL_DIR}/${FAYE_SSL_CRT_FILE}" \
# 				 --environment "${FAYE_ENVIRONMENT}" \
# 				 --ssl-verify \
# 				 --timeout "${FAYE_TIMEOUT}" \
# 				 --max-conns "${FAYE_MAX_CONNECTIONS}" \
# 				 --max-persistent-conns "${FAYE_MAX_CONCURRENT_CONNECTIONS}" \
# 				 -D start
# 	fi
# fi

puma -C puma.rb
