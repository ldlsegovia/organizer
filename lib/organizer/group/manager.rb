module Organizer
  module Group
    class Manager
      include Organizer::Error

      # Creates a new {Organizer::Group::Item} and adds to groups collection.
      #
      # @param _name [Symbol] symbol to identify this particular group.
      # @param _group_by_attr attribute by which the items will be grouped. If nil, _name will be used insted.
      # @return [Organizer::Group::Item]
      def add_group(_name, _group_by_attr = nil)
        groups << Organizer::Group::Item.new(_name, _group_by_attr)
        groups.last
      end

      # Searches the group named as { group_by: :my_group } in _options. If group is found, it groups
      # collection items according the group definition.
      #
      # @param _collection [Organizer::Source::Collection]
      # @param _options [Hash]
      # @return [Organizer::Group::Item] or [Organizer::Source::Collection] when group is not found
      #
      # @raise [Organizer::Operation::ManagerException]
      def build(_collection, _options)
        selected_groups = groups_from_options(_options)
        return _collection if selected_groups.size.zero?
        Organizer::Group::Collection.new.build(_collection, selected_groups)
      end

      private

      def groups_from_options(_options)
        group_by = _options.fetch(:group_by, nil)
        selected_groups = Organizer::Group::Collection.new
        return selected_groups unless group_by
        group_by = [group_by] unless group_by.is_a?(Array)

        group_by.each do |group_name|
          group = groups.find_by_name(group_name)
          raise_error(:unknown_group_given) unless group
          selected_groups << group
        end

        selected_groups
      end

      def groups
        @groups ||= Organizer::Group::Collection.new
      end
    end
  end
end
