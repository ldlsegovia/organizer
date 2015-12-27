module Organizer
  module Group
    class DefinitionsCollection < Array
      include Organizer::Error
      include Organizer::Collection
      include Organizer::Explainer

      collectable_classes Organizer::Group::Definition

      def add(_group_name, _group_by_attr = nil)
        self << Organizer::Group::Definition.new(_group_name, _group_by_attr)
        last
      end

      def groups_from_definitions
        groups = Organizer::Group::Collection.new

        each do |item|
          if item.is_a?(Organizer::Group::Definition)
            groups.add(item.item_name, item.group_by_attr)
          end
        end

        groups
      end

      def method_missing(_method, *_args, &_block)
        if Organizer::Group::Definition.instance_methods.include?(_method)
          return find_in_definition(_args.first, _method)
        end

        super
      end

      private

      def find_in_definition(_group_name, _collection_method)
        definition = find_by_name(_group_name)
        raise_error(:definition_not_found) unless definition
        definition.send(_collection_method)
      end
    end
  end
end
