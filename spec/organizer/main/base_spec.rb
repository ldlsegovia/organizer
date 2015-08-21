require 'spec_helper'

describe Organizer::Base do
  let_collection(:collection)

  before do
    Object.send(:remove_const, :BaseChild) rescue nil
    class BaseChild < Organizer::Base; end
  end

  describe "#organize" do
    context "without defined collection" do
      it "raises error with undefined collection" do
        expect { BaseChild.new.organize }.to(
          raise_organizer_error(Organizer::Exception, :undefined_collection_method))
      end
    end

    context "with defined collection" do
      before { BaseChild.add_collection { raw_collection } }

      it "returns defined collection" do
        result = BaseChild.new.organize
        expect(result).to be_a(Organizer::Source::Collection)
        expect(result.size).to eq(9)
      end

      context "with default filters" do
        before do
          BaseChild.add_default_filter { |item| item.age > 9 }
          BaseChild.add_default_filter(:my_filter) { |item| item.age < 33 }
        end

        it "returns filtered collection" do
          result = BaseChild.new.organize
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.size).to eq(3)
        end

        it "skips default filter passing filter to skip_default_filter option" do
          result = BaseChild.new.organize({ skip_default_filters: [:my_filter] })
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.size).to eq(8)
        end
      end

      context "with normal filters" do
        before do
          BaseChild.add_filter(:filter1) { |item| item.age > 9 }
          BaseChild.add_filter(:filter2) { |item| item.age < 33 }
        end

        it "applies filters" do
          result = BaseChild.new.organize(enabled_filters: [:filter1, :filter2])
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.size).to eq(3)
        end
      end

      context "with filters with values" do
        before do
          BaseChild.add_filter_with_value(:filter1) { |item, value| item.age > value }
          BaseChild.add_filter_with_value(:filter2) { |item, value| item.age < value }
        end

        it "applies filters" do
          result = BaseChild.new.organize(filters: { filter1: 9, filter2: 33 })
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.size).to eq(3)
        end
      end

      context "with autogenerated filters" do
        it "applies filters" do
          result = BaseChild.new.organize(filters: { age_eq: 8 })
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.first.first_name).to eq("Francisco")
          result = BaseChild.new.organize(filters: { first_name_contains: "Manu" })
          expect(result.first.first_name).to eq("Juan Manuel")
        end
      end

      context "with operations" do
        before { BaseChild.add_operation(:new_attr) { |item| item.age * 2 } }

        it "executes operations" do
          result = BaseChild.new.organize
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.first.new_attr).to eq(44)
          expect(result.second.new_attr).to eq(62)
          expect(result.third.new_attr).to eq(128)
        end
      end

      context "with groups" do
        before { BaseChild.add_group(:site_id) }

        it "groups collection items" do
          result = BaseChild.new.organize(group_by: :site_id)
          expect(result).to be_a(Organizer::Group::Collection)
          expect(result.size).to eq(3)
        end

        context "with operations" do
          before do
            BaseChild.add_group_operation(:attrs_sum, 10) do |memo, item|
              memo.attrs_sum + item.age
            end
          end

          it "groups collection items" do
            result = BaseChild.new.organize(group_by: :site_id)
            result.each do |group_item|
              expected_sum = group_item.inject(10){ |memo, source_item| memo += source_item.age }
              expect(group_item.attrs_sum).to eq(expected_sum)
            end
          end
        end

        context "with nested groups" do
          before { BaseChild.add_group(:gender) }

          it "groups collection by gender and site" do
            result = BaseChild.new.organize(group_by: [:gender, :site_id])
            expect(result).to be_a(Organizer::Group::Collection)
            expect(result.size).to eq(2)
            expect(result.first).to be_a(Organizer::Group::Item)
            expect(result.first.size).to eq(3)
            expect(result.first.first).to be_a(Organizer::Group::Item)
            expect(result.first.first.size).to eq(2)
            expect(result.first.first.first).to be_a(Organizer::Source::Item)
          end

          context "with operations" do
            before do
              BaseChild.add_group_operation(:greater_age) do |memo, item|
                memo.greater_age > item.age ? memo.greater_age : item.age
              end
            end

            it "applies operations to full group hierarchy" do
              result = BaseChild.new.organize(group_by: [:gender, :site_id])
              expect(result.first.greater_age).to eq(65)
              expect(result.first.first.greater_age).to eq(31)
              expect(result.second.greater_age).to eq(64)
              expect(result.second.first.greater_age).to eq(64)
            end
          end
        end
      end
    end
  end
end
