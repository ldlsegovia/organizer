module Organizer
  class DefinitionsKeeper
    include Organizer::Error

    attr_accessor :collection_options
    attr_reader :collection_proc
    attr_reader :groups
    attr_reader :filters, :source_default_filters
    attr_reader :source_operations, :group_parent_item_operations

    def initialize
      @filters = Organizer::Filter::Collection.new

      @source_default_filters = Organizer::Filter::Collection.new
      @source_operations = Organizer::Operation::Collection.new

      @groups = {}
      @group_parent_item_operations = Organizer::Operation::Collection.new
    end

    def add_collection(&block)
      @collection_proc = block
      nil
    end

    def collection
      raise_error(:undefined_collection_method) unless collection_proc
      Organizer::Source::Collection.new.fill(collection_proc.call(collection_options))
    end

    def add_default_filter(_name = nil, &block)
      @source_default_filters.add_filter(_name, &block)
    end

    def add_filter(_name, &block)
      @filters.add_filter(_name, &block)
    end

    def add_source_operation(_name, &block)
      @source_operations.add_simple_item(_name, &block)
    end

    def add_mask_operation(_attribute, _mask, _options = {})
      @source_operations.add_mask_item(_attribute, _mask, _options)
    end

    def add_group_parent_item_operation(_name, _initial_value = 0, &block)
      @group_parent_item_operations.add_group_parent_item(_name, _initial_value, &block)
    end

    def add_group_operation(_operation_name, _initial_value = 0, &block)
      @current_group_definition.add_parent_item_operation(_operation_name, _initial_value, &block)
    end

    def add_group_definition(_name, _group_by_attr = nil, _has_parent = false)
      if !_has_parent
        return false if !!@groups[_name]
        @current_groups_definitions = @groups[_name.to_sym] = Organizer::Group::DefinitionsCollection.new
      end

      @current_group_definition = @current_groups_definitions.add_definition(_name, _group_by_attr)
    end
  end
end
