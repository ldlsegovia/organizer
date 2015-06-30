class Organizer::Context
  attr_reader :type
  attr_accessor :data

  # @param _type [Symbol] can be group, operation, etc.
  # @param _data [Object] data relative to this context. Can be anything...
  def initialize(_type)
    @type = _type.to_sym
  end
end

class Organizer::ContextManager
  def initialize
    @ctx_collection = []
  end

  # Opens a new context inside the hierarchy.
  #
  # @param _dsl [Organizer::DSL]
  # @param _ctx_type [Symbol] can be group, operation, etc.
  # @param _definition [Proc]
  # @return [Organizer::Context]
  def open(_dsl, _ctx_type, _definition = nil, &action)
    ctx = Organizer::Context.new(_ctx_type)
    @ctx_collection << ctx
    ctx.data = _dsl.instance_eval(&action)
    _dsl.instance_eval(&_definition) if _definition
    close
  end

  # Returns true with no parent contexts.
  #
  # @return [Boolean]
  def root_parent?
    @ctx_collection.one?
  end

  # Returns true if the current context has a group parent.
  #
  # @return [Boolean]
  def group_parent?
    (parent_ctx.type == :group) rescue false
  end

  # Returns parent context
  #
  # @return [Object]
  def parent_ctx
    @ctx_collection[-2]
  end

  private

  def close
    @ctx_collection.pop
  end
end
