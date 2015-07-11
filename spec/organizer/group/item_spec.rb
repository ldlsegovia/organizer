require 'spec_helper'

describe Organizer::Group::Item do
  describe "#initialize" do
    it "creates a group with name only" do
      group = Organizer::Group::Item.new(:store_id)
      expect(group.name).to eq(:store_id)
      expect(group.group_by_attr).to eq(:store_id)
    end

    it "creates a group with name and group_by_attr" do
      group = Organizer::Group::Item.new(:store, :store_id)
      expect(group.name).to eq(:store)
      expect(group.group_by_attr).to eq(:store_id)
    end

    it "ensures name and group_by_attr read only" do
      group = Organizer::Group::Item.new(:store_id)
      expect { group.name = "name" }.to raise_error
      expect { group.group_by_attr = "group_by_attr" }.to raise_error
    end
  end

  it "raises error trying to add non group item to group" do
    group = Organizer::Group::Item.new(:store_id)
    expect { group << "not a group item" }.to(
      raise_organizer_error(Organizer::Group::ItemException, :invalid_item))
  end

  describe "#build" do
    let_collection(:collection)
    before { @group = Organizer::Group::Item.new(:store_id) }

    it "raises error if collection items have not group_by_attr" do
      group = Organizer::Group::Item.new(:undefined_attr)
      expect { group.build(collection) }.to(
        raise_organizer_error(Organizer::Group::ItemException, :group_by_attr_not_present_in_collection))
    end

    it "returns same group with empty collection" do
      expect(@group.build(Organizer::Source::Collection.new)).to be(@group)
    end

    context "with a built a group" do
      before { @group.build(collection) }

      it "returns same group with valid collection" do
        expect(@group).to be(@group)
      end

      it "contains group items" do
        expect(@group.size).to eq(5)
        0.upto(4).each { |i| expect(@group[i]).to be_a(Organizer::Group::SubItem) }
      end

      it "contains items inside group items" do
        one = @group.first
        two = @group.last
        expect(one.size).to eq(2)
        expect(two.size).to eq(1)
        expect(one.first).to be_a(Organizer::Source::Item)
        expect(one.last).to be_a(Organizer::Source::Item)
        expect(two.first).to be_a(Organizer::Source::Item)
        one.first.attribute_names.each { |attribute, value| expect(one).to respond_to(attribute) }
        two.first.attribute_names.each { |attribute, value| expect(two).to respond_to(attribute) }
      end
    end
  end

  describe "collection mixin" do
    let!(:collection) { Organizer::Group::Item.new(:store_id) }
    let!(:collection_exception_class) { Organizer::Group::ItemException }

    let!(:item) do
      group_sub_item = Organizer::Group::SubItem.new(Organizer::Source::Collection.new)
      group_sub_item.instance_variable_set(:@name, :item_name)
      group_sub_item
    end

    it_should_behave_like(:collection)
  end

  describe "collection item mixin" do
    let!(:item) { Organizer::Group::Item.new(:item_name) }

    it_should_behave_like(:collection_item)
  end
end
