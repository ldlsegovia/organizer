require 'spec_helper'

describe Organizer::Source::Limit::Applier do
  subject { Organizer::Source::Limit::Applier }
  let_collection(:collection)

  describe "#apply" do
    context "with limit lower than collection count" do
      before { @limit_item = Organizer::Limit::Item.new(:item_name, 4) }

      it "limits collection" do
        result = subject.apply(@limit_item, collection)
        expect(result.count).to eq(4)
      end
    end

    context "with limit greater than collection count" do
      before { @limit_item = Organizer::Limit::Item.new(:item_name, 20) }

      it "returns complete collection" do
        result = subject.apply(@limit_item, collection)
        expect(result.count).to eq(9)
      end
    end

    it "returns complete collection with undefined limit" do
      result = subject.apply(nil, collection)
      expect(result.count).to eq(9)
    end
  end
end
