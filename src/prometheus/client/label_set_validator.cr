module Prometheus
  module Client
    class LabelSetValidator
      RESERVED_LABELS = {:job, :instance}

      class LabelSetError < Exception
      end

      class ReservedLabelError < LabelSetError
      end

      def validate!(labels : Hash(Symbol, String))
        labels.keys.each do |key|
          raise ReservedLabelError.new("label #{key} must not start with __") if key.to_s.starts_with?("__")
          raise ReservedLabelError.new("#{key} is reserved") if RESERVED_LABELS.includes?(key)
        end
      end
    end
  end
end
