# class audio trimmer adapted from:
# https://github.com/rbrigden/audio-trimmer-ruby

module AudioTrimmerUtil
  def unwrap_time_string_to_seconds(time_string)
    minutes, seconds = time_string.split(':').map(&:to_f)
    total_seconds = minutes * 60 + seconds
  end

  # buffer duration in seconds;
  # duration > 0 increases duration, duration < 0 removes time
  def buffer_time_string(time_string, buffer_duration)
    total_seconds = unwrap_time_string_to_seconds(time_string)
    if total_seconds + buffer_duration < 0
      0
    else
      total_seconds + buffer_duration
    end
  end

  def bidirectional_buffer(time_array, buffer_duration, input_audio_length)
    start = buffer_time_string(time_array[0], -buffer_duration)
    finish = buffer_time_string(time_array[1], buffer_duration)
    finish = input_audio_length - 1 if finish > input_audio_length
    [start, finish]
  end

  def get_audio_length(file_path)
    `soxi -D #{File.expand_path(file_path)}`.to_f
  end

  def construct_output_filename(input)
    base = File.basename(input, '.*')
    ext = File.extname(input)
    "#{File.dirname(input)}/#{base}_out#{ext}"
  end
end

class AudioTrimmer
  include AudioTrimmerUtil
  attr_reader :input, :input_length

  def initialize(params = {})
    input_path = params.fetch(:input, '')
    raise 'Please specify the input filepath' if input_path.empty?
    raise "Input filepath #{input_path} does not exist!" unless File.exist?(input_path)

    @input = File.expand_path(input_path)
    @input_length = get_audio_length(input)
  end

  def trim(start: 0, finish: input_length, buffer_duration: 0, output: '')
    output = File.expand_path(construct_output_filename(input)) if output.empty? || File.expand_path(output) == input
    output = File.expand_path(output)

    if File.exist?(output)
      raise(
        "A file with output name already exists! #{output}"
      )
    end
    buffer_duration = 0 if buffer_duration < 0
    buffer_duration = 10 if buffer_duration > 10

    buffered_seconds = bidirectional_buffer(
      [start, finish],
      buffer_duration,
      input_length
    )

    `sox #{input} #{output} trim #{buffered_seconds[0]} =#{buffered_seconds[1]} fade 00:00:1 0 00:00:1`
  end
end
