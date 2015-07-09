require 'spec_helper'

describe Organizer::FiltersCollection do
  describe "#<<" do
    it "raises error trying to add non organizer filters to collection" do
      expect { subject << "not an organizer filter" }.to(
        raise_organizer_error(Organizer::FiltersCollectionException, :invalid_item))
    end

    it "adds Organizer::Filter to collection" do
      subject << Organizer::Filter.new(Proc.new {})
      expect(subject.size).to eq(1)
      expect(subject.first).to be_a(Organizer::Filter)
    end

    it "raises error with repeated name for filter" do
      skip
    end
  end

  describe "#filter_by_name" do
    before do
      subject << Organizer::Filter.new(Proc.new {}, :filter1)
      subject << Organizer::Filter.new(Proc.new {}, :filter2)
    end

    it "returns existent filter" do
      [:filter1, "filter2"].each do |filter_name|
        expect(subject.filter_by_name(filter_name).name).to eq(filter_name.to_sym)
      end
    end

    it "returns nil with inexistent filter" do
      expect(subject.filter_by_name(:invalid_name)).to be_nil
    end
  end

  describe "#select_filters" do
    context "with non existent filters collection" do
      it "returns selected filters" do
        result = subject.select_filters([])
        expect(result.size).to eq(0)
      end
    end

    context "with existent filters collection" do
      before do
        subject << Organizer::Filter.new(Proc.new {}, :filter1)
        subject << Organizer::Filter.new(Proc.new {}, :filter2)
      end

      it "returns selected filters" do
        result = subject.select_filters([:filter1, :invalid_filter])
        expect(result).to be_a(Organizer::FiltersCollection)
        expect(result.size).to eq(1)
        expect(result.first.name).to eq(:filter1)
      end

      it "returns empty filters collection with invalid filter names" do
        ["", [], nil, "bla", 1].each do |names|
          result = subject.select_filters(names)
          expect(result).to be_a(Organizer::FiltersCollection)
          expect(result.size).to eq(0)
        end
      end
    end
  end

  describe "#reject_filters" do
    before do
      subject << Organizer::Filter.new(Proc.new {}, :filter1)
      subject << Organizer::Filter.new(Proc.new {}, :filter2)
    end

    it "returns non rejected filters" do
      result = subject.reject_filters([:filter1, :invalid_filter])
      expect(result.size).to eq(1)
      expect(result.first.name).to eq(:filter2)
    end

    it "returns all filters collection with invalid filter names" do
      ["", [], nil, "bla", 1].each do |names|
        result = subject.reject_filters(names)
        expect(result).to be_a(Organizer::FiltersCollection)
        expect(result.size).to eq(2)
      end
    end
  end
end
