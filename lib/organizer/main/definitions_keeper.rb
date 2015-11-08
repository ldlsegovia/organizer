module Organizer
  class DefinitionsKeeper
    include Organizer::Error

    attr_accessor :collection_options
    attr_reader :collection_proc
    attr_reader :groups
    attr_reader :filters, :default_filters
    attr_reader :operations, :groups_operations

    def initialize
      @groups = {}
      @filters = Organizer::Filter::Collection.new
      @default_filters = Organizer::Filter::Collection.new
      @operations = Organizer::Operation::Collection.new
      @groups_operations = Organizer::Operation::Collection.new
      @grouped_operations = Organizer::GroupDefinition::Collection.new
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
      @default_filters.add_filter(_name, &block)
    end

    def add_filter(_name, &block)
      @filters.add_filter(_name, &block)
    end

    def add_source_operation(_name, &block)
      @operations.add_simple_operation(_name, &block)
    end

    def add_groups_operation(_name, _initial_value = 0, &block)
      @groups_operations.add_memo_operation(_name, _initial_value, &block)
    end

    def add_group_operation(_operation_name, _initial_value = 0, &block)
      @current_group.add_memo_operation(_operation_name, _initial_value, &block)
    end

    def add_group(_name, _group_by_attr = nil, _parent_name = nil)
      if !_parent_name
        return false if !!@groups[_name]
        @groups[_name] = Organizer::GroupDefinition::Collection.new
        @current_groups = @groups[_name]
      end

      @current_group = @current_groups.add_definition(_name, _group_by_attr, _parent_name)
    end
  end
end
