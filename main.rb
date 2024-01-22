#! /usr/bin/env ruby
require 'optparse'

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

def indented_puts(_key, _value)
  _key = "#{_key}".ljust(13)
  puts "  #{_key}: #{_value}"
end

options = {
  camel: nil,
  'first-name': nil,
  random: nil
}

parser = OptionParser.new do |parser|
  parser.on('-c', '--camel', 'Path to the lrc file')
  parser.on('-f', '--first-name FIRST_NAME', "Replacement for Chuck's first name")
  parser.on('-r', '--random RANDOM_JOKES_COUNT', 'Render n random jokes')
  parser.on('-h', '--help', 'Prints this help') do
    banner
    puts parser
    exit
  end
end

parser.parse!(into: options)

# options[:'first-name'] ||= 'Chuck'
# options[:random] ||= 100

if options.values.all?(&:nil?)
  banner
  puts 'Missing arguments: '
  puts '+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+'
  puts parser
  exit
else
  # Assign default values only to the missing keys
  options[:camel] ||= 'default_camel_value'
  options[:'first-name'] ||= 'default_first_name_value'
  options[:random] ||= 'default_random_value'
end

options.each do |key, value|
  indented_puts(key, value)
end

# Import a lyrics file

# Function to read a lyrics file and return a hash of the lyrics

# Read lyrics file
# Input: path to lrc file
# Output: hash of lyrics
lrcPath = './lyrics/legião-urbana_caboclo-faroeste.lrc'

def parse_lrc(lrcPath)
  lyrics = []
  File.readlines(lrcPath).each do |line|
    match = line.match(/^\[(\d{2}:\d{2}.\d{2})\]\s+(.*)/)
    puts "'THIS IS A MTCH' #{match.to_a}"
    puts "'THIS IS A match index 1' #{match[1]}"
    puts "'THIS IS A match index 2' #{match[2]}"
    puts 'empty lyrics' if match[2] == ''
    next unless match

    # lyrics.store(match[1], match[2])
    lyrics << [match[1], match[2]]
    # puts match.to_a
  end
  lyrics
end
lyrics = parse_lrc(lrcPath)

# puts lyrics.keys[10]
# puts lyrics.values[10]
puts lyrics[1][0].inspect
puts lyrics[1][1].inspect

# Psuedocode: Given a string, return a dotpoint list of index: word
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
puts lyrics_object[1].inspect

clozed_lines = lyrics_object[0].values_at(*lyrics_object[1])
clozed_lines.each do |line|
  puts line[0]
  puts line[1]
end

clozed_lyric_line_contents = lyrics_object[0]
clozed_lyric_line_indices = lyrics_object[1]

def get_context(card_line_index, buffer)
  context = card_line_index + buffer
end

# @ return array of previous and next context lines
def get_lines(lyrics, context)
  lyrics.values_at[*context]
end

context_lines.insert(1, clozed_sentence)

# For each card i need 2 time values
# Card = index of clozed lyric
# card audio start = time of clozed lyric
# card audio end = time of next line (card index + 1)
# Function: get context Given an of a cloze sentence, return an array of the
# context lines with the cloze line (this is a card)

# Function trim audio
# See the ruby gem in my tabs
# Audio slice = length of context lines based on content lines or one line only
# Add 1 second buffer to start and end times
# Switch option: multiple cloze per line = the same card OR
#                multiple cloze per line = different cards (default)

# Function input options (general)
# Card = line with cloze, HOW MANY CONTEXT LINES (previous + next context lines)
