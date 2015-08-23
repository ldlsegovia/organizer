require 'spec_helper'

describe Organizer::Group::Item do
  describe "#initialize" do
    it "creates a group with name only" do
      group = Organizer::Group::Item.new(:store_id)
      expect(group.item_name).to eq(:store_id)
      expect(group.group_by_attr).to eq(:store_id)
    end

    it "creates a group with name and group_by_attr" do
      group = Organizer::Group::Item.new(:store, :store_id)
      expect(group.item_name).to eq(:store)
      expect(group.group_by_attr).to eq(:store_id)
      expect(group.parent_name).to be_nil
    end

    it "ensures name and group_by_attr read only" do
      group = Organizer::Group::Item.new(:store_id)
      expect { group.item_name = "name" }.to raise_error
      expect { group.group_by_attr = "group_by_attr" }.to raise_error
    end

    it "creates group with parent" do
      group = Organizer::Group::Item.new(:store, :store_id, :site)
      expect(group.parent_name).to eq(:site)
      expect(group.has_parent?).to be_truthy
    end
  end

  it "raises error trying to add non group item to group" do
    group = Organizer::Group::Item.new(:store_id)
    expect { group << "not a group item" }.to(
      raise_organizer_error(Organizer::Group::ItemException, :invalid_item))
  end

  describe "attributes handler mixin" do
    let!(:instance) { Organizer::Group::Item.new(:store_id) }
    let!(:error_class) { Organizer::Group::ItemException }

    it_should_behave_like(:attributes_handler)
  end

  describe "collection mixin" do
    let!(:collection) { Organizer::Group::Item.new(:store_id) }
    let!(:collection_exception_class) { Organizer::Group::ItemException }

    let!(:item) do
      group_item = Organizer::Group::Item.new(:store_id)
      group_item.instance_variable_set(:@item_name, :item_name)
      group_item
    end

    it_should_behave_like(:collection)
  end

  describe "collection item mixin" do
    let!(:item) { Organizer::Group::Item.new(:item_name) }
    it_should_behave_like(:collection_item)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Group::Item.new(:item_name) }
    it_should_behave_like(:explainer)
  end
end
