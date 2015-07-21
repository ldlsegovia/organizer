require 'spec_helper'

describe Organizer::Operation::Item do
  describe "#initialize" do
    it "creates a new Operation instance" do
      proc = Proc.new {}
      o = Organizer::Operation::Item.new(proc, :my_operation)
      expect(o.definition).to eq(proc)
      expect(o.item_name).to eq(:my_operation)
    end

    it "raise exception if _definition is not a Proc" do
      expect { Organizer::Operation::Item.new("not a proc", :my_operation) }.to(
        raise_organizer_error(Organizer::Operation::ItemException, :definition_must_be_a_proc))
    end

    it "raise exception if _name is not defined" do
      expect { Organizer::Operation::Item.new(->{}, nil) }.to(
        raise_organizer_error(Organizer::Operation::ItemException, :blank_name))
    end
  end

  describe "#execute" do
    it "raise not implemented error" do
      expect { Organizer::Operation::Item.new(->{}, :my_operation).execute("item") }.to(
        raise_organizer_error(Organizer::Operation::ItemException, :not_implemented))
    end
  end

  describe "collection item mixin" do
    let!(:item) { Organizer::Operation::Item.new(->{}, :item_name) }
    it_should_behave_like(:collection_item)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Operation::Item.new(->{}, :my_operation) }
    it_should_behave_like(:explainer)
  end
end
