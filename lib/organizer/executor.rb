module Organizer
  module Executor
    include Organizer::Error

    def self.run(_definitions, _chainer)
      @definitions = _definitions
      @chainer = _chainer
      @executors = []

      load_source_operations_executor
      load_source_default_filters_executor
      load_filters_executor
      load_sort_items_executor

      load_groups_executor
      load_group_parent_item_operations_executor
      load_group_filters_executor
      load_group_sort_items_executor

      execute(@executors.shift, _definitions.collection, @executors)
    end

    def self.load_source_operations_executor
      load_executor do |source|
        Organizer::Source::Operation::Executor.execute(@definitions.source_operations, source)
      end
    end

    def self.load_source_default_filters_executor
      filters = Organizer::Source::Filter::Selector.select_default(
        @definitions.source_default_filters, @chainer.skip_default_filter_methods)

      load_executor do |source|
        Organizer::Source::Filter::Applier.apply(filters, source)
      end
    end

    def self.load_filters_executor
      filters = Organizer::Source::Filter::Selector.select(
        @definitions.filters, @chainer.filter_methods(:hash))

      load_executor do |source|
        Organizer::Source::Filter::Applier.apply(filters, source)
      end
    end

    def self.load_sort_items_executor
      sort_items = Organizer::Source::Sort::Builder.build(@chainer.sort_methods(:hash))

      load_executor do |source|
        Organizer::Source::Sort::Applier.apply(sort_items, source)
      end
    end

    def self.load_groups_executor
      @selected_group_definitions = Organizer::Group::Selector.select(
        @definitions.groups, @chainer.group)

      load_executor do |source|
        groups = @selected_group_definitions.groups_from_definitions if @selected_group_definitions
        Organizer::Group::Builder.build(source, groups)
      end
    end

    def self.load_group_parent_item_operations_executor
      load_executor do |source|
        grouped_operations = Organizer::Operation::Selector.select_group_operations(
          @definitions.groups_parent_item_operations, @selected_group_definitions)

        Organizer::Group::Operation::ParentItemsExecutor.execute(
          grouped_operations, @definitions.collection, source)
      end
    end

    def self.load_group_filters_executor
      grouped_filters = Organizer::Group::Filter::Selector.select(
        @definitions.filters, @chainer.filter_group_methods(:hash), @selected_group_definitions)

      load_executor do |source|
        Organizer::Group::Filter::Applier.apply(grouped_filters, source)
      end
    end

    def self.load_group_sort_items_executor
      grouped_sort_items = Organizer::Group::Sort::Builder.build(
        @chainer.sort_group_methods(:hash), @selected_group_definitions)

      load_executor do |source|
        Organizer::Group::Sort::Applier.apply(grouped_sort_items, source)
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
