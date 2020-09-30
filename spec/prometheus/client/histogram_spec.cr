require "../../spec_helper"
require "../../../src/prometheus/client/histogram"

def with_histogram
  yield Prometheus::Client::Histogram.new(:test, "some docstring", {:label => "value"}, [2.5, 5.0, 10.0])
end

def with_histogram_and_values
  with_histogram do |histogram|
    histogram.observe(3.0, {:foo => "bar"})
    histogram.observe(5.2, {:foo => "bar"})
    histogram.observe(13.0, {:foo => "bar"})
    histogram.observe(4.0, {:foo => "bar"})

    yield histogram
  end
end

describe Prometheus::Client::Histogram do
  describe ".new" do
    it "raises an error for empty buckets" do
      expect_raises(ArgumentError) do
        Prometheus::Client::Histogram.new(:test, "foo", {:foo => "bar"}, [] of Float64)
      end
    end

    it "raises an error for unsorted buckets" do
      expect_raises(ArgumentError) do
        Prometheus::Client::Histogram.new(:test, "foo", {:foo => "bar"}, [5.0, 2.5, 10.0])
      end
    end

    it "raises an error for duplicated buckets" do
      expect_raises(ArgumentError) do
        Prometheus::Client::Histogram.new(:test, "foo", {:foo => "bar"}, [1.0, 1.0])
      end
    end
  end

  describe "#get" do
    it "returns the expected buckets values" do
      with_histogram_and_values do |histogram|
        histogram.get({:foo => "bar"}).bucket_values.should eq([
          0, # <= 2.5,
          2, # <= 5.0,
          3, # <= 10.0
        ])
      end
    end

    it "returns a value which responds to #sum and #count" do
      with_histogram_and_values do |histogram|
        value = histogram.get({:foo => "bar"})

        value.sum.should eq(25.2)
        value.count.should eq(4.0)
      end
    end

    it "uses zero as default value" do
      with_histogram_and_values do |histogram|
        histogram.get({:foo => "foo"}).bucket_values.should eq([
          0, # <= 2.5
          0, # <= 5.0
          0, # <= 10.0
        ])
      end
    end
  end

  describe "#reset!" do
    it "restores the state after construction" do
      with_histogram do |histogram|
        histogram.values.should be_empty
        histogram.observe(42.0)
        histogram.values.should_not be_empty

        histogram.reset!
        histogram.values.should be_empty

        histogram.observe(42.0, {:some_internal_label => "test"})
        histogram.values.should_not be_empty

        histogram.reset!
        histogram.values.should be_empty
      end
    end
  end
end
