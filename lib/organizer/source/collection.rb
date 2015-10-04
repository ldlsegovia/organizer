module Organizer
  module Source
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Source::Item

      def fill(_raw_collection)
        validate_raw_collection(_raw_collection)
        get_organized_items(_raw_collection)
      end

      private

      def validate_raw_collection(_raw_collection)
        raise_error(:invalid_collection_structure) unless _raw_collection.is_a?(Array)

        if _raw_collection.count > 0 && !_raw_collection.first.is_a?(Hash)
          raise_error(:invalid_collection_item_structure)
        end
      end

      def get_organized_items(_raw_collection)
        _raw_collection.inject(self) do |items, raw_item|
          items << build_organized_item(raw_item)
        end
      end

      def build_organized_item(_raw_item)
        item = Organizer::Source::Item.new
        item.define_attributes(_raw_item)
      end
    end
  end
end
