module Organizer
  module Group
    module Filter
      module Applier
        include Organizer::Error
        extend Organizer::Filter::Applier

        def self.apply(_group_definitions, _collection)
          return _collection if _group_definitions.blank? || _collection.blank?
          return _collection unless _collection.first.is_a?(Organizer::Group::Item)
          group_filters = _group_definitions.filters(_collection.first.group_name)
          filter_collection(group_filters, _collection)
          _collection.each { |item| apply(_group_definitions, item) }
        end
      end
    end
  end
end
