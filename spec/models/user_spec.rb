require 'spec_helper'

describe User do
  describe 'associations' do
    it { should have_many(:subscriptions).dependent(:destroy) }
    it { should have_many(:subscriptions).dependent(:destroy) }
  end

  describe 'devise' do
    it '登録してもメールは送信されない' do
      create(:user, email: 'mail@example.com', password: 'password')
      ActionMailer::Base.deliveries.should == []
    end
  end

  describe '#subscribe' do
    let(:user) { create(:user) }
    let!(:url) { mock_rss! }

    it '指定したURLのFeedとそのSubscriptionを生成する' do
      subscription = user.subscribe(url, title: 'MyTitle', tag_list: 'a, b')

      subscription.user.should == user
      subscription.title.should == 'MyTitle'
      subscription.tags.map(&:name).should == %w(a b)

      feed = subscription.feed
      feed.title.should == 'RSS Title'
      feed.url.should == url
    end

    context 'Feedが既に登録されているとき' do
      let!(:existing_feed) { create(:feed, url: url, user: user) }

      it 'Feedは既存のものを利用する' do
        subscription = user.subscribe(existing_feed.url, title: 'MyTitle')
        subscription.feed.should == existing_feed
        Feed.count.should == 1

        subscription.title.should == 'MyTitle'
      end
    end

    context 'Subscriptionが既に登録されているとき' do
      let!(:url) { mock_rss!(existing_subscription.feed.url) }
      let!(:existing_subscription) { create(:subscription, user: user, feed: create(:feed, user: user)) }

      it '重複エラーになる' do
        expect {
          user.subscribe(existing_subscription.feed.url, title: 'MyTitle')
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
