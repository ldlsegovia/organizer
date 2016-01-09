module Organizer
  class DefinitionsKeeper
    include Organizer::Error

    attr_accessor :collection_options, :collection_proc
    attr_reader :filters
    attr_reader :source_default_filters, :source_operations
    attr_reader :groups
    attr_reader :groups_parent_item_operations, :groups_item_operations

    def initialize
      @filters = Organizer::Filter::Collection.new

      @source_default_filters = Organizer::Filter::Collection.new
      @source_operations = Organizer::Operation::Collection.new

      @groups = {}
      @groups_parent_item_operations = Organizer::Operation::Collection.new
      @groups_item_operations = Organizer::Operation::Collection.new
    end

    def add_collection(&block)
      @collection_proc = block
      nil
    end

    def collection
      raise_error(:undefined_collection_method) unless collection_proc
      Organizer::Source::Collection.new.fill(collection_proc.call(collection_options))
    end

    def add_filter(_name, &block)
      @filters.add(_name, &block)
    end

    def add_source_default_filter(_name = nil, &block)
      @source_default_filters.add(_name, &block)
    end

    def add_source_operation(_name, _mask = nil, &block)
      options = {}
      load_mask_option(options, _mask)
      @source_operations.add(_name, options, &block)
    end

    def add_source_mask_operation(_attribute, _mask, _options = {})
      mask = Organizer::Operation::MaskBuilder.build(_attribute, _mask, _options)
      @source_operations << mask
    end

    def add_groups_parent_item_operation(_name, _initial_value = nil, _mask = nil, &block)
      options = { initial_value: _initial_value }
      load_mask_option(options, _mask)
      @groups_parent_item_operations.add(_name, options, &block)
    end

    def add_groups_item_operation(_name, _mask = nil, &block)
      options = {}
      load_mask_option(options, _mask)
      @groups_item_operations.add(_name, options, &block)
    end

    def add_group_parent_item_operation(_operation_name, _initial_value = nil, _mask = nil, &block)
      options = { initial_value: _initial_value }
      load_mask_option(options, _mask)
      @current_group_definition.parent_item_operations.add(_operation_name, options, &block)
    end

    def add_group_item_operation(_operation_name, _mask = nil, &block)
      options = {}
      load_mask_option(options, _mask)
      @current_group_definition.item_operations.add(_operation_name, options, &block)
    end

    def add_group_child_item_operation(_operation_name, _mask = nil, &block)
      options = {}
      load_mask_option(options, _mask)
      @current_group_definition.child_item_operations.add(_operation_name, options, &block)
    end

    def add_group_definition(_name, _group_by_attr = nil, _has_parent = false)
      if !_has_parent
        return false if !!@groups[_name]
        @current_groups_definitions = @groups[_name.to_sym] = Organizer::Group::DefinitionsCollection.new
      end

      @current_group_definition = @current_groups_definitions.add(_name, _group_by_attr)
    end

    private

    def load_mask_option(_options, _mask_data)
      if _mask_data
        if _mask_data.is_a?(Hash)
          mask_name = _mask_data.keys.first
          mask_options = _mask_data[mask_name]
          _options[:mask] = { name: mask_name, options: mask_options }
        else
          _options[:mask] = { name: _mask_data }
        end
      end
    end
  end
end
