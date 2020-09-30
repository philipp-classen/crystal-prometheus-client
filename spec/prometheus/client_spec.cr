require "../spec_helper"
require "../../src/prometheus/client"

describe Prometheus::Client do
  describe ".registry" do
    it "returns a registry object" do
      Prometheus::Client.registry.should be_a(Prometheus::Client::Registry)
    end

    it "memorizes the returned object" do
      Prometheus::Client.registry.should eq(Prometheus::Client.registry)
    end
  end

  describe ".to_text" do
    it "allows to export stats to a String" do
      Prometheus::Client.to_text.should be_a(String)
    end

    it "allows to export stats to IO" do
      Prometheus::Client.to_text(IO::Memory.new).should be_nil
    end
  end
end
