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
      expect { Organizer::Filter.new("not a proc") }.to(
        raise_organizer_error(:filter_definition_must_be_a_proc))
    end

    it "raise exception if _name is not defined" do
      proc = Proc.new {}
      expect { Organizer::Operation.new(proc, nil) }.to(
        raise_organizer_error(:blank_operation_name))
    end

  end

  describe "#execute" do

    it "raise exception if _item is not an Organizer::Item" do
      proc = Proc.new {}
      expect { Organizer::Operation.new(proc, :my_operation).execute("not an item") }.to(
        raise_organizer_error(:operations_over_organizer_items_only))
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

    it "raises error trying to redefine item param" do
      item = Organizer::Item.new
      item.define_attribute(:attr1, 4684)

      proc = Proc.new do
        # nothing special here
      end

      expect { Organizer::Operation.new(proc, :attr1).execute(item) }.to(
        raise_organizer_error(:method_redefinition_not_allowed))
    end

  end

end
