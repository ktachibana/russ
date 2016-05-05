require 'spec_helper'

describe Subscription, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:feed) }
    it { is_expected.to have_many(:tags).class_name('ActsAsTaggableOn::Tag') }
  end

  describe 'validations' do
    subject { build(:subscription) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_uniqueness_of(:feed_id).scoped_to(:user_id) }
    it { is_expected.to validate_length_of(:title).is_at_most(255) }
  end

  describe '.default_scope' do
    it 'created_atの新しい順' do
      subscriptions = [3, 1, 2].map do |n|
        create(:subscription, created_at: n.days.ago)
      end
      expect(Subscription.all).to eq(subscriptions.values_at(1, 2, 0))
    end
  end

  describe '#user_title' do
    subject { subscription.user_title }
    let(:subscription) { create(:subscription, title: title) }

    context 'titleが未設定のとき' do
      let(:title) { nil }

      it 'feedのtitleを返す' do
        is_expected.to eq(subscription.feed.title)
      end
    end

    context 'titleが設定されているとき' do
      let(:title) { 'MyTitle' }

      it 'titleを返す' do
        is_expected.to eq(subscription.title)
      end
    end
  end
end
