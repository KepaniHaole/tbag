require_relative '../util/file_collector'

module Tbag
  class FileWatcher
    attr_reader :tasks, :system_log, :tasks_directory

    def initialize(h)
      @tasks = h[:tasks]
      @system_log = h[:system_log]
      @tasks_directory = h[:tasks_directory]
    end

    def watch_for_new_files
      new_files = []

      files_on_disk = FileCollector.new(:directory => tasks_directory).collect_files
      files_in_memory = tasks.map { |task| task.file_name }

      (files_on_disk - files_in_memory).each do |new_task|
        system_log.append "new file added: `#{new_task}`"
        new_files << new_task
      end

      new_files
    end

    def watch_for_updated_files
      updated_files = []

      tasks.each do |task|
        qualified_task_file_name = File.join tasks_directory.path, task.file_name

        begin
          modification_time_in_memory = task.file_modification_time
          modification_time_on_disk = File.mtime(qualified_task_file_name).to_i
        rescue Exception => e
          next # file disappeared, but it will come back (vim .swp file issue)
        end

        # make sure not to add the same file multiple times
        updated_files << task.file_name if (modification_time_in_memory != nil) && (modification_time_in_memory != modification_time_on_disk) && !updated_files.include?(task.file_name)
      end

      updated_files.each { |updated_task| system_log.append "file updated: `#{updated_task}`" }

      updated_files
    end

    def watch_for_deleted_files
      deleted_files = []

      files_on_disk = FileCollector.new(:directory => tasks_directory).collect_files
      files_in_memory = tasks.map { |task| task.file_name }

      (files_in_memory - files_on_disk).each do |deleted_file|
        deleted_files << deleted_file if !deleted_files.include? deleted_file
      end

      deleted_files.each { |deleted_file| system_log.append "file deleted: `#{deleted_file}`" }

      deleted_files
    end
  end
end