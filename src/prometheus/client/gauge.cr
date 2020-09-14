require "./metric"

module Prometheus
  module Client
    class Gauge < Metric
      def set(value : Float64, labels = {} of Symbol => String)
        values[label_set_for(labels)] = value
      end

      def increment(labels = {} of Symbol => String, by : Float64 = 1.0)
        values[label_set_for(labels)] += by
      end

      def decrement(labels = {} of Symbol => String, by : Float64 = 1.0)
        values[label_set_for(labels)] -= by
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
