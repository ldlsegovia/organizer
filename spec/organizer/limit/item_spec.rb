require 'spec_helper'

describe Organizer::Limit::Item do
  describe "#initialize" do
    it "creates limit item" do
      item = Organizer::Limit::Item.new(:item_name, 10)
      expect(item.item_name).to eq(:item_name)
      expect(item.value).to eq(10)
    end

    it "raise exception if _name is not defined" do
      expect { Organizer::Limit::Item.new(nil, 10) }.to(
        raise_organizer_error(Organizer::Limit::ItemException, :blank_name))
    end

    it "raise exception if _value is not a positive integer" do
      [nil, "-1", -1, "not an integer", "", 4.684].each do |value|
        expect { Organizer::Limit::Item.new(:item_name, value) }.to(
          raise_organizer_error(Organizer::Limit::ItemException, :not_integer_value))
      end
    end
  end

  describe "collection item mixin" do
    let!(:item) { Organizer::Limit::Item.new(:item_name, 10) }
    it_should_behave_like(:collection_item)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Limit::Item.new(:item_name, 10) }
    it_should_behave_like(:explainer)
  end
end
