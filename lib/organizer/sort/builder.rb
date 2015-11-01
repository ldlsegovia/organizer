module Organizer
  module Sort
    module Builder
      include Organizer::Error

      def self.build_sort_items(_methods)
        return if _methods.keys.empty?
        sort_items = Organizer::Sort::Collection.new

        _methods.each do |attr_name, orientation|
          sort_items.add_item(attr_name.to_sym, orientation.to_s == "desc")
        end

        return if sort_items.empty?
        sort_items
      end

      def self.build_groups_sort_items(_sort_group_methods)
        groups_sort_items = {}

        _sort_group_methods.keys.each do |group_name|
          group_sort_items = build_sort_items(_sort_group_methods[group_name])
          groups_sort_items[group_name] = group_sort_items if group_sort_items
        end

        return if groups_sort_items.keys.empty?
        groups_sort_items
      end
    end
  end
end
