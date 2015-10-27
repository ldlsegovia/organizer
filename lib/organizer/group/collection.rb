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

      def hierarchy(_group)
        collection = Organizer::Group::Collection.new
        load_group_child(_group, collection)
      end

      private

      def load_group_child(_group, _collection)
        _collection << _group

        each do |group|
          if group.is_a?(Organizer::Group::Item) && group.parent_name == _group.group_name
            load_group_child(group, _collection)
          end
        end

        _collection
      end
    end
  end
end
