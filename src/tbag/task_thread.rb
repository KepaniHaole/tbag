require 'monitor'

module Tbag
  class TaskThread
    attr_reader :task, :thread, :system_log

    def initialize(h)
      @task = h[:task]

      @lock = Monitor.new
      @system_log = h[:system_log]
      @finished = false
      @thread = Thread.new do
        begin
          task.start
          mark_finished
        rescue => e
          system_log.append "task failed to execute: #{e.message}"
        end
      end
    end

    def finished?
      @lock.synchronize do
        return @finished
      end
    end

    private
    def mark_finished
      @lock.synchronize do
        @finished = true
      end
    end
  end
end