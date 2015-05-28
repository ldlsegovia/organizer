require 'spec_helper'

describe Organizer::OperationsManager do
  let_organizer_collection(:organizer_collection)

  describe "#add_operation" do
    it "adds new operation" do
      expect(subject.send(:operations).count).to eq(0)
      subject.add_operation(:result_attr) {}
      expect(subject.send(:operations).count).to eq(1)
      subject.add_operation(:another_attr) {}
      expect(subject.send(:operations).count).to eq(2)
    end

    it "raises error with repeated operation name" do
      skip
    end
  end

  describe "#execute" do
    before do
      subject.add_operation(:result_attr) { |item| item.attr1 * 2 }
      @result = subject.execute(organizer_collection)
    end

    it "returns the whole collection" do
      expect(@result.size).to eq(3)
    end

    it "returns collection items with new attribute" do
      expect(@result.second.result_attr).to eq(12)
    end
  end
end
