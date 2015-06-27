require 'spec_helper'

describe Organizer::GroupItem do
  it_should_behave_like(:attributes_handler, Organizer::GroupItem, Organizer::GroupItemException)

  describe "#initialize" do
    let_collection(:collection)
    before { @group_item = Organizer::GroupItem.new(collection) }

    it "copies attributes from first collection item" do
      item = collection.first
      item.attribute_names.each do |attribute, value|
        expect(@group_item.send(attribute)).to eq(item.send(attribute))
      end
    end
  end
end
