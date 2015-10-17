module Organizer
  module Sort
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Sort::Item

      def add_item(_name, _descending = false)
        self << Organizer::Sort::Item.new(_name, _descending)
        last
      end
    end
  end
end
