require 'spec_helper'

describe Organizer::Group::Definition do
  before { @definition = Organizer::Group::Definition.new(:store_id) }

  describe "#initialize" do
    it "creates a group with name" do
      expect(@definition.item_name).to eq(:store_id)
    end
  end

  describe "#add_parent_item_operation" do
    it "adds operation passing opertaion data" do
      result = @definition.add_parent_item_operation(:age_sum, 0, &-> {})
      expect(result).to be_a(Organizer::Group::Operation::ParentItem)
    end

    it "adds operation passing operation instance" do
      operation = Organizer::Group::Operation::ParentItem.new(Proc.new {}, :age_sum, 0)
      result = @definition.add_parent_item_operation(operation)
      expect(result).to be_a(Organizer::Group::Operation::ParentItem)
    end
  end

  describe "attributes handler mixin" do
    let!(:instance) { Organizer::Group::Definition.new(:store_id) }
    let!(:error_class) { Organizer::Group::DefinitionException }

    it_should_behave_like(:attributes_handler)
  end

  describe "collection item mixin" do
    let!(:item) { Organizer::Group::Definition.new(:item_name) }
    it_should_behave_like(:collection_item)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Group::Definition.new(:item_name) }
    it_should_behave_like(:explainer)
  end
end
