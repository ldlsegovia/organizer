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
    load_sort_items_executor(executors, _args)
    load_groups_executor(executors, _definitions, _args)
    load_group_operations_executor(executors, _definitions)
    load_group_filters_executor(executors, _definitions, _args)
    load_group_sort_items_executor(executors, _args)
    executors
  end

  def self.load_operations_executor(_executors, _definitions)
    load_executor(_executors) do |source|
      Organizer::Operation::Executor.execute_on_source(_definitions.operations, source)
    end
  end

  def self.load_default_filters_executor(_executors, _definitions, _args)
    args = _args.default_filters_to_skip
    load_executor(_executors) do |source|
      Organizer::Filter::Applier.apply_except_skipped(_definitions.default_filters, source, args)
    end
  end

  def self.load_filters_executor(_executors, _definitions, _args)
    args = _args.filters
    load_executor(_executors) do |source|
      Organizer::Filter::Applier.apply_selected(_definitions.filters, source, args)
    end if args
  end

  def self.load_sort_items_executor(_executors, _args)
    args = _args.sort_items
    load_executor(_executors) do |source|
      Organizer::Sort::Applier.apply_on_source(args, source)
    end if args
  end

  def self.load_groups_executor(_executors, _definitions, _args)
    args = _args.groups
    load_executor(_executors) do |source|
      Organizer::Group::Builder.build(source, _definitions.groups, args)
    end if args
  end

  def self.load_group_operations_executor(_executors, _definitions)
    load_executor(_executors) do |source|
      if source.is_a?(Organizer::Group::Collection)
        Organizer::Operation::Executor.execute_on_groups(
          _definitions.group_operations,
          _definitions.collection,
          source
        )
      else
        source
      end
    end
  end

  def self.load_group_filters_executor(_executors, _definitions, _args)
    args = _args.groups_filters
    load_executor(_executors) do |source|
      if source.is_a?(Organizer::Group::Collection)
        Organizer::Filter::Applier.apply_selected_on_groups(_definitions.filters, source, args)
      else
        source
      end
    end if args
  end

  def self.load_group_sort_items_executor(_executors, _args)
    args = _args.groups_sort_items
    load_executor(_executors) do |source|
      if source.is_a?(Organizer::Group::Collection)
        Organizer::Sort::Applier.apply_on_groups(args, source)
      else
        source
      end
    end if args
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
