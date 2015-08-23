module Organizer
  module Group
    class Collection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Group::Item

      # Splits given collection into {Organizer::Group::Item}s based on group_by_attr
      #
      # @param _collection [Organizer::Source::Collection]
      # @param _nested_groups [optional, Organizer::Group::Collection]
      # @return [Organizer::Group::Collection]
      def build(_collection, _nested_groups = Organizer::Group::Collection.new)
        build_recursively(self, _collection, _nested_groups)
        self
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

      def build_recursively(_result, _collection, _nested_groups)
        nested_groups = _nested_groups.dup
        group = nested_groups.shift
        return unless group

        if !_collection.empty? && !_collection.first.include_attribute?(group.group_by_attr)
          raise_error(:group_by_attr_not_present_in_collection)
        end

        grouped_collection = _collection.group_by { |item| item.send(group.group_by_attr) }
        grouped_collection.each do |group_value_items|
          group_value = group_value_items.first
          items = group_value_items.last
          group_result = group.dup
          group_result.particularize_group(group_value)
          _result << group_result
          items.each { |source_item| group_result << source_item } if nested_groups.empty?
          build_recursively(group_result, items, nested_groups)
        end
      end
    end
  end
end
