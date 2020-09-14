require "./client/registry"

module Prometheus
  module Client
    def self.registry
      @@registry ||= Registry.new
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
    def self.to_text
      String.build do |str|
        self.registry.@metrics.each do |_, metric|
          metric.to_text(str)
        end
      end
    end
  end
end
