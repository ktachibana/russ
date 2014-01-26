require 'spec_helper'

describe Subscription do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:feed) }
    it { should have_many(:tags).class_name('ActsAsTaggableOn::Tag') }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:feed_id) }
  end

  describe '#user_title' do
    subject { subscription.user_title }
    let(:subscription) { create(:subscription, title: title) }

    context 'titleが未設定のとき' do
      let(:title) { nil }

      it 'feedのtitleを返す' do
        should == subscription.feed.title
      end
    end

    context 'titleが設定されているとき' do
      let(:title) { 'MyTitle' }

      it 'titleを返す' do
        should == subscription.title
      end
    end
  end
end
