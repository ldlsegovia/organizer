module Organizer
  module Group
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Group::Item

      # Creates a new {Organizer::Group::Item} and adds to self.
      #
      # @param _name [Symbol] symbol to identify this particular group.
      # @param _grouping_criteria attribute by which the items will be grouped. If nil, _name will be used insted.
      # @param _parent_name stores the group parent name of the new group if has one.
      # @return [Organizer::Group::Item]
      def add_group(_name, _grouping_criteria = nil, _parent_name = nil)
        raise_error(:invalid_parent) if _parent_name && !self.find_by_name(_parent_name)
        self << Organizer::Group::Item.new(_name, _grouping_criteria, _parent_name)
        self.last
      end

      # Searches _group descendants and returns collection with the hierarchy.
      # If _group has not children, the method returns _group inside a
      # {Organizer::Group::Collection} instance.
      #
      # @param _group [Organizer::Group::Item]
      # @return [Organizer::Group::Collection]
      def hierarchy(_group)
        collection = Organizer::Group::Collection.new
        load_group_child(_group, collection)
      end

      private

      def load_group_child(_group, _collection)
        _collection << _group

        self.each do |group|
          if group.is_a?(Organizer::Group::Item) &&
            group.parent_name == _group.group_name
            load_group_child(group, _collection)
          end
        end

        _collection
      end
    end
  end
end
