require_relative '../../src/tbag/task_db_factory'

module Tbag
  describe TaskDBFactory do
    context 'when given a string' do
      let(:string) { "a=b\nc=d\ne=f" }
      let(:hash) { { :a => :b, :c => :d, :e => :f} }

      it 'should produce a well formed task db from a string' do
        expect(described_class.create_from_string(string).serialize).to eq(string)
      end

      it 'should produce a well formed task db from a hash' do
        expect(described_class.create_from_hash(hash).serialize).to eq(string)
      end
    end
  end
end