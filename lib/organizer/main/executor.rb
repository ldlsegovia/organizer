module Organizer
  module Executor
    include Organizer::Error

    def self.run(_definitions, _chainer)
      executors = []
      load_operations_executor(executors, _definitions)
      load_default_filters_executor(executors, _definitions, _chainer.skip_default_filter_methods)
      load_filters_executor(executors, _definitions, _chainer.filter_methods(:hash))
      load_sort_items_executor(executors, _chainer.sort_methods(:hash))

      @group_definitions = get_group_definitions(_definitions.groups, _chainer.group)
      load_groups_executor(executors)
      load_group_operations_executor(executors, _definitions.collection, _definitions.groups_operations)
      load_group_filters_executor(executors, _definitions, _chainer.filter_group_methods(:hash))
      load_group_sort_items_executor(executors, _chainer.sort_group_methods(:hash))

      execute(executors.shift, _definitions.collection, executors)
    end

    def self.load_operations_executor(_executors, _definitions)
      load_executor(_executors) do |source|
        Organizer::Operation::Executor.execute_on_source(_definitions.operations, source)
      end
    end

    def self.load_default_filters_executor(_executors, _definitions, skip_default_filter_methods)
      filters = Organizer::Filter::Selector.select_default(_definitions.default_filters, skip_default_filter_methods)
      load_executor(_executors) do |source|
        Organizer::Filter::Applier.apply(filters, source)
      end
    end

    def self.load_filters_executor(_executors, _definitions, _filter_methods)
      filters = Organizer::Filter::Selector.select_filters(_definitions.filters, _filter_methods)
      load_executor(_executors) do |source|
        Organizer::Filter::Applier.apply(filters, source)
      end if filters
    end

    def self.load_sort_items_executor(_executors, _sort_methods)
      sort_items = Organizer::Sort::Builder.build_sort_items(_sort_methods)
      load_executor(_executors) do |source|
        Organizer::Sort::Applier.apply(sort_items, source)
      end if sort_items
    end

    def self.load_groups_executor(_executors)
      load_executor(_executors) do |source|
        hierarchy = @group_definitions.map(&:group)
        Organizer::Group::Builder.build(source, hierarchy)
      end if @group_definitions
    end

    def self.load_group_operations_executor(_executors, _collection, _global_operations)
      load_executor(_executors) do |source|
        if @group_definitions
          operations = Organizer::Operation::Selector.select_group_operations(
            _global_operations, @group_definitions)
          Organizer::Operation::Executor.execute_on_groups(operations, _collection, source)
        else
          source
        end
      end
    end

    def self.load_group_filters_executor(_executors, _definitions, _filter_group_methods)
      filters = Organizer::Filter::Selector.select_groups_filters(_definitions.filters, _filter_group_methods, @group_definitions)

      load_executor(_executors) do |source|
        if @group_definitions
          Organizer::Filter::Applier.apply_groups_filters(filters, source)
        else
          source
        end
      end if filters
    end

    def self.load_group_sort_items_executor(_executors, _sort_group_methods)
      groups_sort_items = Organizer::Sort::Builder.build_groups_sort_items(_sort_group_methods, @group_definitions)

      load_executor(_executors) do |source|
        if @group_definitions
          Organizer::Sort::Applier.apply_on_groups(groups_sort_items, source)
        else
          source
        end
      end if groups_sort_items
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

    def self.get_group_definitions(_definitions, _group_method)
      return if _group_method.blank?
      _definitions[_group_method.group_name.to_sym].clone
    end
  end
end
