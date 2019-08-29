threads (ENV['FAYE_THREADS_MIN'] || 3).to_i, (ENV['FAYE_THREADS_MAX'] || 15).to_i
workers (ENV['FAYE_WORKERS'] || 9).to_i
if ENV['FAYE_PRELOAD_APP'] && %w{YES Yes Y yes y 1 true si da ja}.include?(ENV['FAYE_PRELOAD_APP'])
	preload_app!
end
tag (ENV['FAYE_TAG'] || 'faye').to_s
environment (ENV['FAYE_ENVIRONMENT'] || "development").to_s
bind "tcp://#{(ENV['FAYE_BIND'] || '0.0.0.0').to_s}:#{(ENV['FAYE_HTTP_PORT'] || 4242).to_i}"

ssl_enabled = ENV['FAYE_ENABLE_SSL'] && %w{YES Yes Y yes y 1 true si da ja}.include?(ENV['FAYE_ENABLE_SSL'])
if ssl_enabled
	ssl_bind (ENV['FAYE_BIND_SSL'] || '0.0.0.0').to_s, (ENV['FAYE_HTTPS_PORT'] || 4443).to_i, {
	  cert: "#{ENV['FAYE_SSL_DIR']}#{ENV['FAYE_SSL_CRT_FILE']}",
	  key: "#{ENV['FAYE_SSL_DIR']}#{ENV['FAYE_SSL_KEY_FILE']}",
	  ssl_cipher_filter: (ENV['FAYE_SSL_CIPHER_FILTER'] || nil), # optional
	  verify_mode: (ENV['FAYE_SSL_VERIFY_MODE'] || "none").to_s,         # default 'none'
	  no_tlsv1: (ENV['FAYE_SSL_NO_TLSV1'] || "false").to_s,
	  no_tlsv1_1: (ENV['FAYE_SSL_NO_TLSV11'] || "false").to_s,
	  ca_additions: (ENV['FAYE_SSL_CA_FILE'] || nil)
	}
end #/if