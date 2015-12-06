require_relative 'task_db'

module Tbag
  module TaskDBFactory
    def self.create_from_string(string)
      TaskDB.new(
        Hash[
          string.split("\n").reduce([]) do |acc, token|
            tokens = token.split '='
            acc << [tokens[0], tokens[1]]
          end
        ]
      )
    end

    def self.create_from_hash(hash)
      TaskDB.new hash
    end
  end
end