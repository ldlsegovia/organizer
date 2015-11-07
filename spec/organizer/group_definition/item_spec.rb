require 'spec_helper'

describe Organizer::GroupDefinition::Item do
  before { @definition = Organizer::GroupDefinition::Item.new(:store_id) }

  describe "#initialize" do
    it "creates a group with name" do
      expect(@definition.item_name).to eq(:store_id)
    end
  end

  describe "#add_memo_operation" do
    it "adds operation" do
      result = @definition.add_memo_operation(:age_sum, 0, &-> {})
      expect(result).to be_a(Organizer::Operation::Memo)
    end
  end

  describe "attributes handler mixin" do
    let!(:instance) { Organizer::GroupDefinition::Item.new(:store_id) }
    let!(:error_class) { Organizer::GroupDefinition::ItemException }

    it_should_behave_like(:attributes_handler)
  end

  describe "collection item mixin" do
    let!(:item) { Organizer::GroupDefinition::Item.new(:item_name) }
    it_should_behave_like(:collection_item)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::GroupDefinition::Item.new(:item_name) }
    it_should_behave_like(:explainer)
  end
end
