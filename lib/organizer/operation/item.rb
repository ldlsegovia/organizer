module Organizer
  module Operation
    class Item
      include Organizer::Error
      include Organizer::CollectionItem
      include Organizer::Explainer

      attr_accessor :error
      attr_reader :definition
      attr_reader :mask

      def initialize(_definition, _name, _options = {})
        raise_error(:definition_must_be_a_proc) unless _definition.is_a?(Proc)
        raise_error(:blank_name) unless _name
        @definition = _definition
        @item_name = _name
        @mask = build_mask(_options.fetch(:mask, {}))
      end

      def execute(_item)
        raise_error(:not_implemented)
      end

      def has_error?
        !error.blank? && !error.message.blank?
      end

      def build_mask(_mask)
        mask_name = _mask.fetch(:name, nil)
        options = _mask.fetch(:options, {})
        return unless mask_name
        Organizer::Operation::MaskBuilder.build(item_name, mask_name, options)
      end
    end
  end
end
