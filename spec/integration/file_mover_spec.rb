require_relative 'environment/environment'
require_relative '../../src/tbag/file_mover'

module Tbag
  describe FileMover do
    before(:each) { Environment::create }
    after(:each)  { Environment::destroy }

    let(:source_directory) { Environment.tasks_directory }
    let(:target_directory) { Environment.trash_directory }

    let(:file) { 'my_file' }

    subject { described_class.new(:source_directory => source_directory, :target_directory => target_directory) }

    it 'should be able to move files' do
      # put a file in the tasks directory
      IO.write(File.join(source_directory.path, file), 'bunch of garbage')

      # move it
      subject.move_file file

      # make sure it's no longer in the source directory, and that it made it to the target directory
      expect(Dir.glob(File.join(source_directory.path, '**', '*')).select { |file| File.file?(file) }.count).to eq(0)
      expect(Dir.glob(File.join(target_directory.path, '**', '*')).select { |file| File.file?(file) }.count).to eq(1)
    end
  end
end