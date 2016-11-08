RSpec.shared_context "housekeeping" do
  def to_clean
    context_store.to_clean
  end

  def keep_tidy
    yield.tap do |o|
      to_clean.dumping_ground ||= []
      to_clean.dumping_ground << o
    end
  end

  # As setting up for testing can be very expensive, we do it only at the start of then context
  # it is then our responsibility to tidy up at the end of the context.
  # In this case the expensive thing is the product, but the uuid is conveniently setup here to give us a unique id
  # for the whole context.  Useful for when attributes in your test data must be unique.
  before(:context) do
    uuid = SecureRandom.uuid
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
