require "../../spec_helper"
require "../../../src/prometheus/client/gauge"

def with_gauge
  yield Prometheus::Client::Gauge.new(:test, "some docstring", {:label => "value"})
end

describe Prometheus::Client::Gauge do
  describe ".new" do
    it "defaults value to 0.0" do
      with_gauge do |gauge|
        gauge.get.should eq(0.0)
      end
    end
  end

  describe "#set" do
    it "sets a metric value" do
      with_gauge do |gauge|
        gauge.set(42.0)
        gauge.get.should eq(42.0)
      end
    end

    it "sets a metric value for a given label set" do
      with_gauge do |gauge|
        gauge.set(5.0, {:test => "value"})
        gauge.get({:test => "value"}).should eq(5.0)
        gauge.get({:test => "foobar"}).should eq(0.0)
      end
    end
  end

  describe "#inc" do
    it "increments the gauge" do
      with_gauge do |gauge|
        gauge.inc
        gauge.get.should eq(1.0)
      end
    end

    it "increments the gauge by a given value" do
      with_gauge do |gauge|
        gauge.inc(5.0)
        gauge.get.should eq(5.0)
      end
    end

    it "returns the new gauge value" do
      with_gauge do |gauge|
        gauge.inc.should eq(1.0)
      end
    end
  end

  describe "#dec" do
    it "decrements the gauge" do
      with_gauge do |gauge|
        gauge.dec
        gauge.get.should eq(-1.0)
      end
    end

    it "decrements the gauge by a given value" do
      with_gauge do |gauge|
        gauge.dec(5.0)
        gauge.get.should eq(-5.0)
      end
    end

    it "returns the new gauge value" do
      with_gauge do |gauge|
        gauge.dec.should eq(-1.0)
      end
    end
  end

  describe "#reset!" do
    it "restores the state after construction" do
      with_gauge do |gauge|
        gauge.values.should be_empty
        gauge.inc
        gauge.values.should_not be_empty

        gauge.reset!
        gauge.values.should be_empty

        gauge.inc({:some_internal_label => "test"})
        gauge.values.should_not be_empty

        gauge.reset!
        gauge.values.should be_empty
      end
    end
  end
end
