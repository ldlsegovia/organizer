require 'spec_helper'

describe Organizer::Operation::MaskBuilder do
  subject { Organizer::Operation::MaskBuilder }

  describe "#build" do
    let_item(:source_item)

    {
      currency: { attr: :int_attr1, expected: "€400.000", options: { unit: "€", precision: 3 } },
      natural: { attr: :int_attr1, expected: "400" },
      size: { attr: :int_attr1, expected: "400 Bytes" },
      percentage: { attr: :int_attr1, expected: "400,0000%", options: { precision: 4, delimiter: '.', separator: ',' } },
      phone: { attr: :int_attr1, expected: "400 x 555", options: { extension: 555 } },
      delimited: { attr: :int_attr1, expected: "400", options: { delimiter: "." } },
      rounded: { attr: :int_attr1, expected: "400.00", options: { precision: 2 } },
      clean: { attr: :string_attr, expected: "hi! im a string", options: { capitalize: false } },
      truncated: { attr: :string_attr, expected: "Hi...", options: 5 },
      capitalized: { attr: :string_attr, expected: "Hi! im a string" },
      downcase: { attr: :string_attr, expected: "hi! im a string" },
      upcase: { attr: :string_attr, expected: "HI! IM A STRING" },
      date: { attr: :date_attr, expected: "1984-06-04" },
      datetime: { attr: :datetime_attr, expected: "1984-06-04 06:06:06" },
      time: { attr: :float_attr, expected: "00:04:00", options: { measure: :minutes } }
    }.each do |mask, config|
      it "applies #{mask} mask" do
        operation = subject.build(config[:attr], mask, config[:options])
        operation.execute(source_item)
        expect(source_item.send("human_#{config[:attr]}")).to eq(config[:expected])
      end
    end

    it "raises error passing invalid mask as parameter" do
      expect { subject.build(:age, :invalid_mask, nil) }.to(
        raise_error(Organizer::Operation::MaskBuilderException))
    end

    it "allows to pass mask as string" do
      operation = subject.build("int_attr1", :percentage)
      operation.execute(source_item)
      expect(source_item.human_int_attr1).to eq("400.000%")
    end
  end
end
