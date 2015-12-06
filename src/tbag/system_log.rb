require_relative '../util/time_formatter'
require_relative '../bootstrap/symbols'

module Tbag
  class SystemLog
    attr_reader :file_path

    def initialize(h)
      start_time = Time.now
      formatted_start_time = TimeFormatter.create_string_from_time(start_time)

      @file_path = File.join h[:system_logs_directory].path, Symbols.get_system_log_name(formatted_start_time)

      # update the .systemdb file on disk as well
      IO.write(File.join(h[:system_logs_directory].path, Symbols::SYSTEMDB), "start_time=#{start_time.to_i}")
    end

    def append(message)
      File.open(file_path, 'a+') do |file|
        file.puts "[#{TimeFormatter.create_string_from_time Time.now}]: #{message}"
      end
    end

    def read
      IO.read file_path
    end
  end
end