require 'spec_helper'

describe Organizer::Operation::MaskBuilder do
  subject { Organizer::Operation::MaskBuilder }

  describe "#build" do
    let_item(:source_item)

    it "raises error passing invalid mask as parameter" do
      expect { subject.build(:age, :invalid_mask) }.to(
        raise_error(Organizer::Operation::MaskBuilderException))
    end

    it "creates desired operation with valid mask" do
      operation = subject.build(:int_attr1, :currency)
      operation.execute(source_item)
      expect(source_item.human_int_attr1).to eq("$400.00")
    end

    it "allows to pass mask as string" do
      operation = subject.build("int_attr1", :percentage)
      operation.execute(source_item)
      expect(source_item.human_int_attr1).to eq("400.000%")
    end

    it "uses custom options" do
      operation = subject.build("int_attr1", :currency, precision: 5)
      operation.execute(source_item)
      expect(source_item.human_int_attr1).to eq("$400.00000")
    end
  end
end
