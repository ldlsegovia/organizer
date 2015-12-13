require 'spec_helper'

describe Organizer::Operation::Simple do
  describe "#execute" do
    let_item(:item)

    before { @proc = Proc.new { |item| item.int_attr1 + item.int_attr2 } }

    it "sets operation result as new attribute into item param" do
      Organizer::Operation::Simple.new(@proc, :attrs_sum).execute(item)
      expect(item.attrs_sum).to eq(item.int_attr1 + item.int_attr2)
    end

    it "execute mask when defined" do
      mask_options = { name: :currency, options: { separator: "-" } }
      Organizer::Operation::Simple.new(@proc, :attrs_sum, mask: mask_options).execute(item)
      expect(item.human_attrs_sum).to eq("$666-00")
    end
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Operation::Simple.new(-> {}, :my_operation) }
    it_should_behave_like(:explainer)
  end
end
