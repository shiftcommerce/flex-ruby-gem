RSpec.shared_context "housekeeping" do
  # A general purpose open struct that the examples can store objects (flex commerce model instances) or arrays of objects in
  # that will be cleaned up at the end of the top level context
  def to_clean
    context_store.to_clean
  end

  # Wrap around the creation of an instance for it to be cleaned up after the context
  def keep_tidy
    yield.tap do |o|
      to_clean.dumping_ground ||= []
      if o.is_a?(Array)
        to_clean.dumping_ground.concat o
      else
        to_clean.dumping_ground << o
      end
    end
  end

  before(:context) do
    context_store.to_clean = OpenStruct.new
  end

  # Clean up time - delete stuff in the reverse order to give us more chance of success
  after(:context) do
    to_clean.to_h.values.reverse.each do |resource|
      if resource.is_a?(Array)
        resource.each do |r|
          r.destroy rescue nil if r.persisted?
        end
      else
        resource.destroy rescue nil if resource.persisted?
      end
    end
  end
end
