module Organizer
  module Group
    module Builder
      include Organizer::Error

      def self.build(_collection, _groups)
        return _collection if _groups.blank?
        groups = Organizer::Group::Collection.new
        build_recursively(groups, _collection, _groups)
        groups
      end

      def self.build_recursively(_result, _collection, _nested_groups)
        nested_groups = _nested_groups.dup
        group = nested_groups.shift
        return unless group

        grouped_collection = _collection.group_by { |item| group.apply(item) }
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
