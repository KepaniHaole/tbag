require_relative '../../src/tbag/task_thread'
require_relative '../../src/tbag/task'

require_relative '../../src/bootstrap/directory'

module Tbag
  describe TaskThread do
    let(:task) {
      Task.new(
        :shell_command => ->(a, b, c, d) { sleep 5 },
        :sleep_duration => 1,
        :execution_directory => Directory.new(:path => '/tmp'),
        :log_directory => Directory.new(:path => '/tmp'),
        :sub_tasks => [],
        :file_name => 'not_important',
        :file_modification_time => 12345,
        :task_name => 'asdfg',
        :task_index => 1
      )
    }

    context 'when given a decently long task' do
      it "should only return 'finished' after the task completes" do
        subject = described_class.new(:task => task)

        current_time = Time.now.to_i
        '' until subject.finished? # do nothing
        end_time = Time.now.to_i

        expect(end_time - current_time).to be >= 5
      end
    end
  end
end