require_relative 'task_parser_factory'
require_relative 'task_scheduler'
require_relative 'file_watcher'
require_relative 'file_mover'
require_relative 'system_log'

module Tbag
  class TaskService
    attr_reader :tasks_directory, :task_logs_directory, :system_log, :task_scheduler, :file_watcher, :file_mover

    def initialize(h)
      @tasks_directory = h[:tasks_directory]
      @task_logs_directory = h[:task_logs_directory]

      @system_log =
        SystemLog.new(
          :system_logs_directory => h[:system_logs_directory]
        )

      system_log.append 'starting task service'

      begin
        tasks =
          TaskParserFactory.create(
            tasks_directory,
            task_logs_directory
          ).tasks

        tasks.each do |task|
          system_log.append "found task: `#{task.name}`"
        end

        @task_scheduler =
          TaskScheduler.new(
            :tasks => tasks,
            :system_log => system_log,
            :task_logs_directory => task_logs_directory
          )

        @file_watcher =
          FileWatcher.new(
            :tasks => tasks,
            :system_log => system_log,
            :tasks_directory => tasks_directory
          )

        @file_mover =
          FileMover.new(
            :source_directory => tasks_directory,
            :target_directory => h[:trash_directory]
          )
      rescue Exception => e
        system_log.append e.message
        raise e
      end
    end

    def start
      system_log.append 'starting task scheduler'
      task_scheduler.start_all

      begin
        loop do
          # scheduling algorithm
          task_scheduler.schedule

          # new files added to the file system
          file_watcher.watch_for_new_files.each do |new_file_name|
            begin
              TaskParserFactory.create(
                tasks_directory,
                task_logs_directory,
                ->(file_name) { file_name == new_file_name }
              ).tasks.each { |task| task_scheduler.add task }
            rescue Exception => e
              system_log.append "couldn't parse task: #{e.message}"
              system_log.append "moving file `#{new_file_name}` from `#{file_mover.source_directory.path}` to `#{file_mover.target_directory.path}`"
              file_mover.move_file new_file_name
              system_log.append e.message
            end
          end

          # deleted task files
          file_watcher.watch_for_deleted_files.each do |file_delete|
            task_scheduler.remove_all file_delete
          end

          # dynamic updates to existing task files
          file_watcher.watch_for_updated_files.each do |file_update|
            begin
              tasks = TaskParserFactory.create(
                tasks_directory,
                task_logs_directory,
                ->(file_name) { file_name == file_update }
              ).tasks
              tasks.each { |task| task_scheduler.remove_all task.file_name }
              tasks.each { |task| task_scheduler.add task }
            rescue Exception => e
              system_log.append "couldn't parse task: #{e.message}"
              system_log.append "moving file `#{file_update}` from `#{file_mover.source_directory.path}` to `#{file_mover.target_directory.path}`"
              file_mover.move_file file_update
              system_log.append e.message
            end
          end

          # prevent burning the cpu
          sleep 1
        end
      rescue Exception => e
        system_log.append "fatal error: #{e.message}"
        system_log.append "#{e.backtrace.join("\n")}"
      ensure
        system_log.append 'shutting down task scheduler'
      end
    end
  end
end