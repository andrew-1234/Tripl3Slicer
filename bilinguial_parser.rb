#! /usr/bin/env ruby
require 'fileutils'
require 'csv'

# Check for time stamp lines
# Line has no time stamp and no lyric has been parsed yet - skip
# Line has time stamp - add as a lyric
# Line has no time stamp - appent translation to last lyric, repeats

def parse_lrc(lrcPath)
  lyrics = []
  File.readlines(lrcPath).each do |line|
    match = line.match(/^\[(\d{2}:\d{2}.\d{2})\]\s+(.*)/)
    next unless match

    lyrics << [match[1], match[2]]
  end
  lyrics
end

def addition(a, b)
  a + b
end
