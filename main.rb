#! /usr/bin/env ruby
require 'optparse'
require 'pry'
load '/Users/andrew/Documents/GitHub/Tripl3Slicer/audio_trim.rb'
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

class Options
  # @param [String] lyrics_file Path to the .lrc file
  # @param [String] song_file Path to the .mp3 input file
  # @param [String] output_dir Path to the output directory
  attr_accessor :lyrics_file, :song_file, :output_dir

  # @param [String] lyrics Path to the .lrc file
  # @param [String] song Path to the .mp3 input file
  # @param [String] output Path to the output directory
  def initialize(lyrics = './lyrics/legião-urbana_caboclo-faroeste.lrc', song = nil, output = './output')
    @lyrics_file = lyrics
    @song_file = song
    @output_dir = output
    parse_options
    check_options
    check_directory(@output_dir)
  end

  private

  #  Assign values to the Options variables
  def parse_options
    parser = OptionParser.new do |parser|
      parser.on('-l', '--lyrics LYRICS', 'Path to the .lrc file') do |l|
        @lyrics_file = l
      end
      parser.on('-s', '--song SONG', 'Path to the .mp3 input file') do |s|
        @song_file = s
      end
      parser.on('-d', '--output', 'Path to the output directory') do |o|
        @output_dir = o
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
    return unless @lyrics_file.nil? || @song_file.nil?

    puts 'Missing arguments. Please use -h or --help for help.'
    exit
  end

  def check_directory(directory)
    return if Dir.exist?(directory)

    puts "Directory #{directory} does not exist. Creating directory."
    Dir.mkdir(directory)
  end
end

# From an array of clozed sentences, return an array of Card objects
# For each sentence, assign the card's position, audio start and audio end
# For each card, create a file name for output from output directory and card
# position
# For each card object, slice the audio file to create the audio chunk
# For each card, create an anki relative link to the audio chunk (media folder)
# For each card, we need a clozed sentence and anki link to the audio chunk
# For each card, format the sentence and audio link for csv output

# Create a class Lyrics, which accepts a class Options. The Lyrics class will include methods to read lyric files, and operate on the lyrics.

# Clozes words in a sentence by index position
#
# @param sentence [String] the input sentence string
# @param positions [Array<Integer>] an array of index values of word elements
# @return [String] Returns the sentence string with clozed {{c1:words}}.

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
      audio_path = "#{@options.output_dir}/card_#{position}.mp3"
      @cards << Card.new(sentence, position, audio_start, audio_end, audio_path)
    end
  end

  def mint_audio
    @cards.each do |card|
      trimmer = AudioTrimmer.new input: @options.song_file
      trimmer.trim(start: card.audio_start, finish: card.audio_end, output: card.audio_path)
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
                        "{{c#{counter}:#{word}}} "
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
    puts 'Enter digits separated by commas (e.g., 1, 3, 5):'
    user_input = gets.chomp
    user_input.split(',').map(&:strip).map(&:to_i)
  end
end

def main
  options = Options.new
  p options
  lyrics = Lyrics.new(options)
  p lyrics
  lyrics.interactive_select(lyrics.lyrics)
  # Create a new deck from the lyrics
  my_deck = Deck.new(options, lyrics)
  my_deck.mint_cards
  my_deck.mint_audio
end

main

# read this
# https://ruby-doc.org/core-2.6/Enumerator.html

# Block parameters -------------------------------------------------------------
# When you use a block with two parameters (like |time, word|) with an array
# where each element is itself an array of two elements (like the pairs in
# lyric_stuff), Ruby automatically assigns the first element of each pair to the
# first block parameter (time in this case) and the second element to the second
# block parameter (word).

# This is a feature of Ruby's block parameter unpacking. When the block expects
# two parameters and each element of the array being iterated over is also an
# array of two elements, Ruby automatically maps the elements of each inner
# array to the corresponding block parameters. So, in lyric_stuff.each do |time,
# word|, time receives the first element of each inner array (like "00:00"), and
# word receives the second element (like "hello").

# times = []
# words = []
# lyric_stuff.each do |time, word|
#   times << time
#   words << word
# end
# (line1, line2) = lyric_stuff
# -----------------------------------------------------------------------------
