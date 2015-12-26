module Organizer
  module Operation
    class Item
      include Organizer::Error
      include Organizer::CollectionItem
      include Organizer::Explainer

      attr_reader :definition
      attr_reader :initial_value
      attr_reader :mask
      attr_accessor :error

      def initialize(_definition, _name, _options = {})
        raise_error(:definition_must_be_a_proc) unless _definition.is_a?(Proc)
        raise_error(:blank_name) unless _name
        @definition = _definition
        @item_name = _name
        load_options(_options)
      end

      def execute(_item, _params = [])
        if !_item.respond_to?(item_name)
          _item.define_attribute(item_name, initial_value, false)
        end

        result = _params.size.zero? ? definition.call(_item) : definition.call(_item, *_params)
        _item.send("#{item_name}=", result)
        mask.execute(_item) if mask
        nil
      end

      def has_error?
        !error.blank? && !error.message.blank?
      end

      private

      def load_options(_options)
        @mask = build_mask(_options.fetch(:mask, {}))
        @initial_value = _options.fetch(:initial_value, nil)
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
