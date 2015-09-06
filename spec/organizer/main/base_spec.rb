require 'spec_helper'

describe Organizer::Base do
  let_collection(:collection)

  before do
    Object.send(:remove_const, :BaseChild) rescue nil
    class BaseChild < Organizer::Base; end
    @organizer = BaseChild.new
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
          result = BaseChild.new.organize(filters: [:filter1, :filter2])
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.size).to eq(3)
        end
      end

      context "with filters with values" do
        before do
          BaseChild.add_filter(:filter1) { |item, value| item.age > value }
          BaseChild.add_filter(:filter2) { |item, value| item.age < value }
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
        end
      end

      context "with operations" do
        before { BaseChild.add_simple_operation(:new_attr) { |item| item.age * 2 } }

        it "executes operations" do
          result = BaseChild.new.organize
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.first.new_attr).to eq(44)
          expect(result.second.new_attr).to eq(62)
          expect(result.third.new_attr).to eq(128)
        end
      end

      context "with groups" do
        context "grouping by attribute" do
          before { BaseChild.add_group(:site_id) }

          it "groups collection items" do
            result = BaseChild.new.organize(group_by: :site_id)
            expect(result).to be_a(Organizer::Group::Collection)
            expect(result.size).to eq(3)
          end

          context "with operations" do
            before do
              BaseChild.add_memo_operation(:attrs_sum, 10) do |memo, item|
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
        end

        context "grouping by condition" do
          before { BaseChild.add_group(:age_greater_than_33, "item.age > 33") }

          it "groups collection items" do
            result = BaseChild.new.organize(group_by: :age_greater_than_33)
            expect(result).to be_a(Organizer::Group::Collection)
            expect(result.size).to eq(2)
          end
        end

        context "with nested groups" do
          before { BaseChild.add_group(:gender) }

          shared_examples :nested_group do
            it "groups collection by gender and site" do
              expect(@group).to be_a(Organizer::Group::Collection)
              expect(@group.size).to eq(2)
              expect(@group.first).to be_a(Organizer::Group::Item)
              expect(@group.first.size).to eq(3)
              expect(@group.first.first).to be_a(Organizer::Group::Item)
              expect(@group.first.first.size).to eq(2)
              expect(@group.first.first.first).to be_a(Organizer::Source::Item)
            end
          end

          context "nested through params" do
            before do
              BaseChild.add_group(:site_id)
              @group = BaseChild.new.organize(group_by: [:gender, :site_id])
            end

            it_should_behave_like(:nested_group)
          end

          context "nested on definition" do
            before do
              BaseChild.add_group(:site, :site_id, :gender)
              @group = BaseChild.new.organize(group_by: :gender)
            end

            it_should_behave_like(:nested_group)
          end

          context "with operations" do
            before do
              BaseChild.add_group(:site_id)
              BaseChild.add_memo_operation(:greater_age) do |memo, item|
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

  describe "#organize" do
    context "with undefined collection" do
      it "raises error with undefined collection" do
        expect { BaseChild.new.organize_data }.to(
          raise_organizer_error(Organizer::Exception, :undefined_collection_method))
      end
    end

    context "with a valid collection" do
      let_collection(:collection)
      before { BaseChild.add_collection { raw_collection } }

      context "working with filters" do
        before do
          BaseChild.add_filter(:filter1) { |item| item.age > 9 }
          BaseChild.add_filter(:filter2) { |item, value| item.age < value }
        end

        it "returns filtered collection" do
          result = @organizer.filter_by(:filter1).organize_data
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.size).to eq(8)
        end

        it "raises error chaning filter to invalid methods" do
          expect { @organizer.group_by(:gender).filter_by(:my_filter) }.to(
            raise_organizer_error(Organizer::ExecutorException, :invalid_chaining))
        end

        it "applies chained filters" do
          result = @organizer.filter_by(:filter1).filter_by(filter2: 33).organize_data
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.size).to eq(3)
        end

        context "with autogenerated filters" do
          it "applies filters" do
            result = @organizer.filter_by(age_eq: 8).organize_data
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.first.first_name).to eq("Francisco")
          end
        end

        context "with default filters" do
          before do
            BaseChild.add_default_filter { |item| item.age > 9 }
            BaseChild.add_default_filter(:my_filter) { |item| item.age < 33 }
          end

          it "returns filtered collection" do
            result = @organizer.organize_data
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(3)
          end

          it "skips default filter passing filter to skip_default_filter option" do
            result = @organizer.skip_default_filters(:my_filter).organize_data
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(8)
          end

          it "chains skip_default_filter with filter_by method" do
            result = @organizer.skip_default_filters(:my_filter).filter_by(:filter1).organize_data
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(8)
          end

          it "chains filter_by with skip_default_filter method" do
            result = @organizer.filter_by(:filter1).skip_default_filters(:my_filter).organize_data
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(8)
          end

          it "skips all default filters" do
            result = @organizer.skip_default_filters.organize_data
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(9)
          end

          it "raises error chaning skip filter to group by method" do
            expect { @organizer.group_by(:gender).skip_default_filters }.to(
              raise_organizer_error(Organizer::ExecutorException, :invalid_chaining))
          end

          it "raises error chaning skip filter to another skip filter" do
            expect { @organizer.skip_default_filters.skip_default_filters }.to(
              raise_organizer_error(Organizer::ExecutorException, :invalid_chaining))
          end
        end
      end
    end
  end
end
