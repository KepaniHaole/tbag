require_relative '../tbag/task_service'
require_relative '../tbag/friendly_syntax_error'

require_relative 'symbols'

require_relative 'usage'
require_relative 'pid'

module Tbag
  class KickStart
    attr_reader :tasks_directory, :logs_directory, :trash_directory, :pid

    def initialize(h)
      @tasks_directory = h[:tasks_directory]
      @logs_directory = h[:logs_directory]
      @trash_directory = h[:trash_directory]
      @pid = h[:pid]
    end

    def kick_start
      if pid.exists?
        Usage::exit_service_already_running pid.read if pid.valid?
        puts "removing stale pid file (#{pid.read})"
        pid.purge
      end

      # parse initial tasks from the parent process so we can fail early in
      # case of syntax errors
      task_logs_directory = logs_directory.get_subdirectory Symbols::TASK
      system_logs_directory = logs_directory.get_subdirectory Symbols::SYSTEM

      begin
        task_service =
          TaskService.new(
            :tasks_directory => tasks_directory,
            :task_logs_directory => task_logs_directory,
            :system_logs_directory => system_logs_directory,
            :trash_directory => trash_directory
          )
      rescue Exception => e
        puts "fatal initialization error: #{e.message}"
        exit 1
      end

      # from here on out we're running in a separate process
      child_pid = fork do
        pid.write Process.pid

        begin
          # this will never return, tasks are meant to run forever
          task_service.start
        ensure
          pid.purge
        end
      end

      puts "everything looks good! detaching tbag service (#{child_pid})"
      Process.detach child_pid
    end
  end
end