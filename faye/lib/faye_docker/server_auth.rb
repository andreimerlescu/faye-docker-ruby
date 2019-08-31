require 'json'
require 'logger'
module FayeDocker
  class ServerAuth
    def incoming(message, request, callback)
      # Let non-subscribe messages through
      if ['/meta/subscribe', "/meta/handshake", '/meta/connect', '/meta/disconnect'].include? message['channel']
        return callback.call(message)
      end #unless

      FayeDocker.logger.info message.to_json

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
        if message['data'] && message['data']['queue']
          queue = message['data']['queue']
        end #/if
      else
        message['error'] = "403::Forbidden (#{__LINE__})"
      end #/if-else

      message['ext'] = nil
      message['data']['ext'] = nil if message['data']
      
      # Check the auth_token and auth_service
      if auth_token && auth_service
        # Find the right token for the channel
        @file_content ||= File.read("#{ENV['FAYE_TOKENS_DIR']}/#{ENV['FAYE_TOKENS_JSON_FILE']}")
        if @file_content.nil? || @file_content.length <= 3
          message['error'] = "500::Internal system error (#{__LINE__})"
        else
          registry = JSON.parse(@file_content)
          if registry[auth_service]
            unless registry[auth_service]['auth_token'].to_s == auth_token.to_s
              message['error'] = "403::Forbidden (#{__LINE__})"
            else
              # ap "--------------------------------> successfully delivered message!"
              if request && request.env['HTTP_REFERRER'] != registry[auth_service]['origin']
                message['error'] = "403::Forbidden (#{__LINE__}) [#{request.env['HTTP_REFERRER']}]"
              else
                return callback.call(message)
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
end