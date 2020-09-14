require "./metric"

module Prometheus
  module Client
    class Counter < Metric
      def inc(by : Number = 1.0, labels = {} of Symbol => String)
        raise ArgumentError.new("increment must be a non-negative number") if by < 0.0
        values[label_set_for(labels)] += by.to_f64
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
