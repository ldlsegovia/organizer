require 'spec_helper'

describe Organizer::Filter::SourceApplier do
  subject { Organizer::Filter::SourceApplier }
  let_collection(:collection)

  describe "#apply" do
    before { @filters = Organizer::Filter::Collection.new }

    it "applies filters passed as params" do
      @filters.add_filter(:filter1) { |item| item.age > 9 }
      @filters.add_filter(:filter2) { |item| item.age < 33 }
      expect(subject.apply(@filters, collection).size).to eq(3)
    end

    it "returns complete collection with no filters" do
      expect(subject.apply(@filters, collection).size).to eq(9)
    end
  end
end
