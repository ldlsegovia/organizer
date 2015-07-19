require 'spec_helper'

describe Organizer::Group::SubItem do
  describe "#initialize" do
    let_collection(:collection)
    before { @group_item = Organizer::Group::SubItem.new(collection) }

    it "copies attributes from first collection item" do
      item = collection.first
      item.attribute_names.each do |attribute, value|
        expect(@group_item.send(attribute)).to eq(item.send(attribute))
      end
    end
  end

  describe "attributes handler mixin" do
    let!(:klass) { Organizer::Group::SubItem }
    let!(:error_class) { Organizer::Group::SubItemException }

    it_should_behave_like(:attributes_handler)
  end

  describe "collection mixin" do
    let!(:collection) { Organizer::Group::SubItem.new }
    let!(:collection_exception_class) { Organizer::Group::SubItemException }

    let!(:item) do
      source_item = Organizer::Source::Item.new
      source_item.instance_variable_set(:@name, :item_name)
      source_item
    end

    it_should_behave_like(:collection)
  end

  describe "collection item mixin" do
    let!(:item) do
      sub_item = Organizer::Group::SubItem.new
      sub_item.instance_variable_set(:@name, :item_name)
      sub_item
    end

    it_should_behave_like(:collection_item)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Group::SubItem.new }
    it_should_behave_like(:explainer)
  end
end
