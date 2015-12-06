require 'fileutils'

module Tbag
  class Pid
    attr_reader :pid_file

    def initialize(pid_file)
      @pid_file = pid_file
    end

    def read
      IO.read(pid_file).to_i
    end

    def write(pid)
      IO.write pid_file, pid
    end

    def purge
      FileUtils.rm_rf pid_file
    end

    def exists?
      File.exist? pid_file
    end

    # TODO this is absolute garbage, but for now it works
    # the pid on disk is 'valid' only if it corresponds to a running tbag service process
    # if the pid on disk refers to a process that isn't running (or a process that isnt tbag),
    # then it's ok to overwrite what we have cached on the filesystem
    def valid?
      cached_pid = read
      `ps ax | grep tbag`.strip.split(/\n/).reduce([]) do |acc, process_info|
        process_info_tokens = process_info.split(/\s+/)
        acc << [process_info_tokens[0], process_info_tokens[-2], process_info_tokens[-1]]
      end.any? do |data|
        data[0].to_i == cached_pid && data[1].include?('tbag') && data[2].include?('start')
      end
    end
  end
end