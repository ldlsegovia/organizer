require 'spec_helper'

describe Organizer::Operation::SourceItem do
  describe "#execute" do
    it "raise exception if _item is not an Organizer::Source::Item" do
      expect { Organizer::Operation::SourceItem.new(Proc.new {}, :my_operation).execute("not an item") }.to(
        raise_organizer_error(Organizer::Operation::SourceItemException, :execute_over_organizer_items_only))
    end

    it "sets operation result as new attribute into item param" do
      hash = { attr1: 400, attr2: 266 }
      item = Organizer::Source::Item.new
      item.define_attributes(hash)

      proc = Proc.new do |organizer_item|
        organizer_item.attr1 + organizer_item.attr2
      end

      item = Organizer::Operation::SourceItem.new(proc, :attrs_sum).execute(item)
      expect(item.attrs_sum).to eq(666)
    end
  end

  describe "explainer mixin" do
    let!(:explainer) { Organizer::Operation::SourceItem.new(Proc.new {}, :my_operation) }
    it_should_behave_like(:explainer)
  end
end
