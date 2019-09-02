require 'faye'
require 'faye/redis'
require 'permessage_deflate'
require File.join(Dir.pwd,'lib/faye_docker/server_auth.rb')
require File.join(Dir.pwd,'lib/faye_docker/logger.rb')

# Are the necessary environment variables defined?
['FAYE_MOUNT', 'REDIS_HOST', 'REDIS_PORT'].each do |var|
	if ENV["#{var}"].nil? || ENV["#{var}"] == ""
		raise "Missing #{var} environment variable. Unable to start Faye."
	end #/if
end #/each

# Setup Bayeux Instance for Faye
bayeux = Faye::RackAdapter.new(
	:mount => ENV['FAYE_MOUNT'], 
	:timeout => (ENV['FAYE_TIMEOUT'] || 25).to_i,
	:engine  => {
    :type  => Faye::Redis,
    :host  => ENV['REDIS_HOST'],
    :port  => ENV['REDIS_PORT'],
    :password => (ENV['REDIS_REQUIREPASS'] || nil),
    :database => (ENV['FAYE_REDIS_DATABASE'] || "6").to_i,
    :namespace => (ENV['FAYE_TAG'] || 'faye').to_s
  }
)

# Enable message compression
bayeux.add_websocket_extension(PermessageDeflate)

# Enable message security/tokens
bayeux.add_extension(FayeDocker::ServerAuth.new)

run bayeux