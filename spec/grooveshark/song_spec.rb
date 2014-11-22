require_relative '../helper'

require 'grooveshark'

describe 'Song' do
  it 'should initialize without data' do
    expect(Grooveshark::Song.new.id).to be_nil
  end

  it 'should initialize with data' do
    song = Grooveshark::Song.new('song_id' => '2',
                                 'song_name' => 'Test',
                                 'artist_name' => 'Me',
                                 'artist_id' => '1337',
                                 'album_name' => 'Ruby4Ever',
                                 'album_id' => '42',
                                 'track_num' => '26',
                                 'estimate_duration' => '17',
                                 'cover_art_filename' => nil,
                                 'song_plays' => nil,
                                 'year' => '2015')

    expect(song.id).to eq('2')
    expect(song.name).to eq('Test')
    expect(song.artist).to eq('Me')
    expect(song.artist_id).to eq('1337')
    expect(song.album).to eq('Ruby4Ever')
    expect(song.track).to eq('26')
    expect(song.duration).to eq('17')
    expect(song.artwork).to be_nil
    expect(song.playcount).to be_nil
    expect(song.year).to eq('2015')

    expect(song.to_s).to eq('2 - Test - Me')
    expect(song.to_hash).to eq('albumID' => '42',
                               'albumName' => 'Ruby4Ever',
                               'artistID' => '1337',
                               'artistName' => 'Me',
                               'songID' => '2',
                               'songName' => 'Test',
                               'track' => '26')
  end
end
