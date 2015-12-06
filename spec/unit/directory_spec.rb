require_relative '../../src/bootstrap/directory'

module Tbag
  [
    ['/some/random/path/into/nowhere', %w(subdir1 subdir2)],
    ['/some/random/path/with/no/subdirectories', []],
    ['/some/random/path/foo/whatever', %w(subdir1 subdir2 a h g e f q k)]
  ]. each do |data|
    describe Directory do
      subject { described_class.new(:path => data[0], :subdirectories => data[1]) }

      it 'should have correctly structured paths' do
        expect(subject.path).to eq(data[0])

        expect(subject.subdirectories.length).to eq(data[1].length)
        subject.subdirectories.each_with_index do |subdirectory, index|
          expect(subdirectory.path).to eq(File.join(data[0], data[1][index]))
        end
      end

      it 'should be able to fetch subdirectories' do
        data[1].each do |datum|
          subject.get_subdirectory(datum)
        end
      end
    end
  end
end