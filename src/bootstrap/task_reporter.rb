require_relative '../util/file_collector'
require_relative '../tbag/task_db_factory'
require_relative '../util/time_formatter'
require_relative 'symbols'

module Tbag
  class TaskReporter
    attr_reader :tasks_directory, :logs_directory, :status

    def initialize(h)
      @tasks_directory = h[:tasks_directory]
      @logs_directory = h[:logs_directory]

      @status =
        "tbag #{get_status(h[:pid])}"
    end

    def report
      puts status

      task_logs_directory = logs_directory.get_subdirectory Symbols::TASK

      tasks =
        TaskParserFactory.create(tasks_directory, task_logs_directory).tasks

      tasks.each do |task|
        begin
          taskdb_file =
            FileCollector.new(:directory => task.log_directory)
              .collect_files
              .find(->() { raise 'task has never been run' }) { |log| log.end_with? Symbols::TASKDB }

          taskdb =
            TaskDBFactory.create_from_string(
              IO.read File.join(task.log_directory.path, taskdb_file)
            )

          puts get_display_message(task, taskdb)
        rescue => e
          puts "#{task.name} -- status unknown (#{e})"
        end
      end
    end

    private
    def get_status(pid)
      if pid.exists?
        pid.valid? ? "is running (#{pid.read})" : 'stale'
      else
        "isn't running"
      end
    end

    def get_display_message(task, task_db)
      last_run_started_at = Time.at(task_db[:start_time].to_i).strftime('%m-%d-%Y %H:%M:%S')
      last_run_finished_at = Time.at(task_db[:end_time].to_i).strftime('%m-%d-%Y %H:%M:%S')
      next_run_starting_at = Time.at(task_db[:next_time].to_i).strftime('%m-%d-%Y %H:%M:%S')
      puts "#{task.name}:\n  started:  #{last_run_started_at}\n  finished: #{last_run_finished_at}\n  next run: #{next_run_starting_at}\n"
    end
  end
end