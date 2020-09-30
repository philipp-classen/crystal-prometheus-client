require "./client/registry"

module Prometheus
  module Client
    def self.registry
      @@registry ||= Registry.new
    end

    def self.to_text(io : IO) : Nil
      self.registry.to_text(io)
    end

    def self.to_text : String
      self.registry.to_text
    end
  end
end
