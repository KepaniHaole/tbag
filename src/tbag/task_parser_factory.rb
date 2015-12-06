require_relative 'task_parser'
require_relative '../util/file_collector'

module Tbag
  module TaskParserFactory
    def self.create(tasks_directory, task_logs_directory, task_filter = ->(x) { true })
      TaskParser.new(
        :raw_task_data =>
          FileCollector.new(:directory => tasks_directory).collect_files.select { |file| task_filter.call file }.reduce([]) do |acc, file|
            raw_task_datum = {
              :file_name => file,
              :task_data => IO.read(File.join(tasks_directory.path, file))
            }

            acc << raw_task_datum
          end,
        :tasks_directory => tasks_directory,
        :task_logs_directory => task_logs_directory
      )
    end
  end
end