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

      def self.format_as_number(_attribute, _mask, _options)
        on_item_context(_attribute) do |value|
          format_method = NUMBER_FORMATTER_METHODS_MAP[_mask.to_sym]
          ActionView::Base.new.send(format_method, value, _options)
        end
      end

      def self.format_as_date(_attribute, _options, _with_time)
        on_item_context(_attribute) do |value|
          default_format = _with_time ? "%Y-%m-%d %H:%M:%S" : "%Y-%m-%d"
          format = _options.fetch(:format, default_format)
          value.to_s.to_datetime.strftime(format)
        end
      end

      def self.on_item_context(_attribute, &_block)
        Proc.new do |item|
          value = item.send(_attribute)
          _block.call(value)
        end
      end

      def self.build(_attribute, _mask, _options = {})
        definition = if NUMBER_FORMATTER_METHODS_MAP[_mask.to_sym]
                       format_as_number(_attribute, _mask, _options)
                     elsif _mask == :date || _mask == :datetime
                       format_as_date(_attribute, _options, _mask == :datetime)
                     end

        if definition
          masked_attribute_name = "human_#{_attribute}"
          return Organizer::Operation::Simple.new(definition, masked_attribute_name)
        end

        raise_error(:invalid_mask)
      end
    end
  end
end
