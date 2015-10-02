class Organizer::ChainedMethod
  attr_reader :name
  attr_reader :args

  # @param _method_name [Symbol] can be: :group_by, :filter_by, etc.
  # @param _method_args [Symbol] params _method was called. For example: if I call group_by(:site), _args will store :site symbol
  def initialize(_method_name, _method_args)
    @name = _method_name
    @args = _method_args
  end

  def is?(_method_name)
    name.to_s == _method_name.to_s
  end

  def args?
    !args.blank?
  end
end

class Organizer::Chainer
  include Organizer::Error

  CHAINABLE_METHODS = [
    { method: :skip_default_filters, chainable_with: [:filter_by] },
    { method: :filter_by, chainable_with: [:skip_default_filters, :filter_by] },
    { method: :group_by, chainable_with: [:skip_default_filters, :filter_by, :group_by] }
  ]

  # @param _method can be: :group_by, :filter_by, etc.
  # @param _args params _method was called. For example: if I call group_by(:site), _args will store :site symbol
  # @return [Boolean]
  def chain(_method, _args)
    chained_methods << Organizer::ChainedMethod.new(_method, _args.flatten)
    self
  end

  # Checks if _method is a chainable method and it is, checks if can be chained with
  #   previous chained method.
  #
  # @param _method can be: :group_by, :filter_by, etc.
  # @return [Boolean]
  def chainable_method?(_method)
    result = chainable_methods.include?(_method)
    raise_error(:invalid_chaining) unless can_chain?(_method)
    result
  end

  # It returns chained methods array with the following structure:
  #   [{ method: :method_name, args: xxx }, { method: :method_name, args: xxx }]
  #
  # @return [Array]
  def chained_methods
    @chained_methods ||= []
  end

  private

  def chainable_methods
    CHAINABLE_METHODS.collect { |chainable| chainable[:method] }
  end

  def can_chain?(_method)
    return true if chained_methods.empty?
    last_method = chained_methods.last
    methods = chainable_with(_method)
    methods.include?(last_method.name)
  end

  def chainable_with(_method)
    chainable = CHAINABLE_METHODS.find { |cm| cm[:method] == _method }
    return [] unless chainable
    chainable[:chainable_with]
  end
end
