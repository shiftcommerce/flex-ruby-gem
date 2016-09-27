RSpec.shared_context "context store" do
  _context_store = OpenStruct.new
  before(:context) { _context_store = OpenStruct.new }
  define_method(:context_store) { _context_store }
end
