module Organizer
  module Operation
    module MaskBuilder
      include Organizer::Error

      ACTION_VIEW_METHODS_MAP = {
        currency: :number_to_currency,
        natural: :number_to_human,
        size: :number_to_human_size,
        percentage: :number_to_percentage,
        phone: :number_to_phone,
        delimiter: :number_with_delimiter,
        precision: :number_with_precision,
        truncate: :truncate,
        word_wrap: :word_wrap
      }

      STRING_METHODS_MAP = {
        clean: :humanize,
        capitalize: :capitalize,
        downcase: :downcase,
        upcase: :upcase,
      }

      def self.build(_attribute, _mask, _options = {})
        _mask = _mask.to_sym
        definition = if action_view_mask?(_mask)
                       format_with_action_view(_attribute, _mask, _options)
                     elsif string_mask?(_mask)
                       format_from_string(_attribute, _mask)
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

      def self.format_with_action_view(_attribute, _mask, _options)
        on_item_context(_attribute) do |value|
          formatter_method = action_view_formatter(_mask)
          ActionView::Base.new.send(formatter_method, value, _options)
        end
      end

      def self.format_from_string(_attribute, _mask)
        on_item_context(_attribute) do |value|
          formatter_method = string_formatter(_mask)
          value.to_s.send(formatter_method)
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

      def self.action_view_formatter(_mask)
        ACTION_VIEW_METHODS_MAP[_mask]
      end

      def self.string_formatter(_mask)
        STRING_METHODS_MAP[_mask]
      end

      def self.action_view_mask?(_mask)
        !!ACTION_VIEW_METHODS_MAP[_mask]
      end

      def self.date_mask?(_mask)
        _mask == :date || _mask == :datetime
      end

      def self.string_mask?(_mask)
        !!STRING_METHODS_MAP[_mask]
      end

      def self.time_mask?(_mask)
        _mask.to_s.starts_with?("time")
      end
    end
  end
end
