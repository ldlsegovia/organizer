module Organizer
  module Group
    class Builder
      include Organizer::Error

      # Searches inside _groups collection the group named as { group_by: :my_group } in _options.
      # If found, it groups _collection according the group definition.
      #
      # @param _collection [Organizer::Source::Collection]
      # @param _groups [Organizer::Group::Collection]
      # @param _options [Hash]
      # @return [Organizer::Group::Item] or [Organizer::Source::Collection] when group is not found
      #
      # @raise [Organizer::Group::BuilderException]
      def self.build(_collection, _groups, _options)
        selected_groups = groups_from_options(_groups, _options)
        return _collection if selected_groups.size.zero?
        groups = Organizer::Group::Collection.new
        build_recursively(groups, _collection, selected_groups)
        groups
      end

      private

      def self.groups_from_options(_groups, _options)
        group_by = _options.fetch(:group_by, nil)
        selected_groups = Organizer::Group::Collection.new
        return selected_groups unless group_by
        group_by = [group_by] unless group_by.is_a?(Array)

        group_by.each do |group_name|
          group = _groups.find_by_name(group_name)
          raise_error(:unknown_group_given) unless group
          hierarchy = _groups.hierarchy(group)
          hierarchy.each { |g| selected_groups << g }
        end

        selected_groups
      end

      def self.build_recursively(_result, _collection, _nested_groups)
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
