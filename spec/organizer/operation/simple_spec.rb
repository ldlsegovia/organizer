require 'spec_helper'

describe Organizer::Operation::Simple do
  describe "#execute" do
    it "sets operation result as new attribute into item param" do
      hash = { attr1: 400, attr2: 266 }
      item = Organizer::Source::Item.new
      item.define_attributes(hash)
      proc = Proc.new { |organizer_item| organizer_item.attr1 + organizer_item.attr2 }
      Organizer::Operation::Simple.new(proc, :attrs_sum).execute(item)
      expect(item.attrs_sum).to eq(hash[:attr1] + hash[:attr2])
    end
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Operation::Simple.new(->{}, :my_operation) }
    it_should_behave_like(:explainer)
  end
end
