module Tbag
  class FileCollector
    attr_reader :directory

    def initialize(h)
      @directory = h[:directory]
    end

    def collect_files
      begin
        Dir.entries(directory.path).reject do |file|
          file.start_with?('.') || file.start_with?('..')
        end
      rescue
        []
      end
    end
  end
end