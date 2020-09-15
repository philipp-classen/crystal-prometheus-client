require "../../spec_helper"
require "../../../src/prometheus/client/label_set_validator"

describe Prometheus::Client::LabelSetValidator do
  describe "#validate!" do
    it "does not throw when given a valid label" do
      validator = Prometheus::Client::LabelSetValidator.new

      validator.validate!({:version => "alpha"}) # should not throw
    end

    it "raises ReserverdLabelError if label key starts with __" do
      validator = Prometheus::Client::LabelSetValidator.new

      expect_raises(Prometheus::Client::LabelSetValidator::ReservedLabelError) do
        validator.validate!({:__version__ => "alpha"})
      end
    end

    it "raises ReserverdLabelError if label key is reserved" do
      validator = Prometheus::Client::LabelSetValidator.new

      [:job, :instance].each do |key|
        expect_raises(Prometheus::Client::LabelSetValidator::ReservedLabelError) do
          validator.validate!({key => "alpha"})
        end
      end
    end
  end
end
