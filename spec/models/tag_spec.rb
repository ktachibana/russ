require 'spec_helper'

describe Tag do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should ensure_length_of(:name).is_at_most(255) }
    describe 'uniqueness' do
      before { create(:tag) }
      it { should validate_uniqueness_of(:name).scoped_to(:user_id) }
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:rss_sources).through(:taggings) }
  end
end
