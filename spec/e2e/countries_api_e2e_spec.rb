require "e2e_spec_helper"
RSpec.describe "Countries API end to end spec" do
  it_should_behave_like "crud endpoints", only: [:index] do
    let(:model) { FlexCommerce::Country }
  end
end