module Tbag
  class TaskDB
    attr_reader :db_data

    def initialize(db_data)
      @db_data = db_data.dup
    end

    # try to make symbol / string keys indifferent
    def [](key)
      value_with_symbol_key = db_data[key.to_sym]
      value_with_string_key = db_data[key.to_s]

      [value_with_symbol_key, value_with_string_key].find(->() { nil }) { |value| !value.nil? }
    end

    def serialize
      db_data.reduce([]) do |acc, (key, value)|
        acc << "#{key}=#{value}"
      end.join("\n")
    end
  end
end