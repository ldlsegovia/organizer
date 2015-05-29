require 'spec_helper'

describe Organizer::Filter do
  describe "#initialize" do
    it "creates filter with definition" do
      proc = Proc.new {}
      f = Organizer::Filter.new(proc)
      expect(f.definition).to eq(proc)
    end

    it "creates filter with name" do
      expect(Organizer::Filter.new(Proc.new {}, :filter_name).name).to eq(:filter_name)
    end

    it "creates filter with value" do
      expect(Organizer::Filter.new(Proc.new {}, nil, "any true value will work").accept_value).to be_truthy
    end

    it "ensures name, value and definition read only" do
      f = Organizer::Filter.new(Proc.new {})
      expect { f.definition = "definition" }.to raise_error
      expect { f.name = "name" }.to raise_error
      expect { f.value = "value" }.to raise_error
    end

    it "raise exception if _definition is not a Proc" do
      expect { Organizer::Filter.new("not a proc") }.to(
        raise_organizer_error(Organizer::FilterException, :definition_must_be_a_proc))
    end
  end

  describe "#apply" do
    let_item(:item)

    it "raise exception if _item is not an Organizer::Item" do
      expect { Organizer::Filter.new(Proc.new {}).apply("not an item") }.to(
        raise_organizer_error(Organizer::FilterException, :apply_on_organizer_items_only))
    end

    it "raise exception if filter's definition does not return a boolean value" do
      expect { Organizer::Filter.new(Proc.new { "not a boolean" }).apply(item) }.to(
        raise_organizer_error(Organizer::FilterException, :definition_must_return_boolean))
    end

    it "returns false when definiton block call resolves false" do
      expect(Organizer::Filter.new(Proc.new { 1 == 2 }).apply(item)).to be_falsy
    end

    it "returns true when definiton block call resolves true" do
      expect(Organizer::Filter.new(Proc.new { 1 == 1 }).apply(item)).to be_truthy
    end

    it "uses Organizer::Item instance on definition call" do
      proc = Proc.new do |organizer_item|
        (organizer_item.attr1 + organizer_item.attr2) == 666
      end

      expect(Organizer::Filter.new(proc).apply(item)).to be_truthy
    end

    it "uses filter value param on definition call" do
      proc = Proc.new do |organizer_item, value|
        (organizer_item.attr1 + organizer_item.attr2) == value
      end

      expect(Organizer::Filter.new(proc, :my_filter, true).apply(item, 666)).to be_truthy
    end
  end
end
