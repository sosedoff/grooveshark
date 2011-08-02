require 'digest'

module Grooveshark
  module Request
    protected
    
    # Performs an API request
    #
    # method  - Grooveshark API method
    # options - Additional request options
    # secure  - Set secure HTTPS connection (default: false)
    #
    def request(method, options={}, secure=false)
      # Check for the communication token expiration time
      # and issue a new one if expired
      unless @communication_token.nil?      
        refresh_communication_token
      end
      
      agent = METHOD_CLIENTS[method] || CLIENT
      
      body = {
        'header' => {
          'session'        => @session,
          'uuid'           => UUID,
          'client'         => agent,
          'clientRevision' => CLIENT_REV,
          'country'        => COUNTRY
        },
        'method'           => method,
        'parameters'       => options
      }
      
      # Sign the request method
      unless @communication_token.nil?
        body['header']['token'] = create_request_token(method)
      end
      
      # Execute the request
      response = connection(secure).send(:post) do |request|
        request.url("?" + method)
        request.body = MultiJson.encode(body)
        
        request.headers['Content-Type'] = 'application/json'
        request.headers['Accept']       = 'application/json'
        request.headers['Cookie']       = "PHPSESSID=#{@session}"
      end
      
      data = response.body
      if data.kind_of?(Hash)
        data = data.normalize
        if data.key?('fault')
          raise ApiError.new(data['fault'])
        else
          data['result']
        end
      else
        data
      end
    end
    
    # Request a new communication token
    # 
    def request_communication_token
      @communication_token = nil
      @communication_token = request('getCommunicationToken', {:secretKey => Digest::MD5.hexdigest(@session)}, true)
      @communication_token_ttl = Time.now.to_i
      @communication_token
    end
    
    # Refresh communications token on ttl
    #
    # @return [String]
    #
    def refresh_communication_token
      if communication_token_expired?
        request_communication_token
      end
      @communication_token
    end
    
    # Returns true if communication token has expired
    #
    # @return [Boolean]
    #
    def communication_token_expired?
      Time.now.to_i - @communication_token_ttl > TOKEN_TTL
    end
    
    # Create a new request token
    #
    # @return [String]
    #
    def create_request_token(method)
      rnd = rand(256**3).to_s(16).rjust(6, '0')
      salt = METHOD_SALTS.key?(method) ? METHOD_SALTS[method] : SALT
      plain = [method, @communication_token, salt, rnd].join(':')
      hash = Digest::SHA1.hexdigest(plain)
      "#{rnd}#{hash}"
    end
  end
end