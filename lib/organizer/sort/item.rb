module Organizer
  module Sort
    class Item
      include Organizer::Error
      include Organizer::CollectionItem
      include Organizer::Explainer

      attr_reader :descendant

      def initialize(_name, _descendant = true)
        @descendant = !!_descendant
        @item_name = _name
      end
    end
  end
end
