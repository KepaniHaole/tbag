require 'fileutils'

require_relative '../../../src/bootstrap/directory'

module Tbag
  module Environment
    def self.create
      @tasks_directory =
        Directory.new(:path => File.join('/', 'tmp', 'tasks'))
      @logs_directory =
        Directory.new(:path => File.join('/', 'tmp', 'logs'), :subdirectories => %w(system task))
      @trash_directory =
        Directory.new(:path => File.join('/', 'tmp', 'trash'))

      FileUtils.mkdir_p @tasks_directory.path
      FileUtils.mkdir_p @logs_directory.path
      FileUtils.mkdir_p @trash_directory.path

      @logs_directory.subdirectories.each do |subdirectory|
        FileUtils.mkdir_p subdirectory.path
      end

      @pid_file = FileUtils.touch(File.join('/', 'tmp', 'tbag.pid'))[0]
    end

    def self.destroy
      FileUtils.rm_rf @tasks_directory.path
      FileUtils.rm_rf @logs_directory.path

      @logs_directory.subdirectories.each do |subdirectory|
        FileUtils.rm_rf subdirectory.path
      end

      FileUtils.rm_rf @pid_file
    end

    def self.tasks_directory
      @tasks_directory
    end

    def self.logs_directory
      @logs_directory
    end

    def self.trash_directory
      @trash_directory
    end

    def self.task_logs_directory
      @logs_directory.get_subdirectory 'task'
    end

    def self.system_logs_directory
      @logs_directory.get_subdirectory 'system'
    end

    def self.pid_file
      @pid_file
    end
  end
end
