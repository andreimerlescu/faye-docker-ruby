require 'awesome_print'
class Logger
	def incoming(message, request, callback)
		if message['channel'] == '/meta/connect'
		    return callback.call(message)
		  end #unless
		ap message
		# Call the server back now we're done
		callback.call(message)
	end
end