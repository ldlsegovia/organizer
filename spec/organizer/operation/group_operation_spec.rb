require 'spec_helper'

describe Organizer::GroupOperation do
  describe "#initialize" do
    it "creates a new Operation instance" do
      proc = Proc.new {}
      o = Organizer::GroupOperation.new(proc, :my_operation, :my_group, 666)
      expect(o.definition).to eq(proc)
      expect(o.name).to eq(:my_operation)
      expect(o.group_name).to eq(:my_group)
      expect(o.initial_value).to eq(666)
    end
  end

  describe "#execute" do
    let_collection(:collection)
    before { @group_item = Organizer::Group::SubItem.new(collection) }

    it "raise exception if _item is not an Organizer::Group::SubItem" do
      expect { Organizer::GroupOperation.new(Proc.new {}, :my_operation, :my_group).execute("not a group item") }.to(
        raise_organizer_error(Organizer::GroupOperationException, :execute_over_organizer_group_items_only))
    end

    it "sets operation result as new attribute into group item param" do
      proc = Proc.new do |group_item, item|
        group_item.attrs_sum + item.age
      end

      Organizer::GroupOperation.new(proc, :attrs_sum, :my_group).execute(@group_item)
      expect(@group_item.attrs_sum).to eq(322)
    end

    it "sets initial value" do
      proc = Proc.new do |group_item, item|
        group_item.attrs_sum + item.age
      end

      Organizer::GroupOperation.new(proc, :attrs_sum, :my_group, 344).execute(@group_item)
      expect(@group_item.attrs_sum).to eq(666)
    end
  end
end
