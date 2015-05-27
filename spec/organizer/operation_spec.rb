require 'spec_helper'

describe Organizer::Operation do
  describe "#initialize" do
    it "creates a new Operation instance" do
      proc = Proc.new {}
      o = Organizer::Operation.new(proc, :my_operation)
      expect(o.definition).to eq(proc)
      expect(o.name).to eq(:my_operation)
    end

    it "raise exception if _definition is not a Proc" do
      expect { Organizer::Operation.new("not a proc", :my_operation) }.to(
        raise_organizer_error(Organizer::OperationException, :definition_must_be_a_proc))
    end

    it "raise exception if _name is not defined" do
      proc = Proc.new {}
      expect { Organizer::Operation.new(proc, nil) }.to(
        raise_organizer_error(Organizer::OperationException, :blank_name))
    end
  end

  describe "#execute" do
    it "raise exception if _item is not an Organizer::Item" do
      proc = Proc.new {}
      expect { Organizer::Operation.new(proc, :my_operation).execute("not an item") }.to(
        raise_organizer_error(Organizer::OperationException, :execute_over_organizer_items_only))
    end

    it "sets operation result as new attribute into item param" do
      hash = { attr1: 400, attr2: 266 }
      item = Organizer::Item.new
      item.define_attributes(hash)

      proc = Proc.new do |organizer_item|
        organizer_item.attr1 + organizer_item.attr2
      end

      item = Organizer::Operation.new(proc, :attrs_sum).execute(item)
      expect(item.attrs_sum).to eq(666)
    end
  end
end
