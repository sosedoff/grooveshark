require_relative '../helper'

require 'grooveshark'

describe Grooveshark::Broadcast do
  let(:client) { Grooveshark::Client.new }

  describe 'search' do
    let(:result) { client.top_broadcasts(10) }

    it 'returns an array' do
      expect(result).to be_an Array
      expect(result.size).to eq 10
    end

    it 'includes brodcasts' do
      all = result.all? { |item| item.is_a?(Grooveshark::Broadcast) }
      expect(all).to be_truthy
    end
  end

  describe 'broadcast' do
    let(:broadcast) { client.top_broadcasts.first }

    it 'has a valid id' do
      expect(broadcast.id).to match(/^[abcdef\d]{24}$/i)
    end

    describe '#active_song' do
      it 'is a song instance' do
        expect(broadcast.active_song).to be_a Grooveshark::Song
      end
    end

    describe '#next_song' do
      it 'is a song instance' do
        expect(broadcast.active_song).to be_a Grooveshark::Song
      end
    end
  end
end
