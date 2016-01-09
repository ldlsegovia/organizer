module Organizer
  class DSL
    include Organizer::Error

    def initialize(_organizer_name, &block)
      @organizer_class = create_organizer_class(_organizer_name)
      @ctx = Organizer::ContextManager.new
      instance_eval(&block)
      nil
    end

    def collection(&nested_definition)
      in_context(nested_definition, true) do
        raise_error(:forbidden_nesting) unless @ctx.root_parent?
      end
    end

    def source(&block)
      in_context(nil, true) do
        if @ctx.collection_parent?
          @organizer_class.add_collection(&block)
        else
          raise_error(:forbidden_nesting)
        end
      end
    end

    def default_filter(_name = nil, &block)
      in_context do
        if @ctx.collection_parent?
          @organizer_class.add_source_default_filter(_name, &block)
        else
          raise_error(:forbidden_nesting)
        end
      end
    end

    def generate_filters_for(*_attributes)
      in_context do
        if @ctx.root_parent?
          filters = Organizer::Filter::Generator.generate(_attributes)
          filters.each { |filter| @organizer_class.add_filter(filter.item_name, &filter.definition) }
        else
          raise_error(:forbidden_nesting)
        end
      end
    end

    def filter(_name, &block)
      in_context do
        if @ctx.root_parent?
          @organizer_class.add_filter(_name, &block)
        else
          raise_error(:forbidden_nesting)
        end
      end
    end

    def human(_attribute, _mask = :clean, _options = {})
      in_context do
        if @ctx.collection_parent?
          @organizer_class.add_source_mask_operation(_attribute, _mask, _options)
        else
          raise_error(:forbidden_nesting)
        end
      end
    end

    def operation(_name, _mask = nil, &block)
      in_context do
        if @ctx.collection_parent?
          @organizer_class.add_source_operation(_name, _mask, &block)
        elsif @ctx.groups_parent?
          @organizer_class.add_groups_item_operation(_name, _mask, &block)
        elsif @ctx.group_parent?
          @organizer_class.add_group_item_operation(_name, _mask, &block)
        else
          raise_error(:forbidden_nesting)
        end
      end
    end

    def parent_operation(_name, _initial_value = nil, _mask = nil, &block)
      in_context do
        if @ctx.groups_parent?
          @organizer_class.add_groups_parent_item_operation(_name, _initial_value, _mask, &block)
        elsif @ctx.group_parent?
          @organizer_class.add_group_parent_item_operation(_name, _initial_value, _mask, &block)
        else
          raise_error(:forbidden_nesting)
        end
      end
    end

    def child_operation(_name, _mask = nil, &block)
      in_context do
        if @ctx.group_parent?
          @organizer_class.add_group_child_item_operation(_name, _mask, &block)
        else
          raise_error(:forbidden_nesting)
        end
      end
    end

    def groups(&nested_definition)
      in_context(nested_definition, true) do
        raise_error(:forbidden_nesting) unless @ctx.root_parent?
      end
    end

    def group(_name, _group_by_attr = nil, &nested_definition)
      in_context(nested_definition) do
        if @ctx.groups_parent?
          group = @organizer_class.add_group_definition(_name, _group_by_attr)
          raise_error(:forbidden_nesting) unless group
          group
        elsif @ctx.group_parent?
          raise_error(:forbidden_nesting) if @ctx.same_prev_ctx_parent?
          @organizer_class.add_group_definition(_name, _group_by_attr, !!@ctx.parent_ctx.data)
        else
          raise_error(:forbidden_nesting)
        end
      end
    end

    private

    def in_context(_nested_definition = nil, _execute_once = false, &action)
      ctx_type = caller[0][/`.*'/][1..-2]
      raise_error(:forbidden_nesting) if _execute_once && @ctx.already_executed?(ctx_type)
      @ctx.open(self, ctx_type, _nested_definition, &action)
      nil
    end

    def create_organizer_class(_organizer_name)
      class_name = _organizer_name.to_s.classify
      Object.const_set(class_name, Class.new(Organizer::Base))

    rescue
      raise_error(:invalid_organizer_name)
    end
  end
end
