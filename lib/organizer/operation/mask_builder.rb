module Organizer
  module Operation
    module MaskBuilder
      include Organizer::Error

      NUMBER_FORMATTER_METHODS_MAP = {
        currency: :number_to_currency,
        natural: :number_to_human,
        size: :number_to_human_size,
        percentage: :number_to_percentage,
        phone: :number_to_phone,
        delimiter: :number_with_delimiter,
        precision: :number_with_precision
      }

      def self.build(_attribute, _mask, _options = {})
        _mask = _mask.to_sym
        definition = if NUMBER_FORMATTER_METHODS_MAP[_mask]
                       format_as_number(_attribute, _mask, _options)
                     elsif date_mask?(_mask)
                       format_as_date(_attribute, _options, _mask == :datetime)
                     elsif time_mask?(_mask)
                       format_as_time(_attribute, _mask)
                     end

        if definition
          masked_attribute_name = "human_#{_attribute}"
          return Organizer::Operation::Simple.new(definition, masked_attribute_name)
        end

        raise_error(:invalid_mask)
      end

      def self.format_as_number(_attribute, _mask, _options)
        on_item_context(_attribute) do |value|
          formatter_method = number_formatter(_mask)
          ActionView::Base.new.send(formatter_method, value, _options)
        end
      end

      def self.format_as_date(_attribute, _options, _with_time)
        on_item_context(_attribute) do |value|
          default_format = _with_time ? "%Y-%m-%d %H:%M:%S" : "%Y-%m-%d"
          format = _options.fetch(:format, default_format)
          value.to_s.to_datetime.strftime(format)
        end
      end

      def self.format_as_time(_attribute, _mask)
        multiplier = if _mask == :time_from_minutes
                       60
                     elsif _mask == :time_from_hours
                       3600
                     else
                       1 # seconds
                     end

        on_item_context(_attribute) do |value|
          seconds = value.to_i * multiplier
          Time.at(seconds).utc.strftime("%H:%M:%S")
        end
      end

      def self.on_item_context(_attribute, &_block)
        Proc.new do |item|
          value = item.send(_attribute)
          _block.call(value)
        end
      end

      def self.number_formatter(_mask)
        NUMBER_FORMATTER_METHODS_MAP[_mask]
      end

      def self.date_mask?(_mask)
        _mask == :date || _mask == :datetime
      end

      def self.time_mask?(_mask)
        _mask.to_s.starts_with?("time")
      end
    end
  end
end
