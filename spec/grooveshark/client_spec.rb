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
      expect(songs.first).to be_a(Grooveshark::Song)
      expect(songs.size).to_not eq(0)
    end

    it 'should return playlist' do
      playlists = @gs.search('Playlists', 'CruciAGoT')
      expect(playlists).to be_a(Array)
      expect(playlists.first).to be_a(Grooveshark::Playlist)
      expect(playlists.size).to_not eq(0)
    end

    it 'should return result' do
      artists = @gs.search('Artists', 'Nirvana')
      expect(artists).to be_a(Array)
      expect(artists.first).to be_a(Hash)
      expect(artists.size).to_not eq(0)
    end
  end
end
