require 'spec_helper'

describe Item do
  describe 'validations' do
    it { should validate_presence_of(:feed_id) }
  end

  describe 'associations' do
    it { should belong_to(:feed) }
  end

  describe '.latest' do
    it 'ユーザーの最新のItemを取得する' do
      user = create(:user)
      other_user = create(:user)

      create(:feed, user: user).tap do |feed|
        create(:item, feed: feed, title: '3', published_at: 3.days.ago)
      end
      create(:feed, user: user).tap do |feed|
        create(:item, feed: feed, title: '2', published_at: 2.days.ago)
        create(:item, feed: feed, title: '1', published_at: 1.days.ago)
      end
      create(:feed, user: other_user).tap do |feed|
        create(:item, feed: feed, title: '4', published_at: Time.now)
      end

      Item.latest(user).map(&:title).should == %w[1 2 3]
    end
  end
end
