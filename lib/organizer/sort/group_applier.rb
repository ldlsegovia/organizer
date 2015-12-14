module Organizer
  module Sort
    module GroupApplier
      include Organizer::Error
      extend Organizer::Sort::Applier

      def self.apply(_group_definitions, _groups_collection)
        return _groups_collection if _group_definitions.blank? || _groups_collection.blank?
        return _groups_collection unless _groups_collection.first.is_a?(Organizer::Group::Item)
        group_sort_items = _group_definitions.sort_items(_groups_collection.first.group_name) || []
        sort_collection(group_sort_items, _groups_collection)
        _groups_collection.each { |item| apply(_group_definitions, item) }
      end
    end
  end
end
