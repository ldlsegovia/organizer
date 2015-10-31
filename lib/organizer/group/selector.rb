module Organizer
  module Group
    module Selector
      include Organizer::Error

      def self.select_groups(_groups, _group_method)
        return if _group_method.blank?
        selected_groups = Organizer::Group::Collection.new
        group = _groups.find_by_name(_group_method.group_name)
        raise_error(:unknown_group_given) unless group
        raise_error(:cant_group_by_child_group) if group.has_parent?
        hierarchy = _groups.hierarchy(group)
        hierarchy.each { |g| selected_groups << g }
        selected_groups
      end

      def self.groups_from_methods(_group_methods)
        selected = []

        _group_methods.each do |method|
          next unless method.group?
          selected += method.args
        end

        selected.uniq
      end
    end
  end
end
