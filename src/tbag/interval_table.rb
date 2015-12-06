module Tbag
  module IntervalTable
    # TODO a 'month' is 4 weeks (not worrying about 28/30/31 days)
    # TODO a 'year' is 12 months (not worrying about leap years)
    BASE_INTERVALS = [
      { :id => 'second', :aliases => %w(continuously), :seconds =>        1 },
      { :id => 'minute', :aliases => %w(),             :seconds =>       60 },
      { :id => 'hour'  , :aliases => %w(hourly),       :seconds =>     3600 },
      { :id => 'day'   , :aliases => %w(daily),        :seconds =>    86400 },
      { :id => 'week'  , :aliases => %w(weekly),       :seconds =>   604800 },
      { :id => 'month' , :aliases => %w(monthly),      :seconds =>  2419200 },
      { :id => 'year'  , :aliases => %w(yearly),       :seconds => 29030400 },
    ]

    def self.lookup(interval_hint)
      return create_every_prefixed_interval(interval_hint) if interval_hint.start_with? 'every_'

      return find_base_interval interval_hint
    end

    private
    def self.create_every_prefixed_interval(interval_hint)
      # parse user's intent based on method name
      tokens = interval_hint.split /_/

      case tokens.size
        when 2 # every_second, every_day, every_week, every_month, etc
          { :seconds => 1 * find_base_interval(tokens[1])[:seconds] }
        when 3 # every_5_seconds, every_10_days, etc
          { :seconds => Integer(tokens[1]) * find_base_interval(tokens[2])[:seconds] }
        else
          raise "invalid 'every_' interval: #{interval_hint}"
      end
    end

    # return an empty hash if we can't find the interval we're looking for
    def self.find_base_interval(interval_hint)
      BASE_INTERVALS.find(->() { raise "Unknown interval `#{interval_hint}`" }) do |interval|
        id = interval[:id]
        aliases = interval[:aliases]
        [id, *aliases, "#{id}s"].include? interval_hint
      end
    end
  end
end