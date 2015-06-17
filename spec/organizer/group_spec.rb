require 'spec_helper'

describe Organizer::Group do
  describe "#initialize" do
    it "creates a group with name only" do
      group = Organizer::Group.new(:store_id)
      expect(group.name).to eq(:store_id)
      expect(group.group_by_attr).to eq(:store_id)
    end

    it "creates a group with name and group_by_attr" do
      group = Organizer::Group.new(:store, :store_id)
      expect(group.name).to eq(:store)
      expect(group.group_by_attr).to eq(:store_id)
    end

    it "ensures name and group_by_attr read only" do
      group = Organizer::Group.new(:store_id)
      expect { group.name = "name" }.to raise_error
      expect { group.group_by_attr = "group_by_attr" }.to raise_error
    end
  end

  it "raises error trying to add non group item to group" do
    group = Organizer::Group.new(:store_id)
    expect { group << "not a group item" }.to(
      raise_organizer_error(Organizer::GroupException, :invalid_item))
  end

  describe "#build" do
    let_organizer_collection(:organizer_collection)
    before { @group = Organizer::Group.new(:store_id) }

    it "raises error if collection items have not group_by_attr" do
      group = Organizer::Group.new(:undefined_attr)
      expect { group.build(organizer_collection) }.to(
        raise_organizer_error(Organizer::GroupException, :group_by_attr_not_present_in_collection))
    end

    it "returns same group with empty collection" do
      expect(@group.build(Organizer::Collection.new)).to be(@group)
    end

    context "with a built a group" do
      before { @group.build(organizer_collection) }

      it "returns same group with valid collection" do
        expect(@group).to be(@group)
      end

      it "contains group items" do
        expect(@group.size).to eq(2)
        expect(@group.first).to be_a(Organizer::GroupItem)
        expect(@group.last).to be_a(Organizer::GroupItem)
      end

      it "contains items inside group items" do
        one = @group.first
        two = @group.last
        expect(one.size).to eq(2)
        expect(two.size).to eq(1)
        expect(one.first).to be_a(Organizer::Item)
        expect(one.last).to be_a(Organizer::Item)
        expect(two.first).to be_a(Organizer::Item)
      end
    end
  end
end
