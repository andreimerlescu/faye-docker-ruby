require 'logging'
module FayeDocker
	class << self
		def logger
			@logger ||= Logging.logger(STDOUT)
			@logger.level = :warn
			return @logger
		end #/def
	end #/class
end #/module