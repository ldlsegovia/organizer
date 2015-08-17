require 'spec_helper'

describe Organizer::Operation::Memo do
  describe "#initialize" do
    it "creates a new Operation instance" do
      proc = Proc.new {}
      o = Organizer::Operation::Memo.new(proc, :my_operation, 666)
      expect(o.definition).to eq(proc)
      expect(o.item_name).to eq(:my_operation)
      expect(o.initial_value).to eq(666)
    end
  end

  describe "#execute" do
    let_group_collection(:group_collection, :site_id)
    before { @group_item = group_collection.first }

    it "sets operation result as new attribute into group item param" do
      proc = Proc.new do |attrs_sum, item|
        attrs_sum + item.age
      end

      Organizer::Operation::Memo.new(proc, :attrs_sum).execute(@group_item)
      expect(@group_item.attrs_sum).to eq(@group_item.inject(0) { |memo, item| memo += item.age })
    end

    it "sets initial value" do
      proc = Proc.new do |attrs_sum, item|
        attrs_sum + item.age
      end

      Organizer::Operation::Memo.new(proc, :attrs_sum, 10).execute(@group_item)
      expect(@group_item.attrs_sum).to eq(@group_item.inject(0) { |memo, item| memo += item.age } + 10)
    end
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Operation::Memo.new(->{}, :my_operation, :my_group) }
    it_should_behave_like(:explainer)
  end
end
