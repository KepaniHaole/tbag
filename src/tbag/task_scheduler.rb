require_relative 'task_db_factory'
require_relative 'task_thread'

module Tbag
  class TaskScheduler
    attr_reader :tasks, :system_log, :task_logs_directory, :task_thread_pool

    def initialize(h)
      @tasks = h[:tasks]
      @system_log = h[:system_log]
      @task_logs_directory = h[:task_logs_directory]
      @task_thread_pool = []
    end

    def start_all
      tasks.each do |task|
        start_task task
      end
    end

    # scheduling algorithm
    # for each task in memory
    #   if task is finished executing
    #     remove it from the thread pool
    #   if task needs to be run
    #     spin up new thread, add to thread pool
    def schedule
      finished_task_names =
        task_thread_pool
          .select { |task_thread| task_thread.finished? }
          .map    { |task_thread| task_thread.task.name }

      finished_task_names
        .each { |finished_task_name | system_log.append "task finished: `#{finished_task_name}`" }

      task_thread_pool
        .delete_if { |task_thread| finished_task_names.include? task_thread.task.name }

      tasks.each do |task|
        # if the task is already in the thread pool, skip it
        next if task_thread_pool.any? { |task_thread| task_thread.task.name == task.name }

        # find the next execution time from the task db
        begin
          task_db = TaskDBFactory.create_from_string(IO.read File.join(task.log_directory.path, "#{task.name}.taskdb"))
          current_time = Time.now.to_i
          next_task_execution_time = task_db[:next_time].to_i
          start_task task if current_time > next_task_execution_time
        rescue => e
          system_log.append "#{e.message}: task probably hasn't run yet"
        end
      end
    end

    # if task is new, add it to the thread pool and start it
    def add(task)
      tasks << task
      start_task task
    end

    def remove_all(task_file_name)
      tasks.delete_if { |existing_task| existing_task.file_name == task_file_name }
    end

    private
    def start_task(task)
      system_log.append "scheduling task: `#{task.name}`"
      task_thread_pool <<
        TaskThread.new(
          :task => task,
          :system_log => system_log
        )
    end
  end
end