require_relative '../../src/tbag/task_db'

module Tbag
  describe TaskDB do
    subject { described_class.new(:a => :b, :c => :d, :e => :f, :g => :h) }

    it 'should produce a collection of key value pairs' do
      expect(subject.serialize).to eq("a=b\nc=d\ne=f\ng=h")
    end

    context 'when bracket syntax is used' do
      it 'should work with symbols' do
        expect(subject[:a]).to eq(:b)
      end

      it 'should work with strings' do
        expect(subject['a']).to eq(:b)
      end
    end
  end
end