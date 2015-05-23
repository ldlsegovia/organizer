require 'spec_helper'

describe Organizer::Filter do

  describe "#initialize" do

    it "creates filter with definition" do
      proc = Proc.new {}
      f = Organizer::Filter.new(proc)
      expect(f.definition).to eq(proc)
      expect(f.name).to be_nil
    end

    it "creates filter with name and definition" do
      proc = Proc.new {}
      f = Organizer::Filter.new(proc, :filter_name)
      expect(f.definition).to eq(proc)
      expect(f.name).to eq(:filter_name)
    end

    it "ensures name and definition read only" do
      proc = Proc.new {}
      f = Organizer::Filter.new(proc, :filter_name)
      expect { f.definition = "some" }.to raise_error
      expect { f.name = "value" }.to raise_error
    end

    it "raise exception if _definition is not a Proc" do
      expect { Organizer::Filter.new("not a proc") }.to(
        raise_organizer_error(:filter_definition_must_be_a_proc))
    end

  end

  describe "#apply" do

    it "raise exception if _item is not an Organizer::Item" do
      proc = Proc.new {}
      expect { Organizer::Filter.new(proc).apply("not an item") }.to(
        raise_organizer_error(:filter_applied_on_organizer_items_only))
    end

    it "raise exception if filter's definition does not return a boolean value" do
      proc = Proc.new { "not a boolean" }
      expect { Organizer::Filter.new(proc).apply(Organizer::Item.new) }.to(
        raise_organizer_error(:filter_definition_must_return_boolean))
    end

    it "returns false when definiton block call resolves false" do
      proc = Proc.new { 1 == 2 }
      expect(Organizer::Filter.new(proc).apply(Organizer::Item.new)).to be_falsy
    end

    it "returns true when definiton block call resolves true" do
      proc = Proc.new { 1 == 1 }
      expect(Organizer::Filter.new(proc).apply(Organizer::Item.new)).to be_truthy
    end

    it "uses Organizer::Item instance on definition block" do
      hash = { attr1: 400, attr2: 266 }
      item = Organizer::Item.new
      item.define_attributes(hash)

      proc1 = Proc.new do |organizer_item|
        result = organizer_item.attr1 + organizer_item.attr2
        result == 666
      end

      expect(Organizer::Filter.new(proc1).apply(item)).to be_truthy

      proc2 = Proc.new do |organizer_item|
        result = organizer_item.attr1 + organizer_item.attr2
        result == "the mark of the beast?"
      end

      expect(Organizer::Filter.new(proc2).apply(item)).to be_falsy
    end

    it "sets filter name" do
      proc = Proc.new {}
      filter = Organizer::Filter.new(proc, :filter_name)
      expect(filter.name).to eq(:filter_name)
    end

  end

end
