module Organizer
  module Operation
    class Item
      include Organizer::Error
      include Organizer::CollectionItem
      include Organizer::Explainer

      attr_accessor :error
      attr_reader :definition

      def initialize(_definition, _name)
        raise_error(:definition_must_be_a_proc) unless _definition.is_a?(Proc)
        raise_error(:blank_name) unless _name
        @definition = _definition
        @item_name = _name
      end

      def execute(_item)
        raise_error(:not_implemented)
      end

      def has_error?
        !error.blank? && !error.message.blank?
      end
    end
  end
end
