module Organizer
  class Context
    attr_reader :type
    attr_accessor :data
    attr_reader :identifier

    def initialize(_type)
      @type = _type.to_sym
      @identifier = SecureRandom.hex
    end
  end

  class ContextManager
    attr_reader :prev_ctx_hierarchy

    def initialize
      @ctx_hierarchy = []
      @prev_ctx_hierarchy = []
    end

    def open(_dsl, _ctx_type, _definition = nil, &action)
      ctx = Organizer::Context.new(_ctx_type)
      @ctx_hierarchy << ctx
      ctx.data = _dsl.instance_eval(&action) if action
      _dsl.instance_eval(&_definition) if _definition
      close
    end

    def root_parent?
      @ctx_hierarchy.one?
    end

    def group_parent?
      (parent_ctx.type == :group) rescue false
    end

    def groups_parent?
      (parent_ctx.type == :groups) rescue false
    end

    def parent_ctx
      @ctx_hierarchy[-2]
    end

    def same_prev_ctx_parent?
      parent_ctx == parent_prev_ctx
    end

    private

    def close
      @prev_ctx_hierarchy = @ctx_hierarchy.clone
      @ctx_hierarchy.pop
    end

    def parent_prev_ctx
      @prev_ctx_hierarchy[-2]
    end
  end
end
