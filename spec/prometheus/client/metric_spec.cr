require "../../spec_helper"
require "../../../src/prometheus/client/metric"

describe "Prometheus::Client::Metrics" do
  describe ".new" do
    it "validates name" do
      [:"0123", :"foo bar", :"foo-bar"].each do |name|
        expect_raises(ArgumentError) do
          Prometheus::Client::Counter.new(name, "some doc")
        end
      end
    end

    it "validates docstring" do
      expect_raises(ArgumentError) do
        Prometheus::Client::Counter.new(:test, "")
      end
    end
  end
end
