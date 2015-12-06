require_relative 'directory'
require_relative 'symbols'

module Tbag
  BASE_DIRECTORY =
    Directory.new(:path => File.join('/', 'etc', Symbols::TBAG))
  TASKS_DIRECTORY =
    Directory.new(:path => File.join(BASE_DIRECTORY.path, Symbols::TASKS))
  LOGS_DIRECTORY =
    Directory.new(:path => File.join(BASE_DIRECTORY.path, Symbols::LOGS), :subdirectories => %W(#{Symbols::SYSTEM} #{Symbols::TASK}))
  TRASH_DIRECTORY =
    Directory.new(:path => File.join(BASE_DIRECTORY.path, Symbols::TRASH))
  PID_DIRECTORY =
    Directory.new(:path => File.join(BASE_DIRECTORY.path, Symbols::PID))

  DIRECTORIES = [
    BASE_DIRECTORY,
    TASKS_DIRECTORY,
    LOGS_DIRECTORY,
    TRASH_DIRECTORY,
    PID_DIRECTORY
  ]
end