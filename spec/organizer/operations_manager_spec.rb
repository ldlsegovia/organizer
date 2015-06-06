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
    before { subject.add_operation(:result_attr) { |item| item.attr1 * 2 } }

    it "returns the whole collection" do
      expect(subject.execute(organizer_collection).size).to eq(3)
    end

    it "returns collection items with new attribute" do
      expect(subject.execute(organizer_collection).second.result_attr).to eq(12)
    end

    context "with nested operations" do
      before do
        subject.add_operation(:newer_result_attr) { |item| item.result_attr * 2 }
        subject.add_operation(:newest_result_attr) { |item| item.newer_result_attr * 2 }
        subject.add_operation(:the_newest_result_attr) { |item| item.newest_result_attr * 2 }
      end

      it "returns collection items with new attribute" do
        expect(subject.execute(organizer_collection).second.newer_result_attr).to eq(24)
        expect(subject.execute(organizer_collection).second.newest_result_attr).to eq(48)
        expect(subject.execute(organizer_collection).second.the_newest_result_attr).to eq(96)
      end

      context "with invalid item attribute", focus: true do
        before { subject.add_operation(:another_attr) { |item| item.invalid_attr * 2 } }

        it "raise exception" do
          expect { subject.execute(organizer_collection) }.to(
            raise_organizer_error(Organizer::OperationsManagerException, :failed_operation_execution))
        end
      end
    end
  end
end
