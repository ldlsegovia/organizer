module Organizer
  module Group
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Group::Item

      def add(_name, _group_by_attr = nil)
        self << Organizer::Group::Item.new(_name, _group_by_attr)
        last
      end
    end
  end
end
