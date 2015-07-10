#
# A collection of examples expected to pass for all collections
# at the model level.
#
# methods expected to be in scope (defined by let)
# @param [Object] subject The subject under test (the collection)
# @param [Numeric] quantity The quantity expected in total
# @param [Numeric] total_pages The total number of pages expected
# @param [Numeric|Nil] current_page (defaults to 1) The current page expected
# @param [Numeric] expected_list_quantity The number of items expected in the list (paginated)
# @param [Class] subject_class The class of the subject under test
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
