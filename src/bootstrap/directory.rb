# TODO only supports one level of subdirectories atm

module Tbag
  class Directory
    attr_reader :path, :subdirectories

    def initialize(h)
      @path = h[:path]

      @subdirectories = [].tap do |array|
        h.fetch(:subdirectories, []).each do |subdirectory|
          array << Directory.new(:path => File.join(h[:path], subdirectory))
        end
      end
    end

    def get_subdirectory(subdirectory_name)
      subdirectories.find(->() { raise "no such subdirectory `#{subdirectory_name}`" }) do |subdirectory|
        subdirectory.path.end_with? subdirectory_name
      end
    end
  end
end