require 'open3'

module Tbag
  class SystemUpdater
    attr_reader :working_directory

    def initialize(h)
      @working_directory = h[:working_directory]
    end

    def update
      puts 'updating `tbag`...'
      ['git fetch', 'git reset --hard remotes/origin/master'].each do |command|
        Open3.popen3(command, :chdir => working_directory.path) do |stdin, stdout, stderr, executor_thread|
          puts "  running `#{command}`"
          puts "    #{stdout.read.chomp}"
          puts "    #{stderr.read.chomp}"
          puts "    rc: #{executor_thread.value}"
        end
      end
    end
  end
end