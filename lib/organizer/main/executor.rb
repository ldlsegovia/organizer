class Organizer::Executor
  include Organizer::Error

  def self.run(_definitions_keeper, _executor_args)
    executors = build_executors(_definitions_keeper, _executor_args)
    execute(executors.shift, _definitions_keeper.collection, executors)
  end

  def self.build_executors(_definitions, _args)
    executors = []
    load_operations_executor(executors, _definitions)
    load_default_filters_executor(executors, _definitions, _args)
    load_filters_executor(executors, _definitions, _args)
    load_groups_executor(executors, _definitions, _args)
    load_group_operations_executor(executors, _definitions)
    executors
  end

  def self.load_operations_executor(_executors, _definitions)
    load_executor(_executors) do |source|
      Organizer::Operation::Executor.execute(
        _definitions.operations,
        source
      )
    end
  end

  def self.load_default_filters_executor(_executors, _definitions, _args)
    args = _args.default_filters_to_skip
    load_executor(_executors) do |source|
      Organizer::Filter::Applier.apply(
        _definitions.default_filters,
        source,
        skipped_filters: args
      )
    end
  end

  def self.load_filters_executor(_executors, _definitions, _args)
    args = _args.filters
    load_executor(_executors) do |source|
      Organizer::Filter::Applier.apply(
        get_filters(_definitions),
        source,
        selected_filters: args)
    end if args
  end

  def self.get_filters(_definitions)
    # TODO: build generated filters using DLS https://github.com/ldlsegovia/organizer/issues/40
    generated_filters = Organizer::Filter::Generator.generate(_definitions.collection.first)
    filters = Organizer::Filter::Collection.new
    generated_filters.each { |gf| filters << gf }
    _definitions.filters.each { |f| filters << f }
    filters
  end

  def self.load_groups_executor(_executors, _definitions, _args)
    args = _args.groups
    load_executor(_executors) do |source|
      Organizer::Group::Builder.build(
        source,
        _definitions.groups,
        args)
    end if args
  end

  def self.load_group_operations_executor(_executors, _definitions)
    load_executor(_executors) do |source|
      if source.is_a?(Organizer::Group::Collection)
        Organizer::Operation::Executor.execute(
          _definitions.group_operations, _definitions.collection, source)
      else
        source
      end
    end
  end

  def self.load_executor(_executors)
    _executors << Proc.new do |source|
      yield(source)
    end
  end

  def self.execute(_proc, _source, _next_procs)
    return _source unless _proc
    result = _proc.call(_source)
    next_proc = _next_procs.shift
    return result unless next_proc
    execute(next_proc, result, _next_procs)
  end
end
