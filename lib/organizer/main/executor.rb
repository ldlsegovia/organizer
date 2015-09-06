class Organizer::Executor
  include Organizer::Error

  CHAINABLE_METHODS = [
    { method: :skip_default_filters, chainable_with: [:filter_by] },
    { method: :filter_by, chainable_with: [:skip_default_filters, :filter_by] },
    { method: :group_by, chainable_with: [:skip_default_filters, :filter_by, :group_by] }
  ]

  # @param _organizer [Organizer::Base]
  def initialize(_organizer)
    @organizer = _organizer
  end

  def chain(_method, _args)
    _args = _args.first if _args.first.is_a?(Hash)
    chained_methods << { method: _method, args: _args }
    self
  end

  def chainable_method?(_method)
    chainable_methods.include?(_method)
  end

  def method_missing(_method, *_args, &_block)
    if chainable_method?(_method)
      raise_error(:invalid_chaining) unless can_chain?(_method)
      return chain(_method, _args)
    end

    super
  end

  def organize_data
    executors = build_executors
    result = execute(executors.shift, @organizer.collection, executors)
    @organizer.reset_executor
    result
  end

  def chainable_methods
    CHAINABLE_METHODS.collect { |chainable| chainable[:method] }
  end

  def can_chain?(_method)
    return true if chained_methods.empty?
    last_method = chained_methods.last
    methods = chainable_with(_method)
    methods.include?(last_method[:method])
  end

  def chainable_with(_method)
    chainable = CHAINABLE_METHODS.select { |chainable| chainable[:method] == _method }.first
    return [] unless chainable
    chainable[:chainable_with]
  end

  def build_executors
    executors = []
    load_default_filters_executor(executors)
    load_filters_executor(executors)
    executors
  end

  def load_default_filters_executor(_executors)
    skip_method = chained_methods.select { |method| method[:method] == :skip_default_filters }.first
    options = {}

    if skip_method
      options[:skip_default_filters] = skip_method[:args]
      options[:skip_default_filters] = :all if skip_method[:args].empty?
    end

    _executors << Proc.new do |source|
      Organizer::Filter::Applier.apply_default(@organizer.default_filters, source, options)
    end
  end

  def load_filters_executor(_executors)
    args = {}

    chained_methods.each do |method|
      if [:filter_by].include?(method[:method])
        if method[:args].is_a?(Hash)
          args.merge!(method[:args])

        elsif method[:args].is_a?(Array)
          method[:args].each do |filter_name|
             args[filter_name] = nil
          end
        end
      end
    end

    if !args.keys.empty?
      _executors << Proc.new do |source|
        Organizer::Filter::Applier.apply(@organizer.filters, source, { filters: args })
      end
    end
  end

  def chained_methods
    @chained_methods ||= []
  end

  def execute(_proc, _source, _next_procs)
    return _source unless _proc
    result = _proc.call(_source)
    next_proc = _next_procs.shift
    return result unless next_proc
    execute(next_proc, result, _next_procs)
  end
end
