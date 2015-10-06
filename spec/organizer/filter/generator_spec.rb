require 'spec_helper'

describe Organizer::Filter::Generator do
  let_collection(:collection)

  def apply_filter(_key, _value)
    Organizer::Filter::Applier.apply(@filters, collection, selected_filters: { _key => _value })
  end

  describe "#generate" do
    subject { Organizer::Filter::Generator }
    let_collection(:collection)
    let(:item) { collection.first }
    before { @filters = subject.generate(item) }

    it "raise exception if _item is not an Organizer::Source::Item" do
      expect { subject.generate("not an item") }.to(
        raise_organizer_error(Organizer::Filter::GeneratorException, :generate_over_organizer_items_only))
    end

    it "has generated filters" do
      item.attribute_names.each do |attribute|
        [:eq, :not_eq, :gt, :lt, :goet, :loet, :starts, :ends, :contains].each do |sufix|
          filter_name = "#{attribute}_#{sufix}"
          expect(@filters.find_by_name(filter_name).item_name).to eq(filter_name)
        end
      end
    end

    it { expect(apply_filter(:age_eq, 8).size).to eq(1) }
    it { expect(apply_filter(:age_not_eq, 31).size).to eq(7) }
    it { expect(apply_filter(:age_gt, 31).size).to eq(5) }
    it { expect(apply_filter(:age_lt, 31).size).to eq(2) }
    it { expect(apply_filter(:age_goet, 31).size).to eq(7) }
    it { expect(apply_filter(:age_loet, 31).size).to eq(4) }
    it { expect(apply_filter(:first_name_starts, "Lean").size).to eq(1) }
    it { expect(apply_filter(:first_name_ends, "Manuel").size).to eq(1) }
    it { expect(apply_filter(:first_name_contains, "ana").size).to eq(1) }
  end
end
