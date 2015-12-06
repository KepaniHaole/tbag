require_relative '../../src/tbag/task'

require 'fileutils'

module Tbag
  describe Task do
    context 'when set up to run 5 times at 1 second intervals' do
      subject do
        described_class.new(
          :shell_command => ->(a, b, c, d) { "echo 'foo'" },
          :sleep_duration => 1,
          :execution_directory => Directory.new(:path => '/tmp'),
          :log_directory => Directory.new(:path => '/tmp'),
          :sub_tasks => [],
          :file_name => 'file.rb',
          :file_modification_time => 12345,
          :task_index => 1
        )
      end

      it 'should have properly spaced intervals between iterations' do
        #start_time = Time.now.to_i
        #subject.start
        #end_time = Time.now.to_i
        #
        #expect(end_time - start_time).to eq(5)
      end
    end
  end
end