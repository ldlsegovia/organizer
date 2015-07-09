require 'spec_helper'

describe Organizer::Filter::Item do
  describe "#initialize" do
    it "creates filter with definition" do
      proc = Proc.new {}
      f = Organizer::Filter::Item.new(proc)
      expect(f.definition).to eq(proc)
    end

    it "creates filter with name" do
      expect(Organizer::Filter::Item.new(Proc.new {}, :filter_name).name).to eq(:filter_name)
    end

    it "creates filter with value" do
      expect(Organizer::Filter::Item.new(Proc.new {}, nil, "any true value will work").accept_value).to be_truthy
    end

    it "ensures name, value and definition read only" do
      f = Organizer::Filter::Item.new(Proc.new {})
      expect { f.definition = "definition" }.to raise_error
      expect { f.name = "name" }.to raise_error
      expect { f.value = "value" }.to raise_error
    end

    it "raise exception if _definition is not a Proc" do
      expect { Organizer::Filter::Item.new("not a proc") }.to(
        raise_organizer_error(Organizer::Filter::ItemException, :definition_must_be_a_proc))
    end
  end

  describe "#apply" do
    let_item(:item)

    it "raise exception if _item is not an Organizer::Item" do
      expect { Organizer::Filter::Item.new(Proc.new {}).apply("not an item") }.to(
        raise_organizer_error(Organizer::Filter::ItemException, :apply_on_organizer_items_only))
    end

    it "raise exception if filter's definition does not return a boolean value" do
      expect { Organizer::Filter::Item.new(Proc.new { "not a boolean" }).apply(item) }.to(
        raise_organizer_error(Organizer::Filter::ItemException, :definition_must_return_boolean))
    end

    it "returns false when definiton block call resolves false" do
      expect(Organizer::Filter::Item.new(Proc.new { 1 == 2 }).apply(item)).to be_falsy
    end

    it "returns true when definiton block call resolves true" do
      expect(Organizer::Filter::Item.new(Proc.new { 1 == 1 }).apply(item)).to be_truthy
    end

    it "uses Organizer::Item instance on definition call" do
      proc = Proc.new do |organizer_item|
        (organizer_item.int_attr1 + organizer_item.int_attr2) == 666
      end

      expect(Organizer::Filter::Item.new(proc).apply(item)).to be_truthy
    end

    it "uses filter value param on definition call" do
      proc = Proc.new do |organizer_item, value|
        (organizer_item.int_attr1 + organizer_item.int_attr2) == value
      end

      expect(Organizer::Filter::Item.new(proc, :my_filter, true).apply(item, 666)).to be_truthy
    end
  end

  describe "#has_name?" do
    it "returns true when filter has name param" do
      expect(Organizer::Filter::Item.new(Proc.new {}, :my_filter).has_name?("my_filter")).to be_truthy
    end

    it "returns false when filter has not name param" do
      expect(Organizer::Filter::Item.new(Proc.new {}, :my_filter).has_name?("invalid")).to be_falsy
    end
  end
end
