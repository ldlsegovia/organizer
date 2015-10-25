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

          it "skips all default filters" do
            result = @organizer.skip_default_filters.organize
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(9)
          end

          it "raises error chaning skip filter with other methods group by method" do
            expect { @organizer.filter_by(:gender).skip_default_filters }.to(
              raise_organizer_error(Organizer::ChainerException, :invalid_chaining))

            expect { @organizer.group_by(:gender).skip_default_filters }.to(
              raise_organizer_error(Organizer::ChainerException, :invalid_chaining))
          end
        end
      end

      context "working with operations" do
        before { BaseChild.add_source_operation(:new_attr) { |item| item.age * 2 } }

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

      context "sorting" do
        it "sorts collection ascending" do
          result = BaseChild.new.sort_by(:age).organize
          expect(result.first.age).to eq(8)
          expect(result.last.age).to eq(65)

          result = BaseChild.new.sort_by(age: :asc).organize
          expect(result.first.age).to eq(8)
          expect(result.last.age).to eq(65)
        end

        it "sorts collection descending" do
          result = BaseChild.new.sort_by(age: :desc).organize
          expect(result.first.age).to eq(65)
          expect(result.last.age).to eq(8)
        end

        it "sorts by multiple attributes" do
          result = BaseChild.new.sort_by(gender: :desc, age: :desc).organize
          expect(result.first.first_name).to eq("Rodolfo")
          expect(result.last.first_name).to eq("Virginia")

          result = BaseChild.new.sort_by(gender: :desc).sort_by(age: :desc).organize
          expect(result.first.first_name).to eq("Rodolfo")
          expect(result.last.first_name).to eq("Virginia")
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

          context "with operations" do
            before do
              BaseChild.add_groups_operation(:attrs_sum, 10) do |memo, item|
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

          context "with global operations" do
            before do
              BaseChild.add_group(:site_id)
              BaseChild.add_groups_operation(:greater_age) do |memo, item|
                memo.greater_age > item.age ? memo.greater_age : item.age
              end
              BaseChild.add_groups_operation(:lower_savings, nil) do |memo, item|
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

            context "with specific group operations" do
              before do
                BaseChild.add_group_operation(:gender, :odd_age_count, 0) do |memo, item|
                  item.age.odd? ? memo.odd_age_count + 1 : memo.odd_age_count
                end
                BaseChild.add_group_operation(:site_id, :even_age_count, 0) do |memo, item|
                  item.age.even? ? memo.even_age_count + 1 : memo.even_age_count
                end
              end

              it "applies operations to specific groups" do
                result = @organizer.group_by(:gender, :site_id).organize
                expect(result.first.odd_age_count).to eq(4)
                expect { result.first.even_age_count }.to raise_error(NoMethodError)
                expect(result.first.first.even_age_count).to eq(1)
                expect { result.first.first.odd_age_count }.to raise_error(NoMethodError)
              end
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

            context "sorting" do
              it "sorts parent group" do
                group = @organizer.group_by(:gender).sort_by(greater_age: :desc).group_by(:site_id).organize
                expect(group.first.greater_age).to eq(65)
                expect(group.last.greater_age).to eq(64)

                group = @organizer.group_by(:gender, :site_id).sort_by(greater_age: :desc).organize
                expect(group.first.greater_age).to eq(65)
                expect(group.last.greater_age).to eq(64)
              end

              it "sorts child group" do
                group = @organizer.group_by(:gender).group_by(:site_id).sort_by(:lower_savings).organize
                expect(group.first.first.lower_savings).to eq(2.5)
                expect(group.first.last.lower_savings).to eq(25.5)
                expect(group.last.first.lower_savings).to eq(30.0)
                expect(group.last.last.lower_savings).to eq(45.5)
              end
            end
          end
        end
      end
    end
  end
end
