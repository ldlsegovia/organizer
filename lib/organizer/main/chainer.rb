module Organizer
  class Chainer
    include Organizer::Error

    CHAINABLE_METHODS = [
      { name: :skip_default_filter, pattern: /\Askip_default_filters$/, scope: :collection },
      { name: :sort, pattern: /\Asort_by$/, scope: :collection },
      { name: :filter, pattern: /\Afilter_by$/, scope: :collection },
      { name: :group, pattern: /\Agroup_by_\w+$/, scope: :group },
      { name: :sort_group, pattern: /\Asort_\w+_by$/, scope: :group },
      { name: :filter_group, pattern: /\Afilter_\w+_by$/, scope: :group }
    ]

    CHAINABLE_METHODS.each do |method|
      instance_eval do
        define_method("#{method[:name]}_methods") do
          @chained_methods.select { |m| method[:name] == m.name }
        end
      end
    end

    def initialize
      @chained_methods = []
    end

    def chain(_method_name, _args)
      method = build_method(_method_name, _args)
      validate_method(method)
      @chained_methods << method
      self
    end

    def chainable_method?(_method_name)
      !get_method_definition(_method_name).blank?
    end

    private

    def build_method(_method_name, _args)
      definition = get_method_definition(_method_name)
      group_name = group_name_from_method(definition, _method_name) if definition[:scope] == :group
      Organizer::ChainedMethod.new(definition[:name], _args.flatten, group_name)
    end

    def group_name_from_method(_definition, _method_name)
      return _method_name.to_s.gsub("group_by_", "") if _definition[:name] == :group
      parts = _method_name.to_s.split("_")
      parts.shift
      parts.pop
      parts.join("_")
    end

    def get_method_definition(_method_name)
      CHAINABLE_METHODS.find { |method| _method_name =~ method[:pattern] }
    end

    def validate_method(_method)
      validate_uniqueness(_method, :skip_default_filter)
      validate_uniqueness(_method, :group)
    end

    def validate_uniqueness(_method, _method_name)
      return if @chained_methods.select { |method| method.name == _method.name }.empty?
      raise_error(:invalid_chaining) if _method.name == _method_name
    end
  end
end
