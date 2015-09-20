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
    chained_methods << { method: _method, args: _args.flatten }
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

  def organize
    executors = build_executors
    result = execute(executors.shift, @organizer.collection, executors)
    @organizer.reset_executor
    result
  end

  private

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
    chainable = CHAINABLE_METHODS.select { |cm| cm[:method] == _method }.first
    return [] unless chainable
    chainable[:chainable_with]
  end

  def build_executors
    executors = []
    load_default_filters_executor(executors)
    load_filters_executor(executors)
    load_operations_executor(executors)
    load_groups_executor(executors)
    load_group_operations_executor(executors)
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

    generated_filters = Organizer::Filter::Generator.generate(@organizer.collection.first)
    filters = Organizer::Filter::Collection.new
    generated_filters.each { |gf| filters << gf }
    @organizer.filters.each { |f| filters << f }

    chained_methods.each do |method|
      if [:filter_by].include?(method[:method])
        method[:args].each do |arg|
          if arg.is_a?(Hash)
            args.merge!(arg)
          elsif arg.is_a?(Symbol) || arg.is_a?(String)
            args[arg] = nil
          end
        end
      end
    end

    if !args.keys.empty?
      _executors << Proc.new do |source|
        Organizer::Filter::Applier.apply(filters, source, { filters: args })
      end
    end
  end

  def load_operations_executor(_executors)
    _executors << Proc.new do |source|
      Organizer::Operation::Executer.execute_on_source_items(@organizer.operations, source)
    end
  end

  def load_group_operations_executor(_executors)
    _executors << Proc.new do |source|
      if source.is_a?(Hash) && source.has_key?(:grouped_source)
        Organizer::Operation::Executer.execute_on_group_items(
          @organizer.group_operations, source[:source], source[:grouped_source])
      else
        source
      end
    end
  end

  def load_groups_executor(_executors)
    args = []

    chained_methods.each do |method|
      if [:group_by].include?(method[:method])
        method[:args].each do |arg|
          args << arg if arg.is_a?(Symbol) || arg.is_a?(String)
        end
      end
    end

    args.uniq!

    if !args.empty?
      _executors << Proc.new do |source|
        result = Organizer::Group::Builder.build(source, @organizer.groups, { group_by: args })
        { grouped_source: result, source: source }
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
