require_relative '../../src/tbag/task_parser_factory'

require_relative 'environment/environment'

module Tbag
  describe TaskParserFactory do
    before(:each) { Environment::create }
    after(:each)  { Environment::destroy }

    let(:test_task) { 'test_task.rb' }

    let(:tasks_directory) {
      directory = Environment.tasks_directory
      IO.write(File.join(directory.path, test_task),
        %Q(
          yearly {
            run  "echo 'weeee'"
            from "#{directory.path}"
          }
        )
      )
      directory
    }

    subject { described_class.create(tasks_directory, Environment.task_logs_directory) }

    it 'should parse the test task' do
      expect(subject.tasks.length).to eq (1)
    end
  end
end