module Organizer
  module Executor
    include Organizer::Error

    def self.run(_definitions, _chainer)
      executors = []
      load_operations_executor(executors, _definitions)
      load_default_filters_executor(executors, _definitions, _chainer.collection_methods)
      load_filters_executor(executors, _definitions, _chainer.collection_methods)
      load_sort_items_executor(executors, _chainer.collection_methods)
      load_groups_executor(executors, _definitions, _chainer.group_methods)
      load_group_operations_executor(executors, _definitions)
      load_group_filters_executor(executors, _definitions, _chainer.group_methods)
      load_group_sort_items_executor(executors, _chainer.group_methods)
      execute(executors.shift, _definitions.collection, executors)
    end

    def self.load_operations_executor(_executors, _definitions)
      load_executor(_executors) do |source|
        Organizer::Operation::Executor.execute_on_source(_definitions.operations, source)
      end
    end

    def self.load_default_filters_executor(_executors, _definitions, _collection_methods)
      filters = Organizer::Filter::Selector.select_default(_definitions.default_filters, _collection_methods)
      load_executor(_executors) do |source|
        Organizer::Filter::Applier.apply(filters, source)
      end
    end

    def self.load_filters_executor(_executors, _definitions, _collection_methods)
      filters = Organizer::Filter::Selector.select_filters(_definitions.filters, _collection_methods)
      load_executor(_executors) do |source|
        Organizer::Filter::Applier.apply(filters, source)
      end if filters
    end

    def self.load_sort_items_executor(_executors, _collection_methods)
      sort_items = Organizer::Sort::Builder.build_sort_items(_collection_methods)
      load_executor(_executors) do |source|
        Organizer::Sort::Applier.apply(sort_items, source)
      end if sort_items
    end

    def self.load_groups_executor(_executors, _definitions, _group_methods)
      groups = Organizer::Group::Selector.select_groups(_definitions.groups, _group_methods)
      load_executor(_executors) do |source|
        Organizer::Group::Builder.build(source, groups)
      end if groups
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

    def self.load_group_filters_executor(_executors, _definitions, _group_methods)
      filters = Organizer::Filter::Selector.select_groups_filters(_definitions.filters, _group_methods)
      load_executor(_executors) do |source|
        if source.is_a?(Organizer::Group::Collection)
          Organizer::Filter::Applier.apply_groups_filters(filters, source)
        else
          source
        end
      end if filters
    end

    def self.load_group_sort_items_executor(_executors, _group_methods)
      groups_sort_items = Organizer::Sort::Builder.build_groups_sort_items(_group_methods)
      load_executor(_executors) do |source|
        if source.is_a?(Organizer::Group::Collection)
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
  end
end
