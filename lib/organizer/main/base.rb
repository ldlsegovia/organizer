module Organizer
  class Base
    include Organizer::Error

    def self.inherited(child_class)
      child_class.extend(ChildClassMethods)
      child_class.send(:include, ChildInstanceMethods)
      super
    end

    module ChildClassMethods
      def add_collection(&block)
        @collection_proc = block
        nil
      end

      def add_default_filter(_name = nil, &block)
        default_filters.add_filter(_name, &block)
      end

      def add_filter(_name, &block)
        filters.add_filter(_name, &block)
      end

      def add_simple_operation(_name, &block)
        operations.add_simple_operation(_name, &block)
      end

      def add_memo_operation(_name, _initial_value = 0, &block)
        group_operations.add_memo_operation(_name, _initial_value, &block)
      end

      def add_group(_name, _group_by_attr = nil, _parent_name = nil)
        groups.add_group(_name, _group_by_attr, _parent_name)
      end

      def collection_proc; @collection_proc; end

      def groups; @groups ||= Organizer::Group::Collection.new; end

      def filters; @filters ||= Organizer::Filter::Collection.new; end

      def default_filters; @default_filters ||= Organizer::Filter::Collection.new; end

      def operations; @operations ||= Organizer::Operation::Collection.new; end

      def group_operations; @group_operations ||= Organizer::Operation::Collection.new; end
    end

    module ChildInstanceMethods
      def initialize(_collection_options = {})
        @collection_options = _collection_options
      end

      def collection
        raise_error(:undefined_collection_method) unless collection_proc
        Organizer::Source::Collection.new.fill(collection_proc.call(collection_options))
      end

      def method_missing(_method, *_args, &_block)
        if chainer.chainable_method?(_method)
          chainer.chain(_method, _args)
          return self
        end

        super
      end

      def organize
        result = executor.run
        @chainer = nil
        result
      end

      def chainer
        @chainer ||= Organizer::Chainer.new
      end

      def default_filters; self.class.default_filters; end

      def filters; self.class.filters; end

      def groups; self.class.groups; end

      def operations; self.class.operations; end

      def group_operations; self.class.group_operations; end

      def collection_proc; self.class.collection_proc; end

      def collection_options; @collection_options ||= {}; end

      private

      def executor
        @executor ||= Organizer::Executor.new(self)
      end
    end
  end
end
