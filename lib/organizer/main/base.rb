module Organizer
  class Base
    include Organizer::Error

    def self.inherited(child_class)
      child_class.extend(ChildClassMethods)
      child_class.send(:include, ChildInstanceMethods)
      super
    end

    module ChildClassMethods
      # Persist a proc that needs to return an Array of Hashes.
      #
      # @yield array containing Hash items.
      # @yieldreturn [Array] containing Hash items.
      # @return [void]
      def add_collection(&block)
        @collection_proc = block
        return
      end

      # Adds a default {Organizer::Filter::Item} to {Organizer::Filter::Manager}
      #
      # @param _name [optional, Symbol] filter's name.
      # @yield code that must return a Boolean value.
      # @yieldparam organizer_item [Organizer::Source::Item]
      # @yieldreturn [Boolean]
      # @return [Organizer::Filter::Item]
      def add_default_filter(_name = nil, &block)
        filters_manager.add_default_filter(_name, &block)
      end

      # Adds a normal {Organizer::Filter::Item} to {Organizer::Filter::Manager}
      #
      # @param _name [Symbol] filter's name.
      # @yield code that must return a Boolean value.
      # @yieldparam organizer_item [Organizer::Source::Item]
      # @yieldreturn [Boolean]
      # @return [Organizer::Filter::Item]
      def add_filter(_name, &block)
        filters_manager.add_normal_filter(_name, &block)
      end

      # Adds a {Organizer::Filter::Item} with value to {Organizer::Filter::Manager}
      #
      # @param _name [Symbol] filter's name.
      # @yield code that must return a Boolean value.
      # @yieldparam organizer_item [Organizer::Source::Item]
      # @yieldparam value [Object]
      # @yieldreturn [Boolean]
      # @return [Organizer::Filter::Item]
      def add_filter_with_value(_name, &block)
        filters_manager.add_filter_with_value(_name, &block)
      end

      # Adds a new {Organizer::Operation::Simple} to {Organizer::Operation::Executer}
      #
      # @param _name [Symbol] name of the new item's attribute resulting of the operation execution.
      # @yield code that will return the operation's result
      # @yieldparam organizer_item [Organizer::Source::Item]
      # @return [Organizer::Operation::Simple]
      def add_simple_operation(_name, &block)
        operations.add_simple_operation(_name, &block)
      end

      # Adds a new {Organizer::Operation::Memo} to {Organizer::Operation::Executer}
      #
      # @param _name [Symbol] name of the new item's attribute resulting of the operation execution.
      # @param _initial_value [Object]
      # @yield code that will return the operation's result
      # @return [Organizer::Operation::Simple]
      def add_memo_operation(_name, _initial_value = 0, &block)
        group_operations.add_memo_operation(_name, _initial_value, &block)
      end

      # Adds a new {Organizer::Group::Item} to {Organizer::Group::Builder}
      #
      # @param _name [Symbol] symbol to identify this particular group.
      # @param _group_by_attr attribute by which the items will be grouped. If nil, _name will be used insted.
      # @param _parent_name stores the group parent name of the new group if has one.
      # @return [Organizer::Group::Item]
      def add_group(_name, _group_by_attr = nil, _parent_name = nil)
        groups.add_group(_name, _group_by_attr, _parent_name)
      end

      # Returns manager to handle filter issues.
      #
      # @return [Organizer::Filter::Manager]
      def filters_manager
        @filters_manager ||= Organizer::Filter::Manager.new
      end

      # Returns manager to handle operation issues.
      #
      # @return [Organizer::Operation::Executer]
      def operations_manager
        @operations_manager ||= Organizer::Operation::Executer.new
      end

      def collection_proc
        @collection_proc
      end

      def groups
        @groups ||= Organizer::Group::Collection.new
      end

      def operations
        @operations ||= Organizer::Operation::Collection.new
      end

      def group_operations
        @group_operations ||= Organizer::Operation::Collection.new
      end
    end

    module ChildInstanceMethods
      # @param _collection_options this data will be used to get the desired raw collection. Usually,
      # filters will be passed here.
      def initialize(_collection_options = {})
        @collection_options = _collection_options
      end

      # Applies filters, operations, groups, etc. to defined collection.
      #
      # @param _options [Hash]
      # @return [Organizer::Source::Collection]
      def organize(_options = {})
        filtered_collection = filters_manager.apply(collection, _options)
        Organizer::Operation::Executer.execute_on_source_items(operations, filtered_collection)
        result = Organizer::Group::Builder.build(filtered_collection, groups, _options)
        if result.is_a?(Organizer::Group::Collection)
          Organizer::Operation::Executer.execute_on_group_items(
            group_operations, filtered_collection, result)
        end
        result
      end

      # It returns collection stored as proc in collection_proc var converted to {Organizer::Source::Collection}
      #
      # @return [Organizer::Source::Collection] or [Organizer::Group::Item]
      def collection
        raise_error(:undefined_collection_method) unless collection_proc
        Organizer::Source::Collection.new.fill(collection_proc.call(collection_options))
      end

      private

      def filters_manager; self.class.filters_manager; end
      def groups; self.class.groups; end
      def operations; self.class.operations; end
      def group_operations; self.class.group_operations; end
      def collection_proc; self.class.collection_proc; end
      def collection_options; @collection_options ||= {}; end
    end
  end
end
