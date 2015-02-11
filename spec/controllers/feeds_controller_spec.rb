require 'spec_helper'

describe FeedsController, type: :controller do
  render_views
  let!(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET :index' do
    def action
      get :index, params
    end
    let(:params) { { format: format } }
    let(:format) { nil }
    let!(:subscriptions) { [subscription] }
    let(:subscription) { create(:subscription, feed: feed, user: user, tag_list: tags) }
    let(:feed) { create(:feed, item_count: 1) }
    let(:tags) { %w(tag1 tag2) }
    let!(:others_subscription) { create(:subscription, user: create(:user)) }

    it 'Subscription一覧を取得する' do
      action
      expect(response).to be_success
      expect(assigns(:subscriptions)).to match_array(subscriptions)
    end

    context 'タグが与えられたとき' do
      let(:params) { super().merge(tag: %w(tag1)) }
      let!(:subscriptions) { %w(tag1 tag2).map { |tag| create(:subscription, user: user, tag_list: tag) } }

      it '特定のタグがついたSubscriptionだけに絞り込める' do
        action
        expect(response).to be_success
        expect(assigns(:subscriptions)).to eq([subscriptions[0]])
      end
    end

    context 'JSON形式をリクエストしたとき' do
      let(:format) { 'json' }

      it 'JSONを返す' do
        action
        is_expected.to respond_with(:ok)

        expect(response.content_type).to eq('application/json')

        data = JSON.parse(response.body, symbolize_names: true)

        data[:subscriptions][0].tap do |s|
          expect(s[:id]).to eq(subscription.id)
          expect(s[:userTitle]).to eq(subscription.user_title)
          expect(s[:tagList]).to eq(subscription.tag_list)

          s[:feed].tap do |f|
            feed = subscription.feed
            expect(f[:id]).to eq(feed.id)
            expect(f[:title]).to eq(feed.title)

            f[:latestItem].tap do |i|
              item = feed.items[0]
              expect(i[:title]).to eq(item.title)
            end
          end
        end
      end

      context '1つもItemがないとき' do
        let(:feed) { create(:feed, item_count: 0) }

        it 'feed.latest_itemがnull' do
          action
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:subscriptions][0][:feed][:latestItem]).to be nil
        end
      end
    end
  end

  describe 'GET :show' do
    let(:subscription) { create(:subscription, user: user) }

    it 'Feedを表示できる' do
      get :show, id: subscription.feed_id
      expect(assigns(:subscription)).to eq(subscription)
    end
  end
end
