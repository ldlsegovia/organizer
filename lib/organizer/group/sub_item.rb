module Organizer
  module Group
    class SubItem < Array
      include Organizer::Error
      include Organizer::AttributesHandler
      include Organizer::CollectionItem
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Source::Item

      # @param _items [Array] containing Organizer::Source::Item
      def initialize(_items = nil)
        if !_items.blank?
          self.clone_attributes(_items.first)
          super(_items)
        end
      end
    end
  end
end
