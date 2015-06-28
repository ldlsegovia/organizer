class Organizer::Context
  attr_reader :type
  attr_reader :data
  attr_accessor :organizer_class_proc

  # @param _type [Symbol] can be group, operation, etc.
  # @param _data [Object] data relative to this context. Can be anything...
  def initialize(_type, _data)
    @type = _type.to_sym
    @data = _data
    @organizer_class_proc = nil
  end
end

class Organizer::ContextManager
  def initialize
    @ctx_collection = []
    @definitions_count = 0
  end

  # Opens a new context inside the hierarchy.
  #
  # @param _dsl [Organizer::DSL]
  # @param _ctx_type [Symbol] can be group, operation, etc.
  # @param _definition [Proc]
  # @return [Organizer::Context]
  def open(_dsl, _ctx_type, _definition = nil, &action)
    ctx = Organizer::Context.new(_ctx_type, {}) #TODO: pass useful data to context.
    @ctx_collection << ctx
    @definitions_count += 1
    prev_definitions_count = @definitions_count

    if !_definition.blank?
      _dsl.instance_eval(&_definition) rescue nil
      ctx.organizer_class_proc = _definition if prev_definitions_count == @definitions_count
    end

    _dsl.instance_eval(&action)
    close
  end

  # Returns true if the current context has no parent.
  #
  # @return [Boolean]
  def root_parent?
    @ctx_collection.one?
  end

  # Returns true if the current context has a group parent.
  #
  # @return [Boolean]
  def group_parent?
    (@ctx_collection[-2].type == :group) rescue false
  end

  private

  def close
    @ctx_collection.pop
  end
end
