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
      expect { Organizer::Operation::Item.new(-> {}, nil) }.to(
        raise_organizer_error(Organizer::Operation::ItemException, :blank_name))
    end

    it "sets mask operation" do
      mask_options = { name: :truncated, options: 5 }
      o = Organizer::Operation::Item.new(-> {}, :my_operation, mask: mask_options)
      expect(o.mask).to be_a(Organizer::Operation::Item)
      expect(o.mask.item_name).to eq(:human_my_operation)
    end

    it "sets initial value" do
      o = Organizer::Operation::Item.new(-> {}, :my_operation, initial_value: 10)
      expect(o.initial_value).to eq(10)
    end
  end

  describe "#execute" do
    let_item(:item)

    context "without params on definition" do
      before { @proc = Proc.new { |item| item.int_attr1 + item.int_attr2 } }

      it "sets operation result as new attribute into item param" do
        Organizer::Operation::Item.new(@proc, :attrs_sum).execute(item)
        expect(item.attrs_sum).to eq(item.int_attr1 + item.int_attr2)
      end

      it "execute mask when defined" do
        mask_options = { name: :currency, options: { separator: "-" } }
        Organizer::Operation::Item.new(@proc, :attrs_sum, mask: mask_options).execute(item)
        expect(item.human_attrs_sum).to eq("$666-00")
      end
    end

    context "with params on definition" do
      before do
        @proc = Proc.new do |item, param1, param2, param3|
          item.int_attr1 + param1 + param2 + param3
        end
      end

      it "uses parent attribute to keep old results" do
        Organizer::Operation::Item.new(@proc, :attrs_sum, initial_value: 0).execute(item, [4, 6, 84])
        expect(item.attrs_sum).to eq(item.int_attr1 + 4 + 6 + 84)
      end
    end
  end

  describe "collection item mixin" do
    let!(:item) { Organizer::Operation::Item.new(-> {}, :item_name) }
    it_should_behave_like(:collection_item)
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Operation::Item.new(-> {}, :my_operation) }
    it_should_behave_like(:explainer)
  end
end
