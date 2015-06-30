require 'spec_helper'

describe Organizer::GroupOperation do
  describe "#initialize" do
    it "creates a new Operation instance" do
      proc = Proc.new {}
      o = Organizer::GroupOperation.new(proc, :my_operation, :my_group)
      expect(o.definition).to eq(proc)
      expect(o.name).to eq(:my_operation)
      expect(o.group_name).to eq(:my_group)
    end
  end
end
