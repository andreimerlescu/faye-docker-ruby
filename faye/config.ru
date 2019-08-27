require 'faye'
bayeux = Faye::RackAdapter.new(
	:mount => ENV['FAYE_MOUNT'], 
	:timeout => (ENV['FAYE_TIMEOUT'] || 25).to_i,
	:engine  => {
    :type  => Faye::Redis,
    :host  => ENV['REDIS_HOST'],
    :port  => ENV['REDIS_PORT'],
    :password => ENV['REDIS_REQUIREPASS'],
    :database => (ENV['FAYE_REDIS_DATABASE'] || "6").to_i,
    :namespace => (ENV['FAYE_TAG'] || 'faye').to_s
  }
)

run bayeux