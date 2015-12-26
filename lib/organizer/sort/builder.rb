module Organizer
  module Sort
    module Builder
      def build_sort_items(_sort_methods)
        sort_items = Organizer::Sort::Collection.new
        return sort_items if _sort_methods.blank?

        _sort_methods.each do |attr_name, orientation|
          sort_items.add(attr_name.to_sym, orientation.to_s == "desc")
        end

        return if sort_items.empty?
        sort_items
      end
    end
  end
end
