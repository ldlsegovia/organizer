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

      # Adds a new {Organizer::Operation::SourceItem} to {Organizer::Operation::Manager}
      #
      # @param _name [Symbol] name of the new item's attribute resulting of the operation execution.
      # @yield code that will return the operation's result
      # @yieldparam organizer_item [Organizer::Source::Item]
      # @return [Organizer::Operation::SourceItem]
      def add_operation(_name, &block)
        operations_manager.add_operation(_name, &block)
      end

      # Adds a new {Organizer::Operation::GroupCollection} to {Organizer::Operation::Manager}
      #
      # @param _name [Symbol] name of the new item's attribute resulting of the operation execution.
      # @param _initial_value [Object]
      # @yield code that will return the operation's result
      # @return [Organizer::Operation::SourceItem]
      def add_group_operation(_name, _initial_value = 0, &block)
        operations_manager.add_group_operation(_name, _initial_value, &block)
      end

      # Adds a new {Organizer::Group::Item} to {Organizer::Group::Manager}
      #
      # @param _name [Symbol] symbol to identify this particular group.
      # @param _group_by_attr attribute by which the items will be grouped. If nil, _name will be used insted.
      # @return [Organizer::Group::Item]
      def add_group(_name, _group_by_attr = nil)
        groups_manager.add_group(_name, _group_by_attr)
      end

      # Returns manager to handle filter issues.
      #
      # @return [Organizer::Filter::Manager]
      def filters_manager
        @filters_manager ||= Organizer::Filter::Manager.new
      end

      # Returns manager to handle operation issues.
      #
      # @return [Organizer::Operation::Manager]
      def operations_manager
        @operations_manager ||= Organizer::Operation::Manager.new
      end

      # Returns manager to handle group issues.
      #
      # @return [Organizer::Group::Manager]
      def groups_manager
        @groups_manager ||= Organizer::Group::Manager.new
      end

      # Returns a proc containing an array collection
      #
      # @return [Array]
      def collection_proc
        @collection_proc
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
        operations_manager.execute_over_source_items(filtered_collection)
        result = groups_manager.build(filtered_collection, _options)
        if result.is_a?(Organizer::Group::Collection)
          operations_manager.execute_over_group_items(filtered_collection, result)
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
      def operations_manager; self.class.operations_manager; end
      def groups_manager; self.class.groups_manager; end
      def collection_proc; self.class.collection_proc; end
      def collection_options; @collection_options ||= {}; end
    end
  end
end
