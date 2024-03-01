require './lib/tripl3slicer'

# Test the class Options
RSpec.describe Options do
  before(:example) do
    @options = Options.new
  end
  describe 'Initialise a plain options object and check:' do
    it 'options is of class Options; and' do
      expect(@options).to be_kind_of(Options)
    end
    it 'options has a default lyrics_file; and' do
      expect(@options.lyrics_file).to eq('./lyrics/legião-urbana_caboclo-faroeste.lrc')
    end
    it 'options has a nil song_file; and' do
      expect(@options.song_file).to be_nil
    end
    it 'options has a default output_dir; and' do
      expect(@options.output_dir).to eq('./output')
    end
    it 'options has a default buffer_duration' do
      expect(@options.buffer_duration).to eq(2)
    end
  end
end

RSpec.describe Options do
  context 'Parsing user options:' do
    before(:example) do
      @options = Options.new
      allow(ARGV).to receive(:[]).and_call_original
      stub_const('ARGV', ['-l', '../music/lyrics/legião-urbana_caboclo-faroeste.lrc', '-s', '../music/legião-urbana_faroeste-caboclo.mp3', '-d',
                          '../output_dir', '-b', '4'])
    end
    describe 'Are the inputs parsed correctly?:' do
      before(:example) do
        @options.parse_options
      end

      it 'options has correct lyric file; and' do
        expect(@options.lyrics_file).to eq('../music/lyrics/legião-urbana_caboclo-faroeste.lrc')
      end
      it 'options has correct song file; and' do
        expect(@options.song_file).to eq('../music/legião-urbana_faroeste-caboclo.mp3')
      end
      it 'options has correct output directory; and' do
        expect(@options.output_dir).to eq('../output_dir')
      end
      it 'options has correct buffer duration; and' do
        expect(@options.buffer_duration).to eq(4)
      end
    end
  end
  context 'Validity of user options:' do
    before(:example) do
      @options = Options.new
    end
    describe 'Does check_options work?:' do
      it 'Raises exception with nil song' do
        # User {} to specify a side effect that occurs when exp is executed
        expect { @options.check_options }.to raise_exception(Exception)
      end
      it 'Raises exception with nil lyrics' do
        @options.song_file = './song.mp3'
        @options.lyrics_file = nil
        expect { @options.check_options }.to raise_exception(Exception)
      end
      it 'Does nothing if lyrics and song are present' do
        @options.song_file = './song.mp3'
        expect(@options.check_options).to be_truthy
      end
    end
  end
end
