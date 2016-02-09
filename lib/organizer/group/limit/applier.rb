module Organizer
  module Group
    module Limit
      module Applier
        include Organizer::Error

        def self.apply(_group_definitions, _collection)
          return _collection if _group_definitions.blank? || _collection.blank?
          return _collection unless _collection.first.is_a?(Organizer::Group::Item)
          limit_item = _group_definitions.limit_item(_collection.first.group_name)
          _collection.slice!(limit_item.value, _collection.count) unless limit_item.blank?
          _collection.each { |item| apply(_group_definitions, item) }
        end
      end
    end
  end
end
