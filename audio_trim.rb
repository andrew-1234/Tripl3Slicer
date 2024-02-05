# class audio trimmer from: https://github.com/rbrigden/audio-trimmer-ruby
require 'pry'
def buffer_seconds(time_string, direction)
  minutes, seconds = time_string.split(':').map(&:to_f)
  total_seconds = minutes * 60 + seconds
  total_seconds += direction

  new_minutes = total_seconds.div(60).to_i
  new_seconds = total_seconds % 60

  format('%02d:%05.2f', new_minutes, new_seconds)
end

class AudioTrimmer
  attr_accessor :input

  def initialize(params = {})
    input = params.fetch(:input, '')
    input_length = 0
    raise 'please specify input filepath' if input.empty?

    @input = File.expand_path(input)
  end

  def trim(start: 0, finish: get_length(@input), output: '')
    raise 'bad filepath' unless File.exist?(@input) or File.exist?(output)

    start = buffer_seconds(start, -1)
    finish_buffered = buffer_seconds(finish, 1)
    # don't go past audio end
    minutes, seconds = finish_buffered.split(':').map(&:to_f)
    total_seconds = minutes * 60 + seconds
    finish_buffered = get_length(@input) - 1 if total_seconds > get_length(@input)
    if output.empty? or File.expand_path(output) == @input
      out_arr = @input.split('.')
      out_arr[out_arr.length - 2] += '_out'
      output = out_arr.join('.')
      `sox #{@input} #{output} trim #{start} =#{finish_buffered} fade 00:00:05 0 00:00:05`
    else
      output = File.expand_path(output)
      `sox #{@input} #{output} trim #{start} =#{finish_buffered} fade 00:00:1 0 00:00:1`
    end
    'trim success'
  end

  def get_length(file_path)
    `soxi -D #{File.expand_path(file_path)}`.to_f
  end
end
