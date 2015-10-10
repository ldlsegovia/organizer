class Organizer::ChainedMethod
  attr_reader :name, :args

  Organizer::Chainer::CHAINABLE_METHODS.each do |method|
    method_name = method[:method]
    define_method("#{method_name}?") do
      name == method_name
    end
  end

  def initialize(_method_name, _method_args)
    @name = _method_name
    @args = _method_args
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

  def is?(_method_name)
    name.to_s == _method_name.to_s
  end
end
