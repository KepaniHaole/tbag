require_relative 'symbols'

module Tbag
  class SystemReporter
    attr_reader :logs_directory, :pid

    def initialize(h)
      @logs_directory = h[:logs_directory]
      @pid = h[:pid]
    end

    def report
      Usage::exit_service_not_running if !pid.exists?

      system_log_time =
        IO.read(
          File.join(
            logs_directory.get_subdirectory(Symbols::SYSTEM).path, Symbols::SYSTEMDB
          )
        ).split('=')[1].to_i

      formatted_system_log_time = TimeFormatter.create_string_from_time(Time.at(system_log_time))
      current_system_log =
        IO.read(
          File.join(
            logs_directory.get_subdirectory(Symbols::SYSTEM).path, Symbols::get_system_log_name(formatted_system_log_time)
          )
        )

      puts current_system_log
    end
  end
end