class ServerAuth
  def incoming(message, request, callback)
    # Let non-subscribe messages through
    unless message['channel'] == '/meta/subscribe'
      return callback.call(message)
    end #unless

    # Collect auth_token and auth_service
    if message['ext']
      if message['ext']['auth_token']
        auth_token = message['ext']['auth_token']
      else
        message['error'] = "400::Bad request (#{__LINE__})"
      end #/if-else
      if message['ext']['auth_service']
        auth_service = message['ext']['auth_service']
      else
        message['error'] = "400::Bad request (#{__LINE__})"
      end #/if-else
    else
      message['error'] = "403::Forbidden (#{__LINE__})"
    end #/if-else
    
    # Check the auth_token and auth_service
    if auth_token && auth_service
      # Find the right token for the channel
      @file_content ||= File.read("/usr/local/faye/tokens/#{ENV['FAYE_TOKENS_JSON_FILE']}")
      if @file_content.nil? || @file_content.length <= 3
        message['error'] = "500::Internal system error (#{__LINE__})"
      else
        registry = JSON.parse(@file_content)
        if registry[auth_service]
          unless registry[auth_service][:auth_token] == auth_token
            message['error'] = "403::Forbidden (#{__LINE__})"
          else
            if request && request.env['HTTP_ORIGIN'] != registry[auth_service][:origin]
              message['error'] = "403::Forbidden (#{__LINE__})"
            end
          end #/unless
        else
          message['error'] = "403::Forbidden (#{__LINE__})"
        end #/if-else
      end #/if-else
    else
      message['error'] = "403::Forbidden (#{__LINE__})"
    end #/if-else

    # Call the server back now we're done
    callback.call(message)
  end #/def
end #/class