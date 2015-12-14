module Organizer
  module Sort
    module Builder
      include Organizer::Error

      def self.build_sort_items(_sort_methods)
        sort_items = Organizer::Sort::Collection.new
        return sort_items if _sort_methods.blank?

        _sort_methods.each do |attr_name, orientation|
          sort_items.add_item(attr_name.to_sym, orientation.to_s == "desc")
        end

        return if sort_items.empty?
        sort_items
      end

      def self.build_groups_sort_items(_sort_group_methods, _group_definitions)
        return _group_definitions if _sort_group_methods.blank? || _group_definitions.blank?

        _sort_group_methods.each do |group_name, sort_items|
          definition = _group_definitions.find_by_name(group_name)
          raise_error(:unknown_group) unless definition
          group_sort_items = build_sort_items(sort_items)
          definition.sort_items = group_sort_items if group_sort_items
        end

        _group_definitions
      end
    end
  end
end
