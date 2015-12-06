require_relative '../../src/tbag/system_log'
require_relative 'environment/environment'

module Tbag
  describe SystemLog do
    before(:each) { Environment::create }
    after(:each)  { Environment::destroy }

    subject { described_class.new(:system_logs_directory => Environment.system_logs_directory) }

    it 'should log 5 lines of output' do
      5.times { subject.append 'some important log message' }
      log_output = subject.read

      expect(log_output.split("\n").length).to eq 5
    end
  end
end