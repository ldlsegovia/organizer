module Organizer
  module Sort
    class Item
      include Organizer::Error
      include Organizer::CollectionItem
      include Organizer::Explainer

      attr_reader :descending

      def initialize(_name, _descending = false)
        raise_error(:blank_name) unless _name
        @descending = !!_descending
        @item_name = _name
      end
    end
  end
end
