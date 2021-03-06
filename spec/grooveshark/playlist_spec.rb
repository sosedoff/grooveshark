require_relative '../helper'

require 'grooveshark'

describe 'Playlist' do
  it 'should initialize without data' do
    expect(Grooveshark::Playlist.new(double).id).to be_nil
  end

  it 'should initialize with data' do
    playlist = Grooveshark::Playlist
               .new(double,
                    'playlist_id' => '1',
                    'name' => 'something',
                    'about' => 'me',
                    'picture' => 'ruby.jpg',
                    'user_id' => '2',
                    'f_name' => 'PierreRambaud',
                    'num_songs' => '50')
    expect(playlist.id).to eq('1')
    expect(playlist.name).to eq('something')
    expect(playlist.about).to eq('me')
    expect(playlist.picture).to eq('ruby.jpg')
    expect(playlist.user_id).to eq('2')
    expect(playlist.username).to eq('PierreRambaud')
    expect(playlist.num_songs).to eq(50)
  end

  it 'should initiliaze without data and user_id' do
    playlist = Grooveshark::Playlist.new(double, nil, '2')
    expect(playlist.id).to be_nil
    expect(playlist.user_id).to be_nil
  end

  it 'should initiliaze with data and user_id' do
    playlist = Grooveshark::Playlist
               .new(double, { 'playlist_id' => '1' }, '2')
    expect(playlist.id).to eq('1')
    expect(playlist.user_id).to eq('2')
  end

  it "shouldn't load songs if playlist isn't found" do
    client = double
    allow(client).to receive(:request)
      .with('getPlaylistByID', playlistID: nil).and_return({})
    expect(Grooveshark::Playlist.new(client).load_songs).to eq([])
  end

  it 'should load songs if playlist is found' do
    client = double
    allow(client).to receive(:request)
      .with('getPlaylistByID', playlistID: nil)
      .and_return('songs' => ['song_id' => '42',
                              'name' => 'End of days',
                              'artist_name' => 'Vinnie Paz'])
    songs = Grooveshark::Playlist.new(client).load_songs
    expect(songs.first).to be_a(Grooveshark::Song)
    expect(songs.first.to_s).to eq('42 - End of days - Vinnie Paz')
  end

  it 'should rename playlist' do
    client = double
    allow(client).to receive(:request)
      .with('renamePlaylist', playlistID: '2', playlistName: 'GoT')
      .and_return(true)

    allow(client).to receive(:request)
      .with('setPlaylistAbout', playlistID: '2', about: 'Description')
      .and_return(true)

    playlist = Grooveshark::Playlist.new(client, 'playlist_id' => '2')
    expect(playlist.rename('GoT', 'Description')).to eq(true)
    expect(playlist.name).to eq('GoT')
    expect(playlist.about).to eq('Description')
  end

  it 'should return false when rename playlist failed' do
    client = double
    allow(client).to receive(:request)
      .with('renamePlaylist', playlistID: '2', playlistName: 'GoT')
      .and_raise(ArgumentError)

    playlist = Grooveshark::Playlist.new(client, 'playlist_id' => '2')
    expect(playlist.rename('GoT', 'Description')).to eq(false)
    expect(playlist.name).to be_nil
    expect(playlist.about).to be_nil
  end

  it 'should delete playlist' do
    client = double
    allow(client).to receive(:request)
      .with('deletePlaylist', playlistID: '2', name: 'GoT')
      .and_return(true)

    playlist = Grooveshark::Playlist.new(client,
                                         'playlist_id' => '2',
                                         'name' => 'GoT')
    expect(playlist.delete).to eq(true)
  end
end
