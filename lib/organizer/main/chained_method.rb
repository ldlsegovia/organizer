module Organizer
  class ChainedMethod
    attr_reader :name, :args, :group_name

    Organizer::Chainer::CHAINABLE_METHODS.each do |method|
      define_method("#{method[:name]}?") do
        name == method[:name]
      end
    end

    def initialize(_method_name, _method_args, _group_related = nil)
      @name = _method_name.to_sym
      @args = _method_args
      @group_name = _group_related
    end

    def collection_type?
      !@group_name
    end

    def group_type?
      !!@group_name
    end

    def args?
      !args.blank?
    end

    def hash_args?
      args? && args.first.is_a?(Hash)
    end

    def array_args?
      !hash_args?
    end

    def array_args_include?(_value)
      return false unless array_args?
      args.include?(_value)
    end
  end
end
