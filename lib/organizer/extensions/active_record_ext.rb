if !defined?(ActiveRecord::Base)
  module ActiveRecord
    class Base
      def attributes
        { msg: "you are using a fake ActiveRecord::Base class :P"}
      end
    end
  end
end

module ActiveRecordExtension
  def to_h
    self.attributes
  end
end

ActiveRecord::Base.send(:include, ActiveRecordExtension)
