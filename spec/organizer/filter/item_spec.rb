require 'spec_helper'

describe Organizer::Filter::Item do
  describe "#initialize" do
    it "creates filter with definition" do
      proc = Proc.new {}
      f = Organizer::Filter::Item.new(proc)
      expect(f.definition).to eq(proc)
    end

    it "creates filter with name" do
      expect(Organizer::Filter::Item.new(-> {}, :filter_name).item_name).to eq(:filter_name)
    end

    it "ensures name, value and definition read only" do
      f = Organizer::Filter::Item.new(-> {})
      expect { f.definition = "definition" }.to raise_error
      expect { f.item_name = "name" }.to raise_error
    end

    it "raise exception if _definition is not a Proc" do
      expect { Organizer::Filter::Item.new("not a proc") }.to(
        raise_organizer_error(Organizer::Filter::ItemException, :definition_must_be_a_proc))
    end
  end

  describe "#apply" do
    let_item(:item)

    it "raise exception if _item is not an Organizer::Source::Item" do
      expect { Organizer::Filter::Item.new(-> {}).apply("not an item") }.to(
        raise_organizer_error(Organizer::Filter::ItemException, :apply_on_collection_items_only))
    end

    it "raise exception if filter's definition does not return a boolean value" do
      expect { Organizer::Filter::Item.new(Proc.new { "not a boolean" }).apply(item) }.to(
        raise_organizer_error(Organizer::Filter::ItemException, :definition_must_return_boolean))
    end

    it "returns false when definiton block call resolves false" do
      expect(Organizer::Filter::Item.new(Proc.new { 1 == 2 }).apply(item)).to be_falsy
    end

    it "returns true when definiton block call resolves true" do
      expect(Organizer::Filter::Item.new(Proc.new { true }).apply(item)).to be_truthy
    end

    it "uses Organizer::Source::Item instance on definition call" do
      proc = Proc.new do |organizer_item|
        (organizer_item.int_attr1 + organizer_item.int_attr2) == 666
      end

      expect(Organizer::Filter::Item.new(proc).apply(item)).to be_truthy
    end

    it "uses filter value attr on definition call" do
      proc = Proc.new do |organizer_item, value|
        (organizer_item.int_attr1 + organizer_item.int_attr2) == value
      end

      filter = Organizer::Filter::Item.new(proc, :my_filter)
      filter.value = 666
      expect(filter.apply(item)).to be_truthy
    end
  end

  describe "collection item mixin" do
    let!(:item) { Organizer::Filter::Item.new(-> {}, :item_name) }
    it_should_behave_like(:collection_item)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Filter::Item.new(-> {}, :item_name) }
    it_should_behave_like(:explainer)
  end
end
