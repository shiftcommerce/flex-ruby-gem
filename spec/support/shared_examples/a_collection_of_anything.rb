shared_examples_for "a collection of anything" do
  it "should have the correct pagination data" do
    expect(subject.total_entries).to eql quantity
    expect(subject.total_pages).to eql total_pages
    expect(subject.current_page).to eql(current_page.nil? ? 1 : current_page)
    expect(subject.count).to eql expected_list_quantity
  end
  it "should have the correct instance types" do
    subject.each do |instance|
      expect(instance).to be_a subject_class
    end
  end
end
