require_relative 'environment/environment'
require_relative '../../src/util/file_collector'

module Tbag
  describe FileCollector do
    before(:each) { Environment::create }
    after(:each)  { Environment::destroy }

    let(:file_names) { %w(1 2 3 4 5) }

    let(:tasks_directory) {
      directory = Environment.tasks_directory
      IO.write(File.join(directory.path, file_names[0]), 'nfbsdfbswelkq')
      IO.write(File.join(directory.path, file_names[1]), 'qwj')
      IO.write(File.join(directory.path, file_names[2]), 'wuefuqobobqubnwkl')
      IO.write(File.join(directory.path, file_names[3]), 'webwerbwerbwerb')
      IO.write(File.join(directory.path, file_names[4]), 'joiqweiofwneq')
      directory
    }

    subject { described_class.new :directory => tasks_directory }

    it 'should collect all file names' do
      collected_files = subject.collect_files
      expect(collected_files - file_names).to be_empty
    end
  end
end