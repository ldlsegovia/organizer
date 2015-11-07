module Organizer
  module Group
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Group::Item

      def add_group(_name, _group_by_attr = nil, _parent_name = nil)
        raise_error(:invalid_parent) if _parent_name && !find_by_name(_parent_name)
        self << Organizer::Group::Item.new(_name, _group_by_attr, _parent_name)
        last
      end
    end
  end
end
