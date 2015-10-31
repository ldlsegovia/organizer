module Organizer
  module ChainedMethodsHelpers
    def for_each_group_methods(_group_methods)
      group_names = _group_methods.map(&:group_name).uniq
      group_names.each do |group_name|
        group_methods = _group_methods.select { |m| m.group_name == group_name }
        yield(group_name.to_sym, group_methods)
      end
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
end
