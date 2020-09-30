require "./metric"

module Prometheus
  module Client
    class Gauge < Metric
      getter values

      def initialize(@name : Symbol, @docstring : String, @base_labels = {} of Symbol => String)
        @values = Hash(Hash(Symbol, String), Float64).new { |h, k| h[k] = 0.0 }
        super(name, docstring, base_labels)
      end

      def set(value : Number, labels = {} of Symbol => String)
        values[label_set_for(labels)] = value.to_f64
      end

      def inc(labels = {} of Symbol => String)
        inc(1.0, labels)
      end

      def inc(by : Number = 1.0, labels = {} of Symbol => String)
        values[label_set_for(labels)] += by.to_f64
      end

      def dec(labels = {} of Symbol => String)
        dec(1.0, labels)
      end

      def dec(by : Float64 = 1.0, labels = {} of Symbol => String)
        values[label_set_for(labels)] -= by.to_f64
      end

      def reset!
        @values.clear
      end

      private def to_text_impl(io : IO)
        io << "# TYPE #{name} gauge\n"
        values.each do |labels, value|
          io << name
          labels_to_text(io, labels)
          io << ' ' << value << '\n'
        end
      end
    end
  end
end
