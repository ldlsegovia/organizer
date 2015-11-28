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
    before do
      @group_item = group_collection.first
      @source_item1 = @group_item.first
      @source_item2 = @group_item.second

      @proc = Proc.new do |memo, item|
        memo.age_sum + item.age
      end
    end

    it "uses memo attribute to keep old results" do
      Organizer::Operation::Memo.new(@proc, :age_sum).execute(@group_item, @source_item1)
      expect(@group_item.age_sum).to eq(@source_item1.age)
      Organizer::Operation::Memo.new(@proc, :age_sum).execute(@group_item, @source_item2)
      expect(@group_item.age_sum).to eq(@source_item1.age + @source_item2.age)
    end

    it "sets memo initial value" do
      Organizer::Operation::Memo.new(@proc, :age_sum, 10).execute(@group_item, @source_item1)
      expect(@group_item.age_sum).to eq(@source_item1.age + 10)
    end

    it "execute mask when defined" do
      mask_options = { name: :currency, options: { unit: "A", precision: 0 } }
      Organizer::Operation::Memo.new(@proc, :age_sum, 10, mask: mask_options).execute(@group_item, @source_item1)
      expect(@group_item.human_age_sum).to eq("A32")
    end
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Operation::Memo.new(-> {}, :my_operation, :my_group) }
    it_should_behave_like(:explainer)
  end
end
