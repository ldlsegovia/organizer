module Organizer
  class Base
    include Organizer::Error

    def self.inherited(child_class)
      child_class.extend(ChildClassMethods)
      child_class.send(:include, ChildInstanceMethods)
      super
    end

    module ChildClassMethods
      def definitions_keeper
        @definitions_keeper ||= Organizer::DefinitionsKeeper.new
      end

      def method_missing(_method, *_args, &_block)
        if definitions_keeper.respond_to?(_method)
          return definitions_keeper.send(_method, *_args, &_block)
        end

        super
      end
    end

    module ChildInstanceMethods
      def initialize(_collection_options = {})
        definitions_keeper.collection_options = _collection_options
      end

      def organize
        executor_args = Organizer::ExecutorArgs.new(chainer.collection_methods, chainer.group_methods)
        result = Organizer::Executor.run(definitions_keeper, executor_args)
        @chainer = nil
        result
      end

      private

      def method_missing(_method, *_args, &_block)
        if definitions_keeper.respond_to?(_method)
          return definitions_keeper.send(_method, *_args, &_block)

        elsif chainer.chainable_method?(_method)
          chainer.chain(_method, _args)
          return self
        end

        super
      end

      def chainer
        @chainer ||= Organizer::Chainer.new
      end

      def definitions_keeper
        self.class.definitions_keeper
      end
    end
  end
end
