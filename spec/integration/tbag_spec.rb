require_relative '../../src/bootstrap/usage'

module Tbag
  %w(a b foo bar qklwdjqlk wtf).each do |bad_parameter|
    describe `./tbag #{bad_parameter}` do
      it { should include('Usage') }
    end
  end

  describe `./tbag` do
    it { should include('Usage') }
  end

  describe `./tbag help` do
    it { should include('Usage') }
  end

  # see kick_start_spec.rb
  # describe `./tbag start` do
  #   ...
  # end

  #describe `./tbag status` do
  #  it { should raise_exception }
  #end
  #
  #describe `./tbag stop` do
  #  it { should raise_exception }
  #end
end