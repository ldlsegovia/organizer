module Organizer
  module Filter
    module Applier
      include Organizer::Error

      def self.apply(_filters, _collection)
        return _collection unless _filters

        _collection.reject! do |item|
          keep_item = true

          _filters.each do |filter|
            if !filter.apply(item)
              keep_item = false
              break
            end
          end

          !keep_item
        end

        _collection
      end

      def self.apply_groups_filters(_filters, _groups_collection)
        return if _groups_collection.empty?
        return unless _groups_collection.first.is_a?(Organizer::Group::Item)
        group_filters = _filters.filters(_groups_collection.first.group_name)
        apply(group_filters, _groups_collection)
        _groups_collection.each { |item| apply_groups_filters(_filters, item) }
      end
    end
  end
end
