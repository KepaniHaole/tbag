require_relative 'interval_table'

module Tbag
  class Task
    attr_reader :task_data

    def initialize(task_data)
      @task_data = task_data.dup
    end

    def shell_command
      task_data[:shell_command]
    end

    def execution_directory
      task_data[:execution_directory]
    end

    def log_directory
      task_data[:log_directory]
    end

    def name
      task_data[:task_name]
    end

    def sleep_duration
      task_data[:sleep_duration]
    end

    def file_name
      task_data[:file_name]
    end

    def file_modification_time
      task_data[:file_modification_time]
    end

    def sub_tasks
      task_data[:sub_tasks]
    end

    def start
      shell_command.call(
        execution_directory,
        log_directory,
        name,
        sleep_duration
      )

      sub_tasks.each do |sub_task|
        sub_task.shell_command.call(
          sub_task.execution_directory,
          sub_task.log_directory,
          sub_task.name,
          1
        )
      end
    end
  end
end
