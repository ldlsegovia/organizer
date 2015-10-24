module Organizer
  module Sort
    module Builder
      include Organizer::Error
      extend Organizer::ChainedMethodsHelpers

      def self.build_sort_items(_methods)
        methods = methods_to_hash(_methods, :sort_by)
        return if methods.keys.empty?
        sort_items = Organizer::Sort::Collection.new

        methods.each do |attr_name, orientation|
          sort_items.add_item(attr_name.to_sym, orientation.to_s == "desc")
        end

        return if sort_items.empty?
        sort_items
      end

      def self.build_groups_sort_items(_group_methods)
        groups_sort_items = {}

        for_each_group_methods(_group_methods, :sort_by) do |group_name, sort_methods|
          group_sort_items = build_sort_items(sort_methods)
          groups_sort_items[group_name] = group_sort_items if group_sort_items
        end

        return if groups_sort_items.keys.empty?
        groups_sort_items
      end
    end
  end
end
