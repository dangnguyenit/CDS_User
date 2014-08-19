require 'csv'

module Importing
  class Importer
    attr_reader :results, :headers, :error

    Converters = {
      :money => Proc.new { |val| val.to_s.gsub(/^\$|\,/, '').to_f }
    }

    def initialize(data, options = {})
      @csv = CSV.new(data, :headers => true, :header_converters => :symbol)

      @transform = options[:transform] || {}
      @headers = @csv.instance_variable_get :@headers

      @results = []
      @error = nil

      process!
    end

    def failed?
      !!@error
    end

    protected

    def process!
      return unless @results.empty?

      while row = @csv.shift
        result = {}
        row.each do |key, val|
          next if val.nil?
          val.delete!("^\u{0000}-\u{007F}")
          val.strip!

          if @transform.include?(key)
            converter = Converters[@transform[key]]
            val = converter.call(val) if converter
          end

          result[key] = val
        end

        @results << result
      end

    rescue Exception => e
      @error = e

    end
  end
end
