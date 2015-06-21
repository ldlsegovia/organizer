require 'spec_helper'

describe Organizer::OperationsManager do
  let_collection(:collection)

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
    before { subject.add_operation(:result_attr) { |item| item.age * 2 } }

    it "returns the whole collection" do
      expect(subject.execute(collection).size).to eq(9)
    end

    it "returns collection items with new attribute" do
      expect(subject.execute(collection).first.result_attr).to eq(44)
    end

    context "with nested operations" do
      before do
        subject.add_operation(:newer_result_attr) { |item| item.result_attr * 2 }
        subject.add_operation(:newest_result_attr) { |item| item.newer_result_attr * 2 }
        subject.add_operation(:the_newest_result_attr) { |item| item.newest_result_attr * 2 }
      end

      it "returns collection items with new attribute" do
        expect(subject.execute(collection).first.newer_result_attr).to eq(88)
        expect(subject.execute(collection).first.newest_result_attr).to eq(176)
        expect(subject.execute(collection).first.the_newest_result_attr).to eq(352)
      end

      context "with invalid item attribute" do
        before { subject.add_operation(:another_attr) { |item| item.invalid_attr * 2 } }
        before { subject.add_operation(:some_attr) { |item| item.some_invalid_attr * 2 } }

        it "raise exception" do
          expect { subject.execute(collection) }.to(
            raise_error(Organizer::OperationsManagerException))
        end
      end
    end
  end
end
