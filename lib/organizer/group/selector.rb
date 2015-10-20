module Organizer
  module Group
    module Selector
      include Organizer::Error

      def self.select_groups(_groups, _group_methods)
        selected = groups_from_methods(_group_methods)
        return if selected.empty?

        selected_groups = Organizer::Group::Collection.new
        return selected_groups unless selected
        selected = [selected] unless selected.is_a?(Array)

        selected.each do |group_name|
          group = _groups.find_by_name(group_name)
          raise_error(:unknown_group_given) unless group
          hierarchy = _groups.hierarchy(group)
          hierarchy.each { |g| selected_groups << g }
        end

        selected_groups
      end

      def self.groups_from_methods(_group_methods)
        selected = []

        _group_methods.each do |method|
          next unless method.group_by?
          selected += method.args
        end

        selected.uniq
      end
    end
  end
end
