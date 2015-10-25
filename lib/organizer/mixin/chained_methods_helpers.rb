module Organizer
  module ChainedMethodsHelpers
    def for_each_group_methods(_group_methods, *_method_names)
      group_methods = []

      _group_methods.reverse_each do |method|
        if _method_names.include?(method.name)
          group_methods << method
        elsif method.group_by? && !group_methods.empty?
          yield(method.args.first, group_methods)
          group_methods = []
        end
      end
    end

    def methods_to_hash(_methods, _method_name)
      result = {}

      _methods.each do |method|
        next unless method.name == _method_name
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
end
