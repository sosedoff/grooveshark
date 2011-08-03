module Grooveshark
  class Artist
    attr_reader :id, :name
    
    # Initialize a new Grooveshark::Artist object
    #
    # client - Grooveshark::Client instance
    # data   - Hash containing artist information
    #
    def initialize(client, data={})
      unless client.kind_of?(Grooveshark::Client)
        raise ArgumentError, "Grooveshark::Client required!"
      end
      
      @client = client
      @id     = Integer(data['artist_id'] || data['id'])
      @name   = data['artist_name'] || data['name']
    end
  end
end
