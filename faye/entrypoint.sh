#!/bin/bash

if [ -z "${FAYE_IS_DOCKER}" ]; then
	echo "Loading env vars locally since not docker"
	source load_env_nodocker.sh
else
	echo "Need to patch a bug inside rack_adapter"
	PATCH_FILE=`find /. -type f -name 'rack_adapter.rb'`

	sed -i 's/      hijack.close_write/      hijack.close_write if hijack.respond_to? :close_write/g' $PATCH_FILE
	echo "Done patching!"
fi 

thin --address "${FAYE_BIND}" \
		 --port "${FAYE_HTTP_PORT}" \
		 --environment "${FAYE_ENVIRONMENT}" \
		 --timeout "${FAYE_TIMEOUT}" \
		 --max-conns "${FAYE_MAX_CONNECTIONS}" \
		 --max-persistent-conns "${FAYE_MAX_PERSISTENT_CONNECTIONS}" \
		 -q start

