require './lib/tripl3slicer'

# Run tests using: rspec spec spec/deck_spec.rb -fdoc

RSpec.describe Deck do
  before(:example) do
    @plain_deck = Deck.new('Options', 'Lyrics')
  end
  describe 'Initialise a plain_deck before each (:example) and check:' do
    it 'plain_deck is of class Deck; and' do
      expect(@plain_deck).to be_kind_of(Deck)
    end
    it 'plain_deck has no cards; and;' do
      expect(@plain_deck.cards).to be_empty
    end
    it 'plain_deck can accept a card; and' do
      @plain_deck.cards << 'hello'
      expect(@plain_deck.cards).to include('hello')
    end
    it 'it does not share state across before(:example) decks.' do
      expect(@plain_deck.cards.count).to eq(0)
    end
  end
end

RSpec.describe Deck do
  before(:context) do
    @plain_deck = Deck.new('Options', 'Lyrics')
  end
  describe 'Using before context deck persists within a context' do
    it 'plain_deck has no cards; and' do
      expect(@plain_deck.cards).to be_empty
    end
    it 'plain_deck can accept a card; and' do
      @plain_deck.cards << 'hello'
      expect(@plain_deck.cards).to include('hello')
    end
    it 'it still has one card' do
      expect(@plain_deck.cards.count).to eq(1)
    end
  end
end

RSpec.describe 'In this situation' do
  context 'If this is the context' do
    describe 'when these things happen' do
      it 'does one thing' do
      end
      it 'does another thing' do
      end
      it 'does one last thing' do
      end
    end
  end

  context 'in another context' do
    it 'does another thing' do
    end
  end
end
