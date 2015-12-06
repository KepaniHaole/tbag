require_relative '../../src/tbag/task_scheduler'
require_relative '../../src/tbag/task'
require_relative '../../src/bootstrap/directory'
require_relative 'environment/mock_log'

module Tbag
  describe TaskScheduler do
    context 'when given a collection of tasks' do
      let(:tasks) {
        [
          Task.new(
            :shell_command => ->(a, b, c, d) { "echo 'foo'" },
            :sleep_duration => 4,
            :execution_directory => Directory.new(:path => '/tmp'),
            :log_directory => Directory.new(:path => '/tmp'),
            :sub_tasks => [],
            :file_name => 'not_important_1',
            :file_modification_time => 12345,
            :task_name => 'asdfg',
            :task_index => 1
          ),
          Task.new(
            :shell_command => ->(a, b, c, d) { "echo 'bar'" },
            :sleep_duration => 6,
            :execution_directory => Directory.new(:path => '/tmp'),
            :log_directory => Directory.new(:path => '/tmp'),
            :sub_tasks => [],
            :file_name => 'not_important_2',
            :file_modification_time => 12345,
            :task_name => 'hjkl',
            :task_index => 1
          ),
          Task.new(
            :shell_command => ->(a, b, c, d) { "echo 'baz'" },
            :sleep_duration => 8,
            :execution_directory => Directory.new(:path => '/tmp'),
            :log_directory => Directory.new(:path => '/tmp'),
            :sub_tasks => [],
            :file_name => 'not_important_3',
            :file_modification_time => 12345,
            :task_name => 'qwerty',
            :task_index => 1
          ),
        ]
      }

      subject { described_class.new(:tasks => tasks, :system_log => MockLog.new) }

      it 'should asynchronously start, run and remove all of them' do
        subject.start_all
        expect(subject.task_thread_pool.length).to eq(3)

        # add a new one after starting the others just for fun
        subject.add(
          Task.new(
            :shell_command => ->(a, b, c, d) { "echo 'i am the new guy'" },
            :sleep_duration => 6,
            :execution_directory => Directory.new(:path => '/tmp'),
            :log_directory => Directory.new(:path => '/tmp'),
            :sub_tasks => [],
            :file_name => 'not_important_4',
            :file_modification_time => 12345,
            :task_name => 'eyjrtyje',
            :task_index => 1
          ),
        )
        expect(subject.tasks.length).to eq(4)
        expect(subject.task_thread_pool.length).to eq(4)

        # replace it, making sure we didn't remove the running thread from the thread pool
        # they have the same name
        new_task =
          Task.new(
            :shell_command => ->(a, b, c, d) { "echo 'i have replaced the new guy'" },
            :sleep_duration => 2,
            :execution_directory => Directory.new(:path => '/tmp'),
            :log_directory => Directory.new(:path => '/tmp'),
            :sub_tasks => [],
            :file_name => 'not_important_4',
            :file_modification_time => 12345,
            :task_name => 'eyjrtyje',
            :task_index => 1
          )
        subject.remove_all(new_task.file_name)
        subject.add new_task

        expect(subject.tasks.length).to eq(4)
        expect(subject.task_thread_pool.length).to eq(5)

        # longest task is 8 seconds, 10 should be enough to clear everything
        sleep 10

        subject.schedule
        expect(subject.task_thread_pool.length).to eq(0)
      end
    end
  end
end