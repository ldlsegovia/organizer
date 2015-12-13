module Organizer
  module Group
    module Filter
      module Applier
        include Organizer::Error
        extend Organizer::Filter::Applier

        def self.apply(_group_definitions, _groups_collection)
          return if _groups_collection.empty?
          return unless _groups_collection.first.is_a?(Organizer::Group::Item)
          group_filters = _group_definitions.filters(_groups_collection.first.group_name)
          filter_collection(group_filters, _groups_collection)
          _groups_collection.each { |item| apply(_group_definitions, item) }
        end
      end
    end
  end
end
