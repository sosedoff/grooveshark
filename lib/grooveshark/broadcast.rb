# Grooveshark module
module Grooveshark
  class Broadcast
    attr_reader :id, :user_ids
    attr_reader :is_active, :is_playing
    attr_reader :name, :usernames
    attr_reader :active_song, :next_song

    def initialize(client, broadcast_id=nil, data=nil)
      @client = client

      if broadcast_id
        @id = broadcast_id
        reload_status
      elsif data
        @id          = data['broadcast_id'] || broadcast_id
        @name        = data['name']
        @is_playing  = data['is_playing'] == 1 ? true : false
        @is_active   = data['is_active']
        @active_song = Song.new(data['active_song'])
        @next_song   = Song.new(data['next_song'])
        @usernames   = data['usernames']
        @user_ids    = data['owner_user_i_ds']
      end
    end

    # Reload broadcast status
    # Returns true on success. Otherwise false.
    def reload_status
      initialize(
        @client, nil,
        @client.request('broadcastStatusPoll', { :broadcastID => @id })
      )
      true
    rescue
      false
    end
  end
end
