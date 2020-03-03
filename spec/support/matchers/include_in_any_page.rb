# This matcher allows the test to verify that the given matchers are all matched in any page of the result set until no
# more results are returned by the API.
# This enables verification that a resource has been inserted and is available in the collection, no matter what page it is in.
#
# This is slow, especially if the results are not sorted in a way that enables them to be found early, so ideally if you
# know a way of sorting the results in the query to ensure the new
RSpec::Matchers.define :include_in_any_page do |*matchers|
  match do |builder|
    @to_match = matchers.clone
    results = builder.find
    while @to_match.present? && results.length > 0
      matches = []
      @to_match.each do |matcher|
        im = RSpec::Matchers::BuiltIn::Include.new(matcher)
        if im.matches?(results)
          matches << matcher
        end
      end
      @to_match.delete_if { |m| matches.include?(m) }
      next_page = builder.send(:pagination_params)[:page][:number] + 1
      results = builder.page(next_page).find
    end
    @to_match.empty?
  end

  failure_message do
    messages = ["Expected the given matchers to match in any page, but the following were not matched:"]
    failed_matchers = @to_match.map(&:description)
    (messages + failed_matchers).join("\n")
  end
end
