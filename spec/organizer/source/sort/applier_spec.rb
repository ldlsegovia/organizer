require 'spec_helper'

describe Organizer::Source::Sort::Applier do
  subject { Organizer::Source::Sort::Applier }
  let_collection(:collection)
  before { @sort_items = Organizer::Sort::Collection.new }

  describe "#apply" do
    context "with ascendant sort item" do
      before { @sort_items.add_item(:gender) }

      it "sorts collection" do
        result = subject.apply(@sort_items, collection)
        expect(result.first.first_name).to eq("Virginia")
        expect(result.last.first_name).to eq("Javier")
      end
    end

    context "with descendding sort item" do
      before { @sort_items.add_item(:gender, true) }

      it "sorts collection" do
        result = subject.apply(@sort_items, collection)
        expect(result.first.first_name).to eq("Juan Manuel")
        expect(result.last.first_name).to eq("Virginia")
      end

      context "with multiple sort items" do
        before { @sort_items.add_item(:age, true) }

        it "sorts collection" do
          result = subject.apply(@sort_items, collection)
          expect(result.first.first_name).to eq("Rodolfo")
          expect(result.last.first_name).to eq("Virginia")
        end
      end
    end
  end
end
