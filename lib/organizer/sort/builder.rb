module Organizer
  module Sort
    module Builder
      include Organizer::Error

      def self.build_sort_items(_methods)
        sort_items = Organizer::Sort::Collection.new
        _methods ||= @collection_methods

        _methods.each do |method|
          next unless method.sort_by?
          method.args.each do |arg|
            if arg.is_a?(Hash)
              arg.each { |attr_name, orientation| add_sort_item(sort_items, attr_name, orientation) }
            elsif arg.is_a?(Symbol) || arg.is_a?(String)
              add_sort_item(sort_items, arg)
            end
          end
        end

        return if sort_items.empty?
        sort_items
      end

      def self.build_groups_sort_items(_group_methods)
        groups_sort_items = {}
        group_data = []

        _group_methods.reverse_each do |method|
          if method.sort_by?
            group_data << method
          elsif method.group_by? && !group_data.empty?
            group_sort_items = build_sort_items(group_data)
            groups_sort_items[method.args.first] = group_sort_items if group_sort_items
            group_data = []
          end
        end

        return if groups_sort_items.keys.empty?
        groups_sort_items
      end

      def self.add_sort_item(_sort_items_collection, _attr_name, _orientation = nil)
        descending = true if _orientation.to_s == "desc"
        _sort_items_collection.add_item(_attr_name.to_sym, descending)
      end
    end
  end
end
