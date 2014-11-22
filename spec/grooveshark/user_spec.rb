require_relative '../helper'

require 'grooveshark'

describe 'User' do
  it 'should initialize without data' do
    expect(Grooveshark::User.new(double).id).to be_nil
  end

  it 'should initialize with data' do
    user = Grooveshark::User.new(double,
                                 'user_id' => '1',
                                 'f_name' => 'Pierre Rambaud',
                                 'is_premium' => '0',
                                 'email' => 'pierre.rambaud86@gmail.com',
                                 'city' => 'Paris',
                                 'country' => 'FR',
                                 'sex' => 'M')
    expect(user.id).to eq('1')
    expect(user.name).to eq('Pierre Rambaud')
    expect(user.premium).to eq('0')
    expect(user.email).to eq('pierre.rambaud86@gmail.com')
    expect(user.city).to eq('Paris')
    expect(user.country).to eq('FR')
    expect(user.sex).to eq('M')
  end

  it 'should return avar url' do
    user = Grooveshark::User.new(double,
                                 'user_id' => '2')
    expect(user.avatar)
      .to eq('http://images.grooveshark.com/static/userimages/2.jpg')
  end

  it 'should retrieve user activiy' do
    client = double
    allow(client).to receive(:request)
      .with('getProcessedUserFeedData',
            userID: '2',
            day: '201411220101')
      .and_return(true)
    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.feed(Time.new('20141122')))
      .to eq(true)
  end

  it 'should not fetch for songs in library if response is empty' do
    client = double
    allow(client).to receive(:request)
      .with('userGetSongsInLibrary',
            userID: '2',
            page: '1')
      .and_return({})
    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.library(1))
      .to eq([])
  end

  it 'should fetch for songs in library' do
    client = double
    allow(client).to receive(:request)
      .with('userGetSongsInLibrary',
            userID: '2',
            page: '1')
      .and_return('songs' => ['song_id' => 1])
    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.library(1).first)
      .to be_a(Grooveshark::Song)
  end

  it 'should add song to user library' do
    song = Grooveshark::Song.new
    client = double
    allow(client).to receive(:request)
      .with('userAddSongsToLibrary',
            songs: [song.to_hash])
      .and_return(true)

    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.library_add([song]))
      .to eq(true)
  end

  it 'should raise error when library does not receive Song' do
    user = Grooveshark::User.new(double)
    expect { user.library_remove('something') }
      .to raise_error(ArgumentError)
  end

  it 'should remove song from user library' do
    song = Grooveshark::Song.new('song_id' => '42',
                                 'album_id' => '43',
                                 'artist_id' => '44')
    client = double
    allow(client).to receive(:request)
      .with('userRemoveSongFromLibrary',
            userID: '2',
            songID: '42',
            albumID: '43',
            artistID: '44')
      .and_return(true)

    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.library_remove(song))
      .to eq(true)
  end

  it 'should retrieve library timestamp' do
    client = double
    allow(client).to receive(:request)
      .with('userGetLibraryTSModified',
            userID: '2')
      .and_return(true)

    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.library_ts_modified)
      .to eq(true)
  end

  it 'should list user playlists and retrieve playlist from id' do
    client = double
    allow(client).to receive(:request)
      .with('userGetPlaylists',
            userID: '2')
      .and_return('playlists' => ['playlist_id' => '1337'])

    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.playlists).to be_a(Array)
    expect(user.playlists.first).to be_a(Grooveshark::Playlist)
    expect(user.playlists.first.id).to eq('1337')
    expect(user.playlists.first.user_id).to eq('2')

    expect(user.get_playlist('1337')).to be_a(Grooveshark::Playlist)
    expect(user.get_playlist('1337').id).to eq('1337')
    expect(user.get_playlist('1337').user_id).to eq('2')

    expect(user.get_playlist('42')).to be_nil
  end

  it 'should create playlist' do
    client = double
    allow(client).to receive(:request)
      .with('createPlaylist',
            'playlistName' => 'GoT',
            'playlistAbout' => 'Description',
            'songIDs' => %w(10 11))
      .and_return(true)

    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.create_playlist('GoT',
                                'Description',
                                [Grooveshark::Song.new('song_id' => '10'),
                                 11]))
      .to eq(true)
  end

  it 'should return favorites songs' do
    client = double
    allow(client).to receive(:request)
      .with('getFavorites',
            ofWhat: 'Songs',
            userID: '2')
      .and_return(['song_id' => '42'])

    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.favorites).to be_a(Array)
    expect(user.favorites.first).to be_a(Grooveshark::Song)
    expect(user.favorites.first.id).to eq('42')
  end

  it 'should add favorite song with song object parameter' do
    client = double
    allow(client).to receive(:request)
      .with('favorite',
            what: 'Song',
            ID: '2')
      .and_return(true)

    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.add_favorite(Grooveshark::Song.new('song_id' => '2')))
      .to eq(true)
  end

  it 'should add favorite song with string parameter' do
    client = double
    allow(client).to receive(:request)
      .with('favorite',
            what: 'Song',
            ID: '2')
      .and_return(true)

    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.add_favorite('2')).to eq(true)
  end

  it 'should remove favorite songs with song object parameter' do
    client = double
    allow(client).to receive(:request)
      .with('unfavorite',
            what: 'Song',
            ID: '2')
      .and_return(true)

    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.remove_favorite(Grooveshark::Song.new('song_id' => '2')))
      .to eq(true)
  end

  it 'should remove favorite songs with string parameter' do
    client = double
    allow(client).to receive(:request)
      .with('unfavorite',
            what: 'Song',
            ID: '2')
      .and_return(true)

    user = Grooveshark::User.new(client,
                                 'user_id' => '2')
    expect(user.remove_favorite('2')).to eq(true)
  end
end
