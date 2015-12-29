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
        expect { @organizer.organize }.to(
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

        it "raises error trying to apply unknown filters" do
          expect { @organizer.filter_by(:unknown_filter).organize }.to(
            raise_organizer_error(Organizer::Source::Filter::SelectorException, :unknown_filter))
        end

        context "with default filters" do
          before do
            BaseChild.add_source_default_filter { |item| item.age > 9 }
            BaseChild.add_source_default_filter(:default_filter1) { |item| item.age < 33 }
          end

          it "returns filtered collection" do
            result = @organizer.organize
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(3)
          end

          it "skips default filter passing filter to skip_default_filter option" do
            result = @organizer.skip_default_filters(:default_filter1).organize
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(8)
          end

          it "skips all default filters" do
            result = @organizer.skip_default_filters.organize
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(9)
          end

          it "raises error chaning skip filter twice" do
            expect { @organizer.skip_default_filters.skip_default_filters }.to(
              raise_organizer_error(Organizer::ChainerException, :invalid_chaining))
          end
        end
      end

      context "working with operations" do
        before { BaseChild.add_source_operation(:new_attr) { |item| item.age * 2 } }

        it "executes operations" do
          result = @organizer.organize
          expect(result).to be_a(Organizer::Source::Collection)
          expect(result.first.new_attr).to eq(44)
          expect(result.second.new_attr).to eq(62)
          expect(result.third.new_attr).to eq(128)
        end

        context "working with filters" do
          before { BaseChild.add_filter(:filter1) { |item| item.new_attr > 66 } }

          it "filters by generated attribute" do
            result = @organizer.filter_by(:filter1).organize
            expect(result).to be_a(Organizer::Source::Collection)
            expect(result.size).to eq(3)
          end
        end

        context "working with masked attributes" do
          before do
            BaseChild.add_source_mask_operation(:new_attr, :currency, unit: ":-) ")
          end

          it "applies mask to attribute" do
            result = @organizer.organize
            expect(result.first.human_new_attr).to eq(":-) 44.00")
          end
        end
      end

      context "sorting" do
        it "sorts collection ascending" do
          result = @organizer.sort_by(:age).organize
          expect(result.first.age).to eq(8)
          expect(result.last.age).to eq(65)

          result = @organizer.sort_by(age: :asc).organize
          expect(result.first.age).to eq(8)
          expect(result.last.age).to eq(65)
        end

        it "sorts collection descending" do
          result = @organizer.sort_by(age: :desc).organize
          expect(result.first.age).to eq(65)
          expect(result.last.age).to eq(8)
        end

        it "sorts by multiple attributes" do
          result = @organizer.sort_by(gender: :desc, age: :desc).organize
          expect(result.first.first_name).to eq("Rodolfo")
          expect(result.last.first_name).to eq("Virginia")

          result = @organizer.sort_by(gender: :desc).sort_by(age: :desc).organize
          expect(result.first.first_name).to eq("Rodolfo")
          expect(result.last.first_name).to eq("Virginia")
        end
      end

      context "working with groups" do
        context "grouping by attribute" do
          before { BaseChild.add_group_definition(:site_id) }

          it "groups collection items" do
            result = @organizer.group_by_site_id.organize
            expect(result).to be_a(Organizer::Group::Collection)
            expect(result.size).to eq(3)
          end

          it "raises error trying to group by unknown group" do
            expect { @organizer.group_by_unknown.organize }.to(
              raise_organizer_error(Organizer::Group::SelectorException, :unknown_group))
          end

          context "with operations" do
            before do
              BaseChild.add_groups_parent_item_operation(:attrs_sum, 10) do |parent, item|
                parent.attrs_sum + item.age
              end
            end

            it "groups collection items" do
              result = @organizer.group_by_site_id.organize
              result.each do |group_item|
                expected_sum = group_item.inject(10) { |parent, source_item| parent + source_item.age }
                expect(group_item.attrs_sum).to eq(expected_sum)
              end
            end
          end
        end

        context "with nested groups" do
          before do
            BaseChild.add_group_definition(:gender)
            BaseChild.add_group_definition(:site, :site_id, :gender)
          end

          it "groups collection by gender and site" do
            group = @organizer.group_by_gender.organize
            expect(group).to be_a(Organizer::Group::Collection)
            expect(group.size).to eq(2)
            expect(group.first).to be_a(Organizer::Group::Item)
            expect(group.first.size).to eq(3)
            expect(group.first.first).to be_a(Organizer::Group::Item)
            expect(group.first.first.size).to eq(2)
            expect(group.first.first.first).to be_a(Organizer::Source::Item)
          end

          it "raises error trying to call group by twice" do
            expect { @organizer.group_by_gender.group_by_site }.to(
              raise_organizer_error(Organizer::ChainerException, :invalid_chaining))
          end

          context "with global operations" do
            before do
              BaseChild.add_groups_parent_item_operation(:greater_age) do |parent, item|
                parent.greater_age > item.age ? parent.greater_age : item.age
              end
              BaseChild.add_groups_parent_item_operation(:lower_savings, nil) do |parent, item|
                parent.lower_savings = item.savings if parent.lower_savings.nil?
                parent.lower_savings < item.savings ? parent.lower_savings : item.savings
              end
              BaseChild.add_groups_item_operation(:saving_by_age) do |item|
                item.greater_age * item.lower_savings
              end
            end

            it "applies parent operations to full group hierarchy" do
              result = @organizer.group_by_gender.organize
              expect(result.first.lower_savings).to eq(2.5)
              expect(result.first.first.lower_savings).to eq(15.5)
              expect(result.second.greater_age).to eq(64)
              expect(result.second.first.greater_age).to eq(64)
            end

            it "applies group item operations to full group hierarchy" do
              result = @organizer.group_by_gender.organize
              expect(result.first.saving_by_age).to eq(162.5)
              expect(result.first.first.saving_by_age).to eq(480.5)
              expect(result.second.saving_by_age).to eq(1920.0)
              expect(result.second.first.saving_by_age).to eq(1920.0)
            end

            context "with specific group operations" do
              before do
                BaseChild.add_group_parent_item_operation(:odd_age_count, 0) do |parent, item|
                  item.age.odd? ? parent.odd_age_count + 1 : parent.odd_age_count
                end
                BaseChild.add_group_item_operation(:double_age_count) do |item|
                  item.odd_age_count * 2
                end
                BaseChild.add_group_child_item_operation(:age_salad) do |item, site, gender|
                  item.age + site.greater_age + gender.saving_by_age
                end
              end

              it "applies parent operations to specific groups" do
                result = @organizer.group_by_gender.organize
                expect { result.first.odd_age_count }.to raise_error(NoMethodError)
                expect(result.first.first.odd_age_count).to eq(1)
              end

              it "applies group item operations to specific groups" do
                result = @organizer.group_by_gender.organize
                expect { result.first.double_age_count }.to raise_error(NoMethodError)
                expect(result.first.first.double_age_count).to eq(2)
              end

              it "applies child operations to specific group items children" do
                result = @organizer.group_by_gender.organize
                expect { result.first.age_salad }.to raise_error(NoMethodError)
                expect { result.first.first.age_salad }.to raise_error(NoMethodError)
                expect(result.first.first.first.age_salad).to eq(215.5)
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

              it "applies filters to related groups" do
                q = @organizer.group_by_gender
                q = q.filter_gender_by(greater_age_greater_than: 64)
                q = q.filter_site_by(lower_savings_lower_than: 10)
                result = q.organize

                expect(result.size).to eq(1)
                expect(result.first.greater_age).to eq(65)
                expect(result.first.size).to eq(1)
                expect(result.first.first.lower_savings).to eq(2.5)
              end

              it "raises error trying to apply filter to unknown group" do
                expect { @organizer.group_by_gender.filter_gender_by(value: 64).organize }.to(
                  raise_organizer_error(Organizer::Group::Filter::SelectorException, :unknown_filter))
              end

              it "raises error trying to apply unknown filter to known group" do
                expect { @organizer.group_by_gender.filter_unknown_group_by(value: 64).organize }.to(
                  raise_organizer_error(Organizer::Group::Filter::SelectorException, :unknown_group))
              end

              it "applies multiple filters" do
                q = @organizer.group_by_gender
                q = q.filter_gender_by(greater_age_greater_than: 64, lower_savings_lower_than: 3)
                result = q.organize

                expect(result.size).to eq(1)
                expect(result.first.greater_age).to eq(65)
                expect(result.first.lower_savings).to eq(2.5)
              end
            end

            context "sorting" do
              it "sorts related groups" do
                q = @organizer.group_by_gender
                q = q.sort_gender_by(:greater_age)
                q = q.sort_site_by(lower_savings: :desc)
                result = q.organize

                expect(result.first.greater_age).to eq(64)
                expect(result.first.first.lower_savings).to eq(45.5)
                expect(result.first.last.lower_savings).to eq(30.0)
                expect(result.last.greater_age).to eq(65)
                expect(result.last.first.lower_savings).to eq(25.5)
                expect(result.last.last.lower_savings).to eq(2.5)
              end

              it "raises error trying to sort unknown groups" do
                expect { @organizer.group_by_gender.sort_unknown_group_by(value: 64).organize }.to(
                  raise_organizer_error(Organizer::Group::Sort::BuilderException, :unknown_group))
              end
            end
          end
        end
      end
    end
  end
end
