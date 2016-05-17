# Expected definitions
#
# model - The model to use for the tests
# base_attributes - The attributes to use when creating
# update_attributes - attributes to update in update test

RSpec.shared_examples_for "crud endpoints" do
  cache = {}
  let!(:create_attributes) { cache[:create_attributes] ||= base_attributes }
  let!(:update_attributes) { cache[:update_attributes] ||= attributes_to_update }
  before :context do
    cache = {}
  end
  context "#create" do
    subject { cache[:created_subject] ||= model.create(create_attributes) }
    it "should be persisted" do
      expect(subject).to be_persisted
    end
    it "should have all the core attributes with exactly the same values" do
      expect(subject).to have_attributes(create_attributes)
    end
    it "should have an id" do
      expect(subject).to have_attributes(id: instance_of(String))
    end
  end
  # All indexes must support the sorting by created_at else this will not work
  # we have to do this otherwise we could be paging through a significant amount of data
  # using lots of requests until we find what we want
  context "#index" do
    subject { cache[:indexed_subject] ||= model.order(created_at: :desc).all }
    it "should contain many instances of the model" do
      expect(subject).to all(be_a model)
    end
    it "should contain the created instance somewhere" do
      expect(subject.find {|instance| instance.id == cache[:created_subject].id}).to be_truthy
    end

  end
  context "#show" do
    subject { cache[:show_subject] ||= model.find(cache[:created_subject].id) }
    it "should be an instance of the model" do
      expect(subject).to be_a model
    end
    it "should have the correct attributes" do
      expect(subject).to have_attributes cache[:create_attributes]
    end

  end
  context "#update" do
    let(:original_subject) { cache[:show_subject] }
    subject { cache[:updated_subject] ||= original_subject.update_attributes(update_attributes) }
    it "should return true" do
      expect(subject).to be true
    end
    it "should have persisted the changes" do
      expect(model.find(original_subject.id)).to have_attributes(update_attributes)
    end
  end
  # Note that this MAY NOT WORK in all cases.  I am fairly sure that show will show a deleted value
  # because of soft delete.  However, I believe this is going to change so that delete does actually
  # properly delete, so if there are test failures then they are probably valid
  context "#delete" do
    it "should remove the created instance" do
      original_id = cache[:created_subject].id
      cache[:created_subject].destroy
      expect {model.find(original_id)}.to raise_exception FlexCommerceApi::Error::NotFound
    end

  end
end