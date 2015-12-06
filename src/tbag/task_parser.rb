require 'open3'

require 'fileutils'

require_relative 'friendly_syntax_error'
require_relative 'task'

require_relative 'task_db_factory'
require_relative '../util/time_formatter'
require_relative '../bootstrap/symbols'

module Tbag
  class TaskParser
    attr_reader :tasks_directory, :task_logs_directory, :current_file_data, :current_task_data_stack, :tasks

    def initialize(h)
      @tasks_directory = h[:tasks_directory]
      @task_logs_directory = h[:task_logs_directory]
      @current_file_data = {}
      @current_task_data_stack = []
      @tasks = []

      parse_all h[:raw_task_data]
    end

    # do you believe in magic?
    def method_missing(name, *args, &block)
      symbol = name.to_s

      current_file_data[:line_number] += 1

      interval =
        begin
          IntervalTable::lookup symbol
        rescue
          {}
        end

      return define_task(interval, *args, &block) if !interval.empty?
      return define_sub_task(*args, &block) if symbol == 'followed_by'
      return define_shell_command(*args) if symbol == 'run'
      return define_execution_directory(*args) if symbol == 'from'
      return define_log_directory(*args) if symbol == 'log'

      raise FriendlySyntaxError.new(
        :current_file_data => current_file_data,
        :symbol => symbol
      )
    end

    private
    def parse_all(raw_task_data)
      raw_task_data.each do |raw_task_datum|
        raw_task_datum.each do |key, value|
          case key
            when :file_name
              raise "task files must end with a '.rb' extension" if !value.end_with? '.rb'

              current_file_data[:file_name] = value
              current_file_data[:file_modification_time] = File.mtime(File.join tasks_directory.path, value).to_i
              current_file_data[:task_index] = 0
              current_file_data[:line_number] = 0
            when :task_data
              raise 'no task data given' if value.empty?

              current_file_data[:task_data] = value
              eval(value)
            else
              raise "unknown key #{key}"
          end
        end
      end
    end

    def define_task(interval, *args, &block)
      raise "can't define a task within a task" if !current_task_data.nil?
      raise 'no task definition provided' if !block_given?
      raise 'expecting just a task name, got more than that' if !args.empty? && args.length > 1

      push_stack

      current_task_data[:file_name] = current_file_data[:file_name]
      current_task_data[:file_modification_time] = current_file_data[:file_modification_time]
      current_task_data[:task_name] =
        args.length == 1 ? args[0].to_s : "#{current_file_data[:file_name]}_#{current_file_data[:task_index] += 1}"

      current_task_data[:sleep_duration] = interval[:seconds]
      current_task_data[:log_directory] =
        Directory.new(
          :path => File.join(task_logs_directory.path, current_task_data[:task_name]),
        )
      current_task_data[:sub_tasks] = []

      yield block

      # execution directory is a required parameter
      raise "`from` not specified for #{current_task_data[:task_name]}" if current_task_data[:execution_directory].nil?

      tasks << Task.new(pop_stack)
    end

    def define_sub_task(*args, &block)
      raise 'sub task must be contained within a task' if current_task_data[:task_name].nil?

      push_stack

      current_task_data[:file_name] = current_file_data[:file_name]
      current_task_data[:task_name] =
        args.length == 1 ? args[0].to_s : "#{current_file_data[:file_name]}_subtask_#{current_file_data[:task_index] += 1}"

      current_task_data[:log_directory] =
        Directory.new(
          :path => File.join(task_logs_directory.path, current_task_data[:task_name]),
        )

      yield block

      # execution directory is a required parameter
      raise "`from` not specified for #{current_task_data[:task_name]}" if current_task_data[:execution_directory].nil?

      sub_task = Task.new(pop_stack)
      current_task_data[:sub_tasks] << sub_task
    end

    def define_shell_command(*args)
      raise 'shell command already defined' if current_task_data[:shell_command]
      raise 'shell command must be contained within a task' if current_task_data[:task_name].nil?

      # directories are passed to the callback b/c the `current_task_data` hash
      # is cleared after we insert the task (references are gone)
      current_task_data[:shell_command] = ->(execution_directory, log_directory, task_name, sleep_duration) do
        start_time = Time.now.to_i
        Open3.popen3(args[0], :chdir => execution_directory.path) do |stdin, stdout, stderr, executor_thread|
          # ensure a unique log directory exists for our task
          FileUtils.mkdir_p log_directory.path

          exit_status = executor_thread.value

          task_run_name = "#{task_name}_#{TimeFormatter.create_string_from_time Time.now}"
          end_time = Time.now.to_i

          # for now, the pid of the task run just gets thrown out, but we can
          # write it if we need to
          # exit_status.pid

          task_db =
            TaskDBFactory.create_from_hash(
              :start_time => start_time,
              :end_time   => end_time,
              :next_time  => end_time + sleep_duration,
            )

          # stdout log file
          IO.write(File.join(log_directory.path, Symbols.get_stdout_log_name(task_run_name)), stdout.read)

          # stderr log file
          IO.write(File.join(log_directory.path, Symbols.get_stderr_log_name(task_run_name)), stderr.read)

          # rc file
          IO.write(File.join(log_directory.path, Symbols.get_rc_log_name(task_run_name)), "#{exit_status.exitstatus}")

          # update the taskdb
          IO.write(File.join(log_directory.path, Symbols.get_task_db_name(task_name)), task_db.serialize)
        end
      end
    end

    def define_execution_directory(*args)
      raise 'execution directory already defined' if current_task_data[:execution_directory]
      raise 'execution directory must be contained within a task' if current_task_data[:task_name].nil?

      execution_directory = Directory.new(:path => args[0])

      current_task_data[:execution_directory] = execution_directory
    end

    def define_log_directory(*args)
      raise 'log directory already defined' if current_task_data[:log_directory]
      raise 'log directory must be contained within a task' if current_task_data[:task_name].nil?

      log_directory = Directory.new(:path => args[0])

      current_task_data[:log_directory] = log_directory
    end

    def push_stack
      current_task_data_stack.push({})
    end

    def pop_stack
      current_task_data_stack.pop
    end

    # whatever the top of the stack is
    def current_task_data
      current_task_data_stack.last
    end
  end
end