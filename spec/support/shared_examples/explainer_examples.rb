shared_examples :explainer do
  it "has explain mehtod" do
    expect(explainer).to respond_to(:explain)
  end

  it "returns valid output" do
    regexp = Regexp.new(explainer.class.to_s.gsub("Organizer::", ""), true)
    expect { explainer.explain }.to(output(regexp).to_stdout)
  end
end
