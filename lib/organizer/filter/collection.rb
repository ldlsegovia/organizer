module Organizer
  module Filter
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Filter::Item

      def add_filter(_name = nil, &block)
        self << Organizer::Filter::Item.new(block, _name)
        last
      end
    end
  end
end
