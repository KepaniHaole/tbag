module Tbag
  module Symbols
    LOGS     = 'logs'
    PID      = 'pid'
    SYSTEM   = 'system'
    SYSTEMDB = '.systemdb'
    TASK     = 'task'
    TASKDB   = '.taskdb'
    TASKS    = 'tasks'
    TBAG     = 'tbag'
    TRASH    = 'trash'

    def self.get_system_log_name(formatted_log_time)
      "system_log_#{formatted_log_time}"
    end

    def self.get_stdout_log_name(task_run_name)
      "#{task_run_name}.stdout"
    end

    def self.get_stderr_log_name(task_run_name)
      "#{task_run_name}.stderr"
    end

    def self.get_rc_log_name(task_run_name)
      "#{task_run_name}.rc"
    end

    def self.get_task_db_name(task_name)
      "#{task_name}.taskdb"
    end
  end
end