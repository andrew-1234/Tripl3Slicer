#! /usr/bin/env ruby
require 'optparse'
require 'pry'
require 'audio_trim'
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
end

main
binding.pry

class Card
  attr_accessor :sentence, :position, :audio_start, :audio_end

  def initialize(sentence, position, audio_start, audio_end)
    @sentence = sentence
    @position = position
    @audio_start = audio_start
    @audio_end = audio_end
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

def parse_lrc(lrcPath)
  lyrics = []
  File.readlines(lrcPath).each do |line|
    match = line.match(/^\[(\d{2}:\d{2}.\d{2})\]\s+(.*)/)
    next unless match

    lyrics << [match[1], match[2]]
  end
  lyrics
end
lyrics = parse_lrc(lrcPath)
def print_dotpoints(line)
  line.split.each_with_index do |word, index|
    puts "#{index}: #{word}"
  end
end

def select_word(_line)
  puts 'Enter digits separated by commas (e.g., 1, 3, 5):'
  user_input = gets.chomp
  user_input.split(',').map(&:strip).map(&:to_i)
end

# Clozes words in a sentence by index position
#
# @param sentence [String] the input sentence string
# @param positions [Array<Integer>] an array of index values of word elements
# @return [String] Returns the sentence string with clozed {{c1:words}}.
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

def review_lyrics(lyrics)
  selected_lines_index = []
  clozed_lyrics = lyrics
  lyrics.each_with_index do |line, index|
    puts line[1]
    print 'Do you want to keep this line? (y/n): '
    user_input = gets.chomp.downcase
    if user_input == 'y'
      selected_lines_index << index
      print_dotpoints(line[1])
      selected_word_index = select_word(line[1])
      clozed_lyrics[index][1] = cloze_sentence(line[1], selected_word_index)
    elsif user_input == 'q'
      break
    else
      next
    end
  end
  [clozed_lyrics, selected_lines_index]
end

lyrics_object = review_lyrics(lyrics)

# lyrics object [0] is an array where each element = a lyrics line
# each lyrics line is an array with element 0 = time stamp and 1 = string
# lyrics object [1] is an array of index values that correspond to which
# elements of array [lyrics object [0]] have a cloze deletion
clozed_lines = lyrics_object[0].values_at(*lyrics_object[1])
start_times = clozed_lines.map { |line| line[0] }

end_lines = lyrics_object[1].map { |index| index + 1 }
end_times = end_lines.map { |index| lyrics_object[0][index][0] }

# print start time end time for each element
for i in 0..clozed_lines.length - 1
  puts "start time: #{start_times[i]}, end time: #{end_times[i]}"
  puts clozed_lines[i][1] # lyrics
end

# sox probably mm:ss format or just ss
input_file = File.expand_path('./music/legião-urbana_faroeste-caboclo.mp3')
puts input_file
# output_file = File.expand_path('./music/legião-urbana_faroeste-caboclo_out.mp3')
trimmer = AudioTrimmer.new input: input_file
trimmer.trim(start: '30', finish: '1000')

def main
  options = Options.new
  p options
end
