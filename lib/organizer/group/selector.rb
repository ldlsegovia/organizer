module Organizer
  module Group
    module Selector
      include Organizer::Error

      def self.select_groups(_groups, _group_method)
        return if _group_method.blank?
        groups_hierarchy = _groups[_group_method.group_name.to_sym]
        raise_error(:unknown_group_given) unless groups_hierarchy
        groups_hierarchy
      end
    end
  end
end
