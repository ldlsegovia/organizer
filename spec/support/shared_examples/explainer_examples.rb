shared_examples :explainer do
  it "returns valid output" do
    regexp = Regexp.new(explainer.class.to_s.gsub("Organizer::", ""), true)
    expect { explainer.explain }.to(output(regexp).to_stdout)
  end
end
