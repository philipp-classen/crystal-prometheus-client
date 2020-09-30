require "./counter"
require "./gauge"
require "./histogram"

module Prometheus
  module Client
    class Registry
      class AlreadyRegisteredError < Exception
      end

      def initialize
        @metrics = Hash(Symbol, Metric).new
      end

      def register(metric)
        name = metric.name

        raise AlreadyRegisteredError.new("#{name} has already been registered") if exist?(name)

        @metrics[name] = metric

        metric
      end

      def exist?(name : Symbol)
        @metrics.has_key?(name)
      end

      def get(name : Symbol)
        raise ArgumentError.new("#{name} hasn't been registered") unless exist?(name)
        @metrics[name]
      end

      def counter(name, docstring, base_labels = {} of Symbol => String)
        register(Prometheus::Client::Counter.new(name, docstring, base_labels))
      end

      def gauge(name, docstring, base_labels = {} of Symbol => String)
        register(Prometheus::Client::Gauge.new(name, docstring, base_labels))
      end

      def histogram(name, docstring, base_labels, buckets = {} of Symbol => String)
        register(Prometheus::Client::Histogram.new(name, docstring, base_labels, buckets))
      end

      # Exposes the metrics using the text-based format
      # (see https://prometheus.io/docs/instrumenting/exposition_formats/#text-based-format).
      #
      # For example, this is how a metrics endpoint in Kemal would look like:
      #
      # ```
      # get "/metrics" do
      #   Prometheus::Client.to_text
      # end
      # ```
      def to_text(io : IO) : Nil
        first = true
        @metrics.each do |_, metric|
          if first
            first = false
          else
            io << '\n'
          end
          metric.to_text(io)
        end
      end

      def to_text : String
        String.build do |str|
          self.to_text(str)
        end
      end
    end
  end
end
