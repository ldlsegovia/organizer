require 'spec_helper'

describe Organizer::Sort::Item do
  describe "#initialize" do
    it "creates sort item" do
      item = Organizer::Sort::Item.new(:item_name, "some true value")
      expect(item.item_name).to eq(:item_name)
      expect(item.descendant).to be_truthy
    end

    it "creates changes item descendant to false" do
      expect(Organizer::Sort::Item.new(:item_name, nil).descendant).to be_falsy
    end

    it "ensures read only for name and descendant attrs" do
      item = Organizer::Sort::Item.new(:item_name)
      expect { item.descendant = false }.to raise_error
      expect { item.item_name = "name" }.to raise_error
    end

    it "raise exception if _name is not defined" do
      expect { Organizer::Sort::Item.new(nil) }.to(
        raise_organizer_error(Organizer::Sort::ItemException, :blank_name))
    end
  end

  describe "collection item mixin" do
    let!(:item) { Organizer::Sort::Item.new(:item_name) }
    it_should_behave_like(:collection_item)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Sort::Item.new(:item_name) }
    it_should_behave_like(:explainer)
  end
end
