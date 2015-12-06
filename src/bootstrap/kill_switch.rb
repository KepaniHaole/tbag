module Tbag
  class KillSwitch
    attr_reader :pid

    def initialize(h)
      @pid = h[:pid]
    end

    def kill
      # TODO need to poll for the pid file from the task watcher and make sure it's always there
      # TODO if the pid disappears for any reason, or the pid changes, exit everything

      Usage::exit_service_not_running if !pid.exists?
      Usage::exit_invalid_process(pid.read) if !pid.valid?

      puts "killing tbag service: #{pid.read}"
      Process.kill('KILL', pid.read)
      pid.purge
    end
  end
end