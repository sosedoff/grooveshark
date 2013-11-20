require File.expand_path("./helper", File.dirname(__FILE__))

describe 'Broadcast' do
  context 'search' do
    before(:all) do
      @gs = Grooveshark::Client.new
    end

    it 'should return array of broadcasts of size 10' do
      @top_broadcasts = @gs.top_broadcasts(10)
      @top_broadcasts.should be_a_kind_of Array
      @top_broadcasts.size.should == 10
    end
    it 'should be a Broadcast' do
      @top_broadcasts = @gs.top_broadcasts(1)
      @top_broadcast = @top_broadcasts[0]
      @top_broadcast.should be_a_kind_of Grooveshark::Broadcast
    end
  end

  context 'attributes' do
    before(:all) do
      @gs = Grooveshark::Client.new
      @top_broadcast = @gs.top_broadcasts(1)[0]
    end

    it 'should have a valid id' do
      @top_broadcast.id.should match /^[abcdef\d]{24}$/i
    end
    it 'active_song should be a Song' do
      @top_broadcast.active_song.should be_a_kind_of Grooveshark::Song
    end
    it 'next_song should be a Song' do
      @top_broadcast.next_song.should be_a_kind_of Grooveshark::Song
    end
  end
end
