require "./label_set_validator"

module Prometheus
  module Client
    abstract class Metric
      getter name, docstring, base_labels

      def initialize(@name : Symbol, @docstring : String, @base_labels = {} of Symbol => String)
        validate_name
        validate_docstring

        @validator = LabelSetValidator.new
      end

      def values
        @values ||= Hash(Hash(Symbol, String), Float64).new { |h, k| h[k] = 0.0 }
      end

      def get(labels = {} of Symbol => String)
        values[label_set_for(labels)]
      end

      # A text representation of the metrics.
      #
      # For details, see specification:
      # https://prometheus.io/docs/instrumenting/exposition_formats/#text-based-format
      #
      # Note: In general, you do not want to call this function directly, but use
      # Prometheus::Client::to_text
      def to_text(io)
        io << "# HELP #{name} #{docstring}\n"
        to_text_impl(io)
      end

      private abstract def to_text_impl(io)

      RE_NAME = /\A[a-zA-Z_:][a-zA-Z0-9_:]*\Z/

      private def validate_name
        raise ArgumentError.new("metric name #{name} did not match #{RE_NAME}") unless name.to_s =~ RE_NAME
      end

      private def validate_docstring
        raise ArgumentError.new("docstring must be given") if docstring.empty?
      end

      private def label_set_for(labels : Hash(Symbol, String))
        @validator.validate(labels)
        @base_labels.merge(labels)
      end

      # Helper function to format labels as specified in the text based format:
      # "{" label_name "=" `"` label_value `"` { "," label_name "=" `"` label_value `"` } [ "," ] "}"
      #
      # Example: {env="prod",type="foo"}
      private def labels_to_text(io : IO, labels : Hash(Symbol, String))
        unless base_labels.empty? && labels.empty?
          io << '{'
          first = true
          base_labels.merge(labels).each do |label_name, label_value|
            if first
              first = false
            else
              io << ','
            end
            io << label_name << "=\""
            quote_label_value(io, label_value)
            io << '"'
          end
          io << '}'
        end
      end

      # From the specification:
      #
      # label_value can be any sequence of UTF-8 characters, but the backslash (\), double-quote ("),
      # and line feed (\n) characters have to be escaped as \\, \", and \n, respectively.
      private def quote_label_value(io : IO, value : String)
        value.each_char do |char|
          case char
          when '"', '\\'
            io << '\\' << char
          when '\n'
            io << "\\n"
          else
            io << char
          end
        end
      end
    end
  end
end
