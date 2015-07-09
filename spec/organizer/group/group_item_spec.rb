require 'spec_helper'

describe Organizer::Group::SubItem do
  it_should_behave_like(:attributes_handler, Organizer::Group::SubItem, Organizer::Group::SubItemException)

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
end
