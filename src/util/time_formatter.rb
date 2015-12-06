module Tbag
  module TimeFormatter
    FORMAT = '%m-%d-%Y--%H-%M-%S'

    def self.create_string_from_time(time)
      time.strftime FORMAT
    end

    def self.create_long_from_string(string)
      date_and_time = string.split '--'

      date_tokens = date_and_time[0].split('-').map(&:to_i)
      time_tokens = date_and_time[1].split('-').map(&:to_i)

      Time.new(
        date_tokens[0],
        date_tokens[1],
        date_tokens[2],
        time_tokens[0],
        time_tokens[1],
        time_tokens[2]
      ).to_i
    end
  end
end