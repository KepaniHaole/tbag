module Tbag
  module Usage
    def self.exit_service_already_running(pid)
      puts "not starting -- tbag is already running (pid #{pid})"
      exit 1
    end

    def self.exit_service_not_running
      puts "exiting -- tbag isn't running"
      exit 1
    end

    def self.exit_invalid_process(pid)
      puts "invalid process -- `#{pid}` doesn't seem to be a tbag process..."
      exit 1
    end

    def self.exit_bad_parameter(parameter)
      puts "unknown parameter `#{parameter}`"
      print_and_exit
    end

    def self.print_and_exit
      puts %q(
        Usage: tbag [option]
          available options:
            help   - display this message
            start  - start the tbag service if it's not already running
            status - display information about system tasks
            stop   - stop the tbag service if it's already running
            syslog - display the running system log to stdout
            update - get the latest version of tbag
      )
      exit 0
    end
  end
end