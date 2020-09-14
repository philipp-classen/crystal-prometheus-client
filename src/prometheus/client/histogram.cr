require "./metric"

module Prometheus
  module Client
    class Histogram < Metric
      DEFAULT_BUCKETS = [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0]

      getter buckets

      def initialize(@name : Symbol, @docstring : String, @base_labels = {} of Symbol => String, @buckets = DEFAULT_BUCKETS)
        Value.validate_buckets(buckets)
        super(name, docstring, base_labels)
      end

      def observe(value : Number, labels = {} of Symbol => String)
        values[label_set_for(labels)].observe(buckets, value.to_f64)
      end

      def values
        @bucket_values ||= Hash(Hash(Symbol, String), Value).new { |h, k| h[k] = Value.new(buckets) }
      end

      private def to_text_impl(io : IO)
        io << "# TYPE #{name} histogram\n"
        values.each do |labels, value|
          value.bucket_values.each_with_index do |bucket_value, i|
            io << name << "_bucket"
            labels_to_text(io, labels.merge({:le => buckets[i].to_s}))
            io << ' ' << bucket_value << '\n'
          end
          io << name << "_bucket"
          labels_to_text(io, labels.merge({:le => "+Inf"}))
          io << ' ' << value.count << '\n'

          io << name << "_sum"
          labels_to_text(io, labels)
          io << ' ' << value.sum << '\n'
          io << name << "_count"
          labels_to_text(io, labels)
          io << ' ' << value.count << '\n'
        end
      end

      class Value
        getter sum, count, bucket_values

        def initialize(buckets : Array(Float64))
          super()
          @sum = 0.0
          @count = 0_i64
          @bucket_values = Array(Int64).new(buckets.size, 0)
        end

        def observe(buckets, value : Float64)
          raise ArgumentError.new("bucket size does not match") unless buckets.size == @bucket_values.size
          @sum += value
          @count += 1
          i = buckets.size - 1
          while value <= buckets[i]
            @bucket_values[i] += 1
            i -= 1
            break if i < 0
          end
        end

        def self.validate_buckets(buckets : Array(Float64))
          raise ArgumentError.new("buckets cannot be empty") if buckets.empty?
          raise ArgumentError.new("unsorted buckets") unless buckets == buckets.sort
          raise ArgumentError.new("duplicated buckets") unless buckets.size == buckets.uniq.size
        end
      end
    end
  end
end
