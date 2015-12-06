require_relative '../../src/util/time_formatter'

module Tbag
  describe TimeFormatter do
    let(:time) { Time.new(1,1,1,1,1,1) }
    let(:string) { '01-01-0001--01-01-01' }

    it 'should parse times into strings' do
      expect(described_class.create_string_from_time(time)).to eq(string)
    end

    it 'should parse strings into times' do
      expect(described_class.create_long_from_string(string)).to eq(time.to_i)
    end
  end
end