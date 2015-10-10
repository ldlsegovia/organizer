class Organizer::ChainedMethod
  attr_reader :name, :args

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

  def chain(_method, _args)
    chained_methods << Organizer::ChainedMethod.new(_method, _args.flatten)
    self
  end

  def chainable_method?(_method)
    result = chainable_methods.include?(_method)
    raise_error(:invalid_chaining) unless can_chain?(_method)
    result
  end

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
