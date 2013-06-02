require 'spec_helper'

describe Item do
  describe 'validations' do
    it { should validate_presence_of(:rss_source_id) }
  end

  describe 'associations' do
    it { should belong_to(:rss_source) }
  end

  describe '.latest' do
    it 'ユーザーの最新のItemを取得する' do
      user = create(:user)
      other_user = create(:user)

      create(:rss_source, user: user).tap do |s|
        create(:item, rss_source: s, title: '3', published_at: 3.days.ago)
      end
      create(:rss_source, user: user).tap do |s|
        create(:item, rss_source: s, title: '2', published_at: 2.days.ago)
        create(:item, rss_source: s, title: '1', published_at: 1.days.ago)
      end
      create(:rss_source, user: other_user).tap do |s|
        create(:item, rss_source: s, title: '4', published_at: Time.now)
      end

      Item.latest(user).map(&:title).should == %w[1 2 3]
    end
  end
end
