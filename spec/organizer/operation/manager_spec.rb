require 'spec_helper'

describe Organizer::Operation::Manager do
  describe "#add_operation" do
    it "adds new operation" do
      expect { subject.add_operation(:result_attr) {} }.to change {
        subject.send(:operations).count }.from(0).to(1)
    end

    it "returns a new operation" do
      operation = subject.add_operation(:result_attr) {}
      expect(operation).to be_a(Organizer::Operation::SourceItem)
    end
  end

  describe "#add_group_operation" do
    it "adds new group operation" do
      expect { subject.add_group_operation(:result_attr, :my_group) {} }.to change {
        subject.send(:group_operations).count }.from(0).to(1)
    end

    it "returns a new group operation" do
      operation = subject.add_group_operation(:result_attr, :my_group) {}
      expect(operation).to be_a(Organizer::Operation::GroupCollection)
    end
  end

  describe "#execute" do
    context "working with normal collections" do
      let_collection(:collection)
      before { subject.add_operation(:result_attr) { |item| item.age * 2 } }

      it "returns the whole collection" do
        result = subject.execute_over_source_items(collection)
        expect(result.size).to eq(9)
        expect(result).to be_a(Organizer::Source::Collection)
      end

      it "returns collection items with new attribute" do
        expect(subject.execute_over_source_items(collection).first.result_attr).to eq(44)
      end

      context "with nested operations" do
        before do
          subject.add_operation(:newer_result_attr) { |item| item.result_attr * 2 }
          subject.add_operation(:newest_result_attr) { |item| item.newer_result_attr * 2 }
          subject.add_operation(:the_newest_result_attr) { |item| item.newest_result_attr * 2 }
        end

        it "returns collection items with new attribute" do
          result = subject.execute_over_source_items(collection).first
          expect(result.newer_result_attr).to eq(88)
          expect(result.newest_result_attr).to eq(176)
          expect(result.the_newest_result_attr).to eq(352)
        end

        context "with invalid item attribute" do
          before { subject.add_operation(:another_attr) { |item| item.invalid_attr * 2 } }
          before { subject.add_operation(:some_attr) { |item| item.some_invalid_attr * 2 } }

          it "raise exception" do
            expect { subject.execute_over_source_items(collection) }.to(
              raise_error(Organizer::Operation::ManagerException))
          end
        end
      end
    end

    context "working with groups" do
      let_group_collection(:gender, :gender)
      before do
        subject.add_group_operation(:age_sum) do |age_sum, item|
          age_sum += item.age
        end
      end

      it "returns a group" do
        result = subject.execute_over_group_items(gender_group_collection, gender)
        expect(result.size).to eq(2)
        expect(result).to be_a(Organizer::Group::Collection)
      end

      it "returns group items with new attribute" do
        result = subject.execute_over_group_items(gender_group_collection, gender)
        expect(result.first.age_sum).to eq(192)
        expect(result.last.age_sum).to eq(130)
      end
    end
  end
end
