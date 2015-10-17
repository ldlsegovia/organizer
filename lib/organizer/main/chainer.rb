class Organizer::Chainer
  include Organizer::Error

  attr_reader :group_methods, :collection_methods

  CHAINABLE_METHODS = [
    :skip_default_filters,
    :filter_by,
    :group_by,
    :sort_by
  ]

  def initialize
    @is_groups_context = false
    @group_methods = []
    @collection_methods = []
  end

  def chain(_method, _args)
    method = Organizer::ChainedMethod.new(_method, _args.flatten)
    @is_groups_context = true if method.group_by?

    if method.skip_default_filters? && (@is_groups_context || !collection_methods.empty?)
      raise_error(:invalid_chaining)
    end

    @is_groups_context ? @group_methods << method : @collection_methods << method
    self
  end

  def chainable_method?(_method)
    CHAINABLE_METHODS.include?(_method)
  end

  def chained_methods
    @collection_methods + @group_methods
  end
end
