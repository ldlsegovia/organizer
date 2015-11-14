module Organizer
  module Operation
    module MaskBuilder
      include Organizer::Error

      MASKS_MAP = {
        currency: :number_to_currency,
        natural: :number_to_human,
        size: :number_to_human_size,
        percentage: :number_to_percentage,
        phone: :number_to_phone,
        delimiter: :number_with_delimiter,
        precision: :number_with_precision
      }

      def self.build(_attribute, _mask, _options = {})
        validate_mask(_mask)
        create_operation(_attribute, MASKS_MAP[_mask], _options)
      end

      def self.validate_mask(_mask)
        raise_error(:invalid_mask) unless MASKS_MAP[_mask.to_sym]
      end

      def self.create_operation(_attribute, _mask_method, _options)
        definition = Proc.new do |item|
          ActionView::Base.new.send(_mask_method, item.send(_attribute), _options)
        end

        Organizer::Operation::Simple.new(definition, masked_attribute_name(_attribute))
      end

      def self.masked_attribute_name(_attribute)
        "human_#{_attribute}"
      end
    end
  end
end
