module Organizer
  module Group
    module Sort
      module Applier
        include Organizer::Error
        extend Organizer::Sort::Applier

        def self.apply(_group_definitions, _collection)
          return _collection if _group_definitions.blank? || _collection.blank?
          return _collection unless _collection.first.is_a?(Organizer::Group::Item)
          group_sort_items = _group_definitions.sort_items(_collection.first.group_name) || []
          sort_collection(group_sort_items, _collection)
          _collection.each { |item| apply(_group_definitions, item) }
        end
      end
    end
  end
end
