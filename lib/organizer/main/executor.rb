module Organizer
  module Executor
    include Organizer::Error

    def self.run(_definitions, _chainer)
      @definitions = _definitions
      @chainer = _chainer
      @executors = []

      load_operations_executor
      load_default_filters_executor
      load_filters_executor
      load_sort_items_executor

      load_groups_executor

      if @selected_group_definitions
        load_group_operations_executor
        load_group_filters_executor
        load_group_sort_items_executor
      end

      execute(@executors.shift, _definitions.collection, @executors)
    end

    def self.load_operations_executor
      load_executor do |source|
        Organizer::Operation::SourceExecutor.execute(@definitions.operations, source)
      end
    end

    def self.load_default_filters_executor
      filters = Organizer::Filter::Selector.select_default(
        @definitions.default_filters, @chainer.skip_default_filter_methods)

      load_executor do |source|
        Organizer::Filter::SourceApplier.apply(filters, source)
      end
    end

    def self.load_filters_executor
      filters = Organizer::Filter::Selector.select_filters(
        @definitions.filters, @chainer.filter_methods(:hash))

      load_executor do |source|
        Organizer::Filter::SourceApplier.apply(filters, source)
      end if filters
    end

    def self.load_sort_items_executor
      sort_items = Organizer::Sort::Builder.build_sort_items(@chainer.sort_methods(:hash))

      load_executor do |source|
        Organizer::Sort::SourceApplier.apply(sort_items, source)
      end if sort_items
    end

    def self.load_groups_executor
      load_executor do |source|
        @selected_group_definitions = Organizer::Group::Selector.select(
          @definitions.groups, @chainer.group)

        groups = @selected_group_definitions.groups_from_definitions if @selected_group_definitions
        Organizer::Group::Builder.build(source, groups)
      end
    end

    def self.load_group_operations_executor
      load_executor do |source|
        grouped_operations = Organizer::Operation::Selector.select_group_operations(
          @definitions.groups_operations, @selected_group_definitions)

        Organizer::Operation::GroupExecutor.execute_based_on_children(
          grouped_operations, @definitions.collection, source)
      end
    end

    def self.load_group_filters_executor
      grouped_filters = Organizer::Filter::Selector.select_groups_filters(
        @definitions.filters, @chainer.filter_group_methods(:hash), @selected_group_definitions)

      load_executor do |source|
        Organizer::Filter::GroupApplier.apply(grouped_filters, source)
      end if grouped_filters
    end

    def self.load_group_sort_items_executor
      grouped_sort_items = Organizer::Sort::Builder.build_groups_sort_items(
        @chainer.sort_group_methods(:hash), @selected_group_definitions)

      load_executor do |source|
        Organizer::Sort::GroupApplier.apply(grouped_sort_items, source)
      end if grouped_sort_items
    end

    def self.load_executor
      @executors << Proc.new do |source|
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
