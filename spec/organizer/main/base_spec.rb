require 'spec_helper'

describe Organizer::Base do
  let_collection(:collection)

  before do
    Object.send(:remove_const, :BaseChild) rescue nil
    class BaseChild < Organizer::Base; end
    @organizer = BaseChild.new
  end

  describe "#organize" do
    context "with undefined collection" do
      it "raises error with undefined collection" do
        expect { BaseChild.new.organize }.to(
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
          result = @organizer.filter_by(:filter1).organize
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.size).to eq(8)
        end

        it "applies chained filters calling filter_by several times" do
          result = @organizer.filter_by(:filter1).filter_by(filter2: 33).organize
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.size).to eq(3)
        end

        it "applies chained filter calling filter by once" do
          result = @organizer.filter_by(:filter1, filter2: 33).organize
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.size).to eq(3)
        end

        context "with default filters" do
          before do
            BaseChild.add_default_filter { |item| item.age > 9 }
            BaseChild.add_default_filter(:my_filter) { |item| item.age < 33 }
          end

          it "returns filtered collection" do
            result = @organizer.organize
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(3)
          end

          it "skips default filter passing filter to skip_default_filter option" do
            result = @organizer.skip_default_filters(:my_filter).organize
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(8)
          end

          it "chains skip_default_filter with filter_by method" do
            result = @organizer.skip_default_filters(:my_filter).filter_by(:filter1).organize
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(8)
          end

          it "chains filter_by with skip_default_filter method" do
            result = @organizer.filter_by(:filter1).skip_default_filters(:my_filter).organize
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(8)
          end

          it "skips all default filters" do
            result = @organizer.skip_default_filters.organize
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(9)
          end

          it "raises error chaning skip filter to group by method" do
            expect { @organizer.group_by(:gender).skip_default_filters }.to(
              raise_organizer_error(Organizer::ChainerException, :invalid_chaining))
          end

          it "raises error chaning skip filter to another skip filter" do
            expect { @organizer.skip_default_filters.skip_default_filters }.to(
              raise_organizer_error(Organizer::ChainerException, :invalid_chaining))
          end
        end
      end

      context "working with operations" do
        before { BaseChild.add_simple_operation(:new_attr) { |item| item.age * 2 } }

        it "executes operations" do
          result = BaseChild.new.organize
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.first.new_attr).to eq(44)
          expect(result.second.new_attr).to eq(62)
          expect(result.third.new_attr).to eq(128)
        end

        context "working with filters" do
          before { BaseChild.add_filter(:filter1) { |item| item.new_attr > 66 } }

          it "filters by generated attribute" do
            result = BaseChild.new.filter_by(:filter1).organize
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(3)
          end
        end
      end

      context "working with groups" do
        context "grouping by attribute" do
          before { BaseChild.add_group(:site_id) }

          it "groups collection items" do
            result = @organizer.group_by(:site_id).organize
            expect(result).to be_a(Organizer::Group::Collection)
            expect(result.size).to eq(3)
          end

          it "allows to chain group after skip_default_filters method" do
            BaseChild.add_default_filter(:my_filter) { true }
            expect { @organizer.skip_default_filters(:my_filter).group_by(:site_id).organize }.to_not raise_error
          end

          it "allows to chain group after filter_by method" do
            BaseChild.add_filter(:my_filter) { true }
            expect { @organizer.filter_by(:my_filter).group_by(:site_id).organize }.to_not raise_error
          end

          context "with operations" do
            before do
              BaseChild.add_memo_operation(:attrs_sum, 10) do |memo, item|
                memo.attrs_sum + item.age
              end
            end

            it "groups collection items" do
              result = @organizer.group_by(:site_id).organize
              result.each do |group_item|
                expected_sum = group_item.inject(10) { |memo, source_item| memo + source_item.age }
                expect(group_item.attrs_sum).to eq(expected_sum)
              end
            end
          end
        end

        context "grouping by condition" do
          before { BaseChild.add_group(:age_greater_than_33, "item.age > 33") }

          it "groups collection items" do
            result = @organizer.group_by(:age_greater_than_33).organize
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
            before { BaseChild.add_group(:site_id) }

            context "calling group by once" do
              before { @group = @organizer.group_by(:gender, :site_id).organize }

              it_should_behave_like(:nested_group)
            end

            context "calling group by several times" do
              before { @group = @organizer.group_by(:gender).group_by(:site_id).organize }

              it_should_behave_like(:nested_group)
            end
          end

          context "nested on definition" do
            before do
              BaseChild.add_group(:site, :site_id, :gender)
              @group = @organizer.group_by(:gender).organize
            end

            it_should_behave_like(:nested_group)
          end

          context "with operations" do
            before do
              BaseChild.add_group(:site_id)
              BaseChild.add_memo_operation(:greater_age) do |memo, item|
                memo.greater_age > item.age ? memo.greater_age : item.age
              end
              BaseChild.add_memo_operation(:lower_savings, nil) do |memo, item|
                memo.lower_savings = item.savings if memo.lower_savings.nil?
                memo.lower_savings < item.savings ? memo.lower_savings : item.savings
              end
            end

            it "applies operations to full group hierarchy" do
              result = @organizer.group_by(:gender, :site_id).organize
              expect(result.first.lower_savings).to eq(2.5)
              expect(result.first.first.lower_savings).to eq(15.5)
              expect(result.second.greater_age).to eq(64)
              expect(result.second.first.greater_age).to eq(64)
            end

            context "filtering groups" do
              before do
                BaseChild.add_filter(:greater_age_greater_than) do |item, value|
                  item.greater_age > value
                end
                BaseChild.add_filter(:lower_savings_lower_than) do |item, value|
                  item.lower_savings < value
                end
              end

              it "applies filters to first group passing group names as array" do
                q = @organizer.group_by(:gender, :site_id)
                q = q.filter_by(greater_age_greater_than: 64)
                result = q.organize

                expect(result.size).to eq(1)
                expect(result.first.greater_age).to eq(65)
                expect(result.first.size).to eq(3)
              end

              it "applies filters to previous group" do
                q = @organizer.group_by(:gender).filter_by(greater_age_greater_than: 64)
                q = q.group_by(:site_id).filter_by(lower_savings_lower_than: 10)
                result = q.organize

                expect(result.size).to eq(1)
                expect(result.first.greater_age).to eq(65)
                expect(result.first.size).to eq(1)
                expect(result.first.first.lower_savings).to eq(2.5)
              end

              it "applies multiple filters to previous group" do
                q = @organizer.group_by(:site_id)
                q = q.filter_by(greater_age_greater_than: 64, lower_savings_lower_than: 3)
                result = q.organize

                expect(result.size).to eq(1)
                expect(result.first.greater_age).to eq(65)
                expect(result.first.lower_savings).to eq(2.5)
              end
            end
          end
        end
      end
    end
  end
end
