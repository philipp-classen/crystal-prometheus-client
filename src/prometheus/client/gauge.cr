require "./metric"

module Prometheus
  module Client
    class Gauge < Metric
      def set(value : Number, labels = {} of Symbol => String)
        values[label_set_for(labels)] = value.to_f64
      end

      def inc(by : Number = 1.0, labels = {} of Symbol => String)
        values[label_set_for(labels)] += by.to_f64
      end

      def dec(by : Float64 = 1.0, labels = {} of Symbol => String)
        values[label_set_for(labels)] -= by.to_f64
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
