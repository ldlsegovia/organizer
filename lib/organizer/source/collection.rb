module Organizer
  module Source
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Source::Item

      def fill(_raw_collection)
        raise_error(:invalid_collection_structure) unless _raw_collection.respond_to?(:each)
        _raw_collection.inject(self) do |items, raw_item|
          item = Organizer::Source::Item.new
          item.define_attributes(raw_item)
          items << item
        end
      end
    end
  end
end
