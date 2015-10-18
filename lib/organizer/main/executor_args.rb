module Organizer
  class ExecutorArgs
    include Organizer::Error

    def initialize(_collection_methods, _group_methods)
      @collection_methods = _collection_methods
      @group_methods = _group_methods
    end

    def default_filters_to_skip
      skip_methods = @collection_methods.select(&:skip_default_filters?)
      return if skip_methods.empty?
      skip_all = skip_methods.find { |m| m.array_args_include?(:all) }
      args = skip_methods.map(&:args).flatten
      return :all if skip_all || args.blank?
      args
    end

    def filters(_methods = nil)
      args = {}
      _methods ||= @collection_methods

      _methods.each do |method|
        next unless method.filter_by?
        method.args.each do |arg|
          if hash?(arg)
            args.merge!(arg)
          elsif string?(arg)
            args[arg] = nil
          end
        end
      end

      return if args.keys.empty?
      args
    end

    def sort_items(_methods = nil)
      args = Organizer::Sort::Collection.new
      _methods ||= @collection_methods

      _methods.each do |method|
        next unless method.sort_by?
        method.args.each do |arg|
          if hash?(arg)
            arg.each { |attr_name, orientation| add_sort_item(args, attr_name, orientation) }
          elsif string?(arg)
            add_sort_item(args, arg)
          end
        end
      end

      return if args.empty?
      args
    end

    def groups_sort_items
      args_by_group(:sort_by, :sort_items)
    end

    def groups
      args = []

      @group_methods.each do |method|
        next unless method.group_by?
        args += method.args
      end

      return if args.empty?
      args.uniq
    end

    def groups_filters
      args_by_group(:filter_by, :filters)
    end

    private

    def args_by_group(_method_name, _build_with)
      args = {}
      group_data = []

      @group_methods.reverse_each do |method|
        if method.send("#{_method_name}?")
          group_data << method
        elsif method.group_by? && !group_data.empty?
          group_data_args = send(_build_with, group_data)
          args[method.args.first] = group_data_args if group_data_args
          group_data = []
        end
      end

      return if args.keys.empty?
      args
    end

    def add_sort_item(_args, _attr_name, _orientation = nil)
      descending = true if _orientation.to_s == "desc"
      _args.add_item(_attr_name.to_sym, descending)
    end

    def string?(_arg)
      _arg.is_a?(Symbol) || _arg.is_a?(String)
    end

    def hash?(_arg)
      _arg.is_a?(Hash)
    end
  end
end
