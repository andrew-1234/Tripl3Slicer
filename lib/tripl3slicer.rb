#! /usr/bin/env ruby
require 'optparse'
require 'pry'
require 'csv'
require 'fileutils'
require 'psych'
require_relative './audio_trim'
require_relative './send_to_anki'
def banner
  puts "
▄▄▄▄▀ █▄▄▄▄ ▄█ █ ▄▄  █        ▄▄▄▄▄   █     ▄█ ▄█▄    ▄███▄   █▄▄▄▄
▀▀▀ █    █  ▄▀ ██ █   █ █       █     ▀▄ █     ██ █▀ ▀▄  █▀   ▀  █  ▄▀
    █    █▀▀▌  ██ █▀▀▀  █     ▄  ▀▀▀▀▄   █     ██ █   ▀  ██▄▄    █▀▀▌
   █     █  █  ▐█ █     ███▄   ▀▄▄▄▄▀    ███▄  ▐█ █▄  ▄▀ █▄   ▄▀ █  █
  ▀        █    ▐  █        ▀                ▀  ▐ ▀███▀  ▀███▀     █
          ▀         ▀                                             ▀
          "
end

$anki_deck = 'portuguese'
$anki_media_folder = '/Users/andrew/Library/Application Support/Anki2/User 1/collection.media'

class Options
  # @param [String] lyrics_file Path to the .lrc file
  # @param [String] song_file Path to the .mp3 input file
  # @param [String] output_dir Path to the output directory
  attr_accessor :lyrics_file, :song_file, :output_dir, :buffer_duration

  # @param [String] lyrics Path to the .lrc file
  # @param [String] song Path to the .mp3 input file
  # @param [String] output Path to the output directory
  def initialize(
    lyrics = './lyrics/legião-urbana_caboclo-faroeste.lrc',
    song = nil,
    output = './output',
    buffer_duration = 2
  )
    @lyrics_file = lyrics
    @song_file = song
    @output_dir = output
    @buffer_duration = buffer_duration
  end

  #  Assign values to the Options variables
  def parse_options
    parser = OptionParser.new do |parser|
      parser.on('-l', '--lyrics LYRICS', 'Path to the .lrc file') do |l|
        @lyrics_file = l
      end
      parser.on('-s', '--song SONG', 'Path to the .mp3 input file') do |s|
        @song_file = s
      end
      parser.on('-d', '--output OUTPUT', 'Path to the output directory') do |d|
        @output_dir = d
      end
      parser.on('-b', '--buffer BUFFER', 'Seconds to buffer audio') do |b|
        @buffer_duration = b.to_i
      end
      parser.on('-h', '--help', 'Prints this help') do
        banner
        puts parser
        exit
      end
    end.parse!
  end

  # Check if the required Options variables have values
  def check_options
    return true unless @lyrics_file.nil? || @song_file.nil?

    raise 'Missing arguments. Please use -h or --help for help.'
    exit
  end

  def check_directory(directory)
    puts directory
    return if Dir.exist?(directory)

    puts "Directory #{directory} does not exist. Creating directory."
    Dir.mkdir(directory)
  end

  def run_checks
    check_options
    check_directory(@output_dir)
  end

  def options_confirm_continue
    puts 'These are your options, continue? (y/n)'
    puts 'Options: ---------------------------------'
    puts "- Lyrics file: #{@lyrics_file}"
    puts "- Song file: #{@song_file}"
    puts "- Output directory: #{@output_dir}"
    user_input = gets.chomp.downcase
    exit if user_input != 'y'
  end
end

class Card
  attr_accessor :sentence, :position, :audio_start, :audio_end, :audio_path

  def initialize(sentence, position, audio_start, audio_end, audio_path)
    @sentence = sentence
    @position = position
    @audio_start = audio_start
    @audio_end = audio_end
    @audio_path = audio_path
  end
end

class Deck
  attr_accessor :cards, :options, :lyrics

  def initialize(options, lyrics)
    @options = options
    @lyrics = lyrics
    @cards = []
  end

  def mint_cards
    @lyrics.lyrics_clozed.each_with_index do |(audio_start, sentence), index|
      position = @lyrics.selected_lines_index[index]
      audio_end = if position + 1 < lyrics.lyrics.length
                    @lyrics.lyrics[position + 1][0]
                  else
                    # audio end > input logic inside audio_trim.rb
                    '99:99.99'
                  end
      card_id = File.basename(@options.song_file, '.*')
      audio_path = "#{@options.output_dir}/#{card_id}_card_ln_#{position}.mp3"
      @cards << Card.new(sentence, position, audio_start, audio_end, audio_path)
    end
  end

  def mint_audio
    @cards.each do |card|
      trimmer = AudioTrimmer.new input: @options.song_file
      trimmer.trim(
        start: card.audio_start,
        finish: card.audio_end,
        output: card.audio_path,
        buffer_duration: @options.buffer_duration
      )
      p "#{card.audio_path} created."
    end
  end
end

class Lyrics
  attr_accessor :options, :lyrics, :selected_lines_index, :lyrics_clozed

  def initialize(options)
    @options = options
    @lyrics = parse_lrc(options.lyrics_file)
    @selected_lines_index = []
    @lyrics_clozed = []
  end

  def parse_lrc(lrcPath)
    lyrics = []
    File.readlines(lrcPath).each do |line|
      match = line.match(/^\[(\d{2}:\d{2}.\d{2})\]\s+(.*)/)
      next unless match

      lyrics << [match[1], match[2]]
    end
    lyrics
  end

  def interactive_select(lyrics)
    lyrics.each_with_index do |line, index|
      puts line[1]
      print 'Do you want to keep this line? (y/n): '
      user_input = gets.chomp.downcase
      if user_input == 'y'
        @selected_lines_index << index
        print_dotpoints(line[1])
        selected_word_index = select_word
        @lyrics_clozed << [line[0], cloze_sentence(line[1], selected_word_index)]
      elsif user_input == 'q'
        break
      else
        next
      end
    end
  end

  def cloze_sentence(sentence, positions)
    new_sentence = ''
    counter = 0
    sentence.split(' ').each_with_index do |word, index|
      new_sentence += if positions.include?(index)
                        counter += 1
                        "{{c#{counter}::#{word}}} "
                      else
                        "#{word} "
                      end
    end
    new_sentence.strip
  end

  def print_dotpoints(line)
    line.split.each_with_index do |word, index|
      puts "#{index}: #{word}"
    end
  end

  def select_word
    puts 'Select word(s) to cloze: '
    puts 'Enter one or more digits separated by commas (e.g., 1, 3, 5):'
    user_input = gets.chomp
    user_input.split(',').map(&:strip).map(&:to_i)
  end
end

def ankify(deck)
  song_name = File.basename(deck.options.song_file, '.*')
  title_block = "#tags:lyrics #{song_name}",
                '#separator:Semicolon',
                '#html:true',
                '#notetype:Cloze',
                "#deck:#{$anki_deck}",
                '#columns:Text;Back extra',
                '#notetype column:3'
  card_contents = []
  deck.cards.each do |card|
    audio_path_anki = File.basename(card.audio_path)
    audio_path_anki_link = "[sound:#{audio_path_anki}]"
    card_contents << [card.sentence, audio_path_anki_link, "Cloze\n"].join(';')
    audio_move(card, audio_path_anki)
  end
  final_contents = title_block.join("\n") + "\n" + card_contents.join

  begin
    csv_name = "#{deck.options.output_dir}/cards_#{song_name}.csv"
    File.write(csv_name, final_contents, encoding: 'UTF-8')
    [csv_name, song_name]
  rescue StandardError => e
    puts 'whoops something went wrong writing the csv'
    puts "#{e.class}: #{e.message}"
    exit
  end
end

def audio_move(card, audio_path_anki)
  # move audio files to the Anki media folder
  FileUtils.cp(card.audio_path, File.path($anki_media_folder + '/' + audio_path_anki))
rescue StandardError => e
  puts 'whoops something went wrong moving an audio file'
  puts "#{e.class}: #{e.message}"
  exit
end

def main
  options = Options.new
  options.parse_options
  options.run_checks
  options.options_confirm_continue
  lyrics = Lyrics.new(options)
  lyrics.interactive_select(lyrics.lyrics)
  if lyrics.selected_lines_index.empty? then puts "\nNo selections.."; exit end
  my_deck = Deck.new(options, lyrics)
  my_deck.mint_cards
  my_deck.mint_audio
  csv_info = ankify(my_deck)
  puts 'Attempt direct import to anki with ankiconnect? (y/n)'
  puts 'WARNING: Anki must be open to work'
  user_input = gets.chomp.downcase
  return unless user_input == 'y'

  send_to_anki(csv_info[0], csv_info[1])
  puts 'Import complete!'
end

main if __FILE__ == $PROGRAM_NAME
