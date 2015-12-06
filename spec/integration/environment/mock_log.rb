module Tbag
  class MockLog
    attr_reader :data
    def initialize
      @data = ''
    end

    def append(message)
      data << message
    end

    def read
      data
    end
  end
end