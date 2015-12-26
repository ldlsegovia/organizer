module Organizer
  module Operation
    module MaskBuilder
      include Organizer::Error

      MASK_METHODS_MAP = {
        currency: { method: :currency, formatter: :number_proc, allow_options: true },
        natural: { method: :human, formatter: :number_proc },
        size: { method: :human_size, formatter: :number_proc },
        percentage: { method: :percentage, formatter: :number_proc, allow_options: true },
        phone: { method: :phone, formatter: :number_proc, allow_options: true },
        delimited: { method: :delimited, formatter: :number_proc, allow_options: true },
        rounded: { method: :rounded, formatter: :number_proc, allow_options: true },
        clean: { method: :humanize, formatter: :instance_method_proc, allow_options: true },
        truncated: { method: :truncate, formatter: :instance_method_proc, allow_options: true },
        capitalized: { method: :capitalize, formatter: :instance_method_proc },
        downcase: { method: :downcase, formatter: :instance_method_proc },
        upcase: { method: :upcase, formatter: :instance_method_proc },
        date: { formatter: :date_proc, allow_options: true },
        datetime: { formatter: :datetime_proc, allow_options: true },
        time: { formatter: :time_proc, allow_options: true },
      }

      def self.build(_attribute, _mask, _options = nil)
        definition = get_mask_definition(_mask.to_sym)
        options = _options if definition[:allow_options]
        params = [_attribute, definition[:method], options].compact
        operation_proc = send(definition[:formatter], *params)
        masked_attribute_name = "human_#{_attribute}".to_sym
        Organizer::Operation::Item.new(operation_proc, masked_attribute_name)
      end

      def self.on_item_context(_attribute, &_block)
        Proc.new do |item|
          value = item.send(_attribute)
          _block.call(value)
        end
      end

      def self.number_proc(_attribute, _formatter_method, _options = nil)
        on_item_context(_attribute) do |number|
          number.to_s(_formatter_method, _options)
        end
      end

      def self.instance_method_proc(_attribute, _formatter_method, _options = nil)
        on_item_context(_attribute) do |value|
          !!_options ? value.send(_formatter_method, _options) : value.send(_formatter_method)
        end
      end

      def self.date_proc(_attribute, _options = {})
        on_item_context(_attribute) do |value|
          value.to_s.to_datetime.strftime(_options.fetch(:format, "%Y-%m-%d"))
        end
      end

      def self.datetime_proc(_attribute, _options = {})
        on_item_context(_attribute) do |value|
          value.to_s.to_datetime.strftime(_options.fetch(:format, "%Y-%m-%d %H:%M:%S"))
        end
      end

      def self.time_proc(_attribute, _options = {})
        measure = _options.fetch(:measure, nil)

        multiplier = if measure == :minutes
                       60
                     elsif measure == :hours
                       3600
                     else
                       1 # seconds
                     end

        on_item_context(_attribute) do |value|
          seconds = value.to_i * multiplier
          Time.at(seconds).utc.strftime("%H:%M:%S")
        end
      end

      def self.get_mask_definition(_mask)
        defintion = MASK_METHODS_MAP[_mask]
        raise_error(:invalid_mask) unless defintion
        defintion
      end
    end
  end
end
