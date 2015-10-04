module Organizer
  class DSL
    include Organizer::Error

    attr_reader :context

    def initialize(_organizer_name, &block)
      @organizer_class = create_organizer_class(_organizer_name)
      @ctx = Organizer::ContextManager.new
      instance_eval(&block)
      nil
    end

    def collection(&block)
      in_root_context { @organizer_class.add_collection(&block) }
    end

    def default_filter(_name = nil, &block)
      in_root_context { @organizer_class.add_default_filter(_name, &block) }
    end

    def filter(_name, &block)
      in_root_context do
        @organizer_class.add_filter(_name, &block)
      end
    end

    def operation(_name, _initial_value = 0, &block)
      in_context do
        if @ctx.root_parent?
          @organizer_class.add_simple_operation(_name, &block)
        elsif @ctx.groups_parent?
          @organizer_class.add_memo_operation(_name, _initial_value, &block)
        else
          raise_error(:forbidden_nesting)
        end
      end
    end

    def groups(&nested_definition)
      in_context(nested_definition) do
        raise_error(:forbidden_nesting) unless @ctx.root_parent?
      end
    end

    def group(_name, _group_by_attr = nil, &nested_definition)
      in_context(nested_definition) do
        if @ctx.groups_parent?
          @organizer_class.add_group(_name, _group_by_attr)
        elsif @ctx.group_parent?
          if @ctx.same_prev_ctx_parent?
            raise_error(:forbidden_nesting)
          else
            parent_name = @ctx.parent_ctx.data.group_name
            @organizer_class.add_group(_name, _group_by_attr, parent_name)
          end
        else
          raise_error(:forbidden_nesting)
        end
      end
    end

    private

    def in_context(_nested_definition = nil, &action)
      caller_method_name = caller[0][/`.*'/][1..-2]
      @ctx.open(self, caller_method_name, _nested_definition, &action)
      nil
    end

    def in_root_context
      in_context do
        if @ctx.root_parent?
          yield
        else
          raise_error(:forbidden_nesting)
        end
      end
    end

    def create_organizer_class(_organizer_name)
      class_name = _organizer_name.to_s.classify
      Object.const_set(class_name, Class.new(Organizer::Base))

    rescue
      raise_error(:invalid_organizer_name)
    end
  end
end
