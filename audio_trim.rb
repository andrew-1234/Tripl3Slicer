# https://github.com/rbrigden/audio-trimmer-ruby
require 'pry'
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

    # don't go past audio end
    finish = get_length(@input) - 1 if finish.to_f > get_length(@input)
    binding.pry
    if output.empty? or File.expand_path(output) == @input
      out_arr = @input.split('.')
      out_arr[out_arr.length - 2] += '_out'
      output = out_arr.join('.')
      `sox #{@input} #{output} trim #{start} =#{finish}`
      # `mv #{output} #{@input}` # don't overwrite the original file
    else
      output = File.expand_path(output)
      `sox #{@input} #{output} trim #{start} =#{finish}`
    end
    'trim success'
  end

  def get_length(file_path)
    `soxi -D #{File.expand_path(file_path)}`.to_f
  end
end
