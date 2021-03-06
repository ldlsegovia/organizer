require 'spec_helper'

describe Organizer::Source::Item do
  describe "attributes handler mixin" do
    let!(:instance) { Organizer::Source::Item.new }
    let!(:error_class) { Organizer::Source::ItemException }

    it_should_behave_like(:attributes_handler)
  end

  describe "collection item mixin" do
    let!(:item) do
      source_item = Organizer::Source::Item.new
      source_item.instance_variable_set(:@item_name, :item_name)
      source_item
    end

    it_should_behave_like(:collection_item)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Source::Item.new }
    it_should_behave_like(:explainer)
  end
end
