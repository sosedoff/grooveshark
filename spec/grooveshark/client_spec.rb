require_relative '../helper'

require 'grooveshark'

describe 'Client' do
  context 'initialization' do
    it 'should have a valid session' do
      @gs = Grooveshark::Client.new
      expect(@gs.session).to_not be_nil
      expect(@gs.session).to match(/^[abcdef\d]{32}$/i)
    end

    it 'should have a valid country' do
      gs = Grooveshark::Client.new
      expect(gs.country).to be_a Hash
      expect(gs.country.size).to eq(11)
    end

    it 'should have a valid token' do
      @gs = Grooveshark::Client.new
      expect(@gs.comm_token).to_not be_nil
      expect(@gs.comm_token).to match(/^[abcdef\d]{40}$/i)
    end
  end

  context 'authentication' do
    it 'should raise InvalidAuthentication error for invalid credentials' do
      @gs = Grooveshark::Client.new
      expect { @gs.login('invlid_user_name', 'invalid_password') }
        .to raise_error Grooveshark::InvalidAuthentication
    end

    it 'should obtain a new communication token on TTL expiration' do
      @gs = Grooveshark::Client.new(ttl: 1)
      @tokens = []

      3.times do
        @gs.search_songs('Muse')
        @tokens << @gs.comm_token
        sleep 3
      end

      @tokens.uniq!
      expect(@tokens.size).to eq(3)
    end
  end

  context 'search' do
    before(:all) do
      @gs = Grooveshark::Client.new
    end

    it 'should return empty songs collection' do
      songs = @gs.search_songs('@@@@@%%%%%%%@%@%%@')
      expect(songs).to be_a Array
      expect(songs.size).to eq(0)
    end

    it 'should return songs collection' do
      songs = @gs.search_songs('Nirvana')
      expect(songs).to be_a Array
      expect(songs.size).to_not eq(0)
    end
  end

  # context 'download' do
  #   it 'should download without being banned' do
  #     gs = Grooveshark::Client.new
  #     # Usually IP is banned after about 15 minutes
  #     ten_minutes_later = Time.new + 15 * 60
  #     while Time.new < ten_minutes_later
  #       # Try with a short song (this one is about a minute long)
  #       song = gs.search_songs('Alan Reeves The Chase').first
  #       url = gs.get_song_url(song)
  #       file = RestClient::Request
  #              .execute(method: :post, url: url, raw_response: true).file
  #       case mime_type = `file -b --mime-type #{file.path}`.strip
  #       when /^audio\//
  #         # This is the expected type
  #       when /^application\/octet-stream$/
  #         # Sometimes the file type can't be detected and this type
  #         # is returned. At least we check it's big enough
  #         # to be an audio file.
  #         file.size.should >= 500 * 1024
  #       else
  #         fail RSpec::Expectations::ExpectationNotMetError,
  #              "Unknown MIME type (#{mime_type})"
  #       end
  #     end
  #   end
  # end
end
