require 'fileutils'

module Tbag
  class FileMover
    attr_reader :source_directory, :target_directory

    def initialize(h)
      @source_directory = h[:source_directory]
      @target_directory = h[:target_directory]
    end

    def move_file(file)
      qualified_file_name = File.join(source_directory.path, file)
      FileUtils.move(qualified_file_name, target_directory.path, :force => true) if File.exist? qualified_file_name
    end
  end
end