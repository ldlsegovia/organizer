module Organizer
  class Chainer
    include Organizer::Error

    attr_reader :group

    CHAINABLE_METHODS = [
      { name: :skip_default_filter, pattern: /\Askip_default_filters$/, scope: :collection },
      { name: :sort, pattern: /\Asort_by$/, scope: :collection },
      { name: :limit, pattern: /\Alimit$/, scope: :collection },
      { name: :filter, pattern: /\Afilter_by$/, scope: :collection },
      { name: :group, pattern: /\Agroup_by_\w+$/, scope: nil },
      { name: :sort_group, pattern: /\Asort_\w+_by$/, scope: :group },
      { name: :filter_group, pattern: /\Afilter_\w+_by$/, scope: :group }
    ]

    CHAINABLE_METHODS.each do |method|
      instance_eval do
        define_method("#{method[:name]}_methods") do |*args_as|
          args_as = args_as.first
          methods = @chained_methods.select { |m| method[:name] == m.name }
          return normalize_methods(methods, args_as) if method[:scope] === :collection
          get_grouped_methods(methods, args_as)
        end
      end
    end

    def initialize
      @chained_methods = []
      @group = nil
    end

    def chain(_method_name, _args)
      method = build_method(_method_name, _args)
      validate_chaining(method)
      method.group? ? @group = method : @chained_methods << method
      self
    end

    def chainable_method?(_method_name)
      !get_method_definition(_method_name).blank?
    end

    private

    def build_method(_method_name, _args)
      definition = get_method_definition(_method_name)

      group_name = if definition[:name] == :group
                     _method_name.to_s.gsub("group_by_", "")
                   elsif definition[:scope] == :group
                     group_name_from_method_name(definition, _method_name)
                   end

      Organizer::ChainedMethod.new(definition[:name], _args.flatten, group_name)
    end

    def group_name_from_method_name(_definition, _method_name)
      parts = _method_name.to_s.split("_")
      parts.shift
      parts.pop
      parts.join("_")
    end

    def get_method_definition(_method_name)
      CHAINABLE_METHODS.find { |method| _method_name =~ method[:pattern] }
    end

    def validate_chaining(_method)
      raise_error(:invalid_chaining) if _method.group? && group
      validate_uniqueness(_method, :skip_default_filter)
      validate_uniqueness(_method, :limit)
    end

    def validate_uniqueness(_method, _method_name)
      return if @chained_methods.select { |method| method.name == _method.name }.empty?
      raise_error(:invalid_chaining) if _method.name == _method_name
    end

    def get_grouped_methods(_methods, _args_as)
      groups = {}
      group_names = _methods.map(&:group_name).uniq
      group_names.each do |group_name|
        group_methods = _methods.select { |m| m.group_name == group_name }
        groups[group_name.to_sym] = normalize_methods(group_methods, _args_as)
      end
      groups
    end

    def normalize_methods(_methods, _strategy = nil)
      return _methods unless _strategy
      return methods_to_hash(_methods) if _strategy == :hash
    end

    def methods_to_hash(_methods)
      result = {}

      _methods.each do |method|
        method.args.each do |arg|
          if arg.is_a?(Hash)
            result.merge!(arg)
          elsif arg.is_a?(Symbol) || arg.is_a?(String)
            result[arg] = nil
          end
        end
      end

      result
    end
  end

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
