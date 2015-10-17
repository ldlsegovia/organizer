require 'spec_helper'

describe Organizer::Sort::Applier do
  subject { Organizer::Sort::Applier }

  describe "#apply_on_source" do
    before { @sort_items = Organizer::Sort::Collection.new }

    context "working with a simple collection" do
      let_collection(:collection)

      context "with ascendant sort item" do
        before { @sort_items.add_item(:gender) }

        it "sorts collection" do
          result = subject.apply_on_source(@sort_items, collection)
          expect(result.first.first_name).to eq("Virginia")
          expect(result.last.first_name).to eq("Javier")
        end
      end

      context "with descendant sort item" do
        before { @sort_items.add_item(:gender, true) }

        it "sorts collection" do
          result = subject.apply_on_source(@sort_items, collection)
          expect(result.first.first_name).to eq("Juan Manuel")
          expect(result.last.first_name).to eq("Virginia")
        end

        context "with multiple sort items" do
          before { @sort_items.add_item(:age, true) }

          it "sorts collection" do
            result = subject.apply_on_source(@sort_items, collection)
            expect(result.first.first_name).to eq("Rodolfo")
            expect(result.last.first_name).to eq("Virginia")
          end
        end
      end
    end
  end
end
