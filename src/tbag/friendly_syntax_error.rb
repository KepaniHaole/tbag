module Tbag
  class FriendlySyntaxError < Exception
    attr_reader :current_file_data, :symbol

    def initialize(h)
      @current_file_data = h[:current_file_data]
      @symbol =  h[:symbol]
    end

    def message
      [get_exception_header, get_task_data, get_exception_footer].join "\n"
    end

    private
    def get_exception_header
      "It looks like you have a syntax error in `#{current_file_data[:file_name]}`, at line #{current_file_data[:line_number]}:\n"
    end

    def get_task_data
      current_file_data[:task_data].split(/\n/).reject { |line| line.nil? || line.empty?}.each_with_index.map do |line, index|
        "  #{(index + 1) == current_file_data[:line_number] ? '--> ' : '    '}#{index + 1}:  #{line}"
      end.join "\n"
    end

    def get_exception_footer
      "\nI don't know what `#{symbol}` means."
    end
  end
end