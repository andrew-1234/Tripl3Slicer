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

def review_lyrics(lyrics)
  indices = []
  lyrics.each_with_index do |line, index|
    puts line
    print 'Do you want to keep this line? (y/n): '
    user_input = gets.chomp.downcase
    if user_input == 'y'
      indices << index
    elsif user_input == 'q'
      break
    else
      next
    end
  end
  indices
end

indices = review_lyrics(lyrics)

indices.each do |index|
  puts "#{lyrics[index][0]}: #{lyrics[index][1]}"
end

# now add word index functionality

# Function trim audio
# See the ruby gem in my tabs
