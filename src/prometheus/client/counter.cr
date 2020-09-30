require "./metric"
require "../internal-logger"

module Prometheus
  module Client
    class Counter < Metric
      getter values

      def initialize(@name : Symbol, @docstring : String, @base_labels = {} of Symbol => String)
        @values = Hash(Hash(Symbol, String), Float64).new { |h, k| h[k] = 0.0 }
        super(name, docstring, base_labels)
      end

      def inc(labels = {} of Symbol => String)
        inc(1.0, labels)
      end

      def inc(by : Number = 1.0, labels = {} of Symbol => String)
        raise ArgumentError.new("increment must be a non-negative number: got #{by}") if by < 0.0
        values[label_set_for(labels)] += by.to_f64
      end

      # Warning: counters should not decrease, so use this function only
      # if you know what you are doing.
      def set!(value : Number, labels = {} of Symbol => String)
        raise ArgumentError.new("value must be a non-negative number: got #{value}") if value < 0.0
        merged_labels = label_set_for(labels)
        old_value = values[merged_labels]
        if value < old_value
          Prometheus::Crystal::Client::Log.warn { "truncation detected for counter #{name}[labels=#{merged_labels}]: #{old_value} => #{value}" }
        end
        values[merged_labels] = value.to_f64
      end

      def reset!
        @values.clear
      end

      private def to_text_impl(io : IO)
        io << "# TYPE #{name} counter\n"
        values.each do |labels, value|
          io << name
          labels_to_text(io, labels)
          io << ' ' << value << '\n'
        end
      end
    end
  end
end
