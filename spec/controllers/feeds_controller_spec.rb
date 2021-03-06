# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedsController, type: :controller do
  render_views
  let!(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET :index' do
    def action
      get :index, params: params
    end
    let(:params) { { format: :json } }
    let!(:subscriptions) { [subscription] }
    let(:subscription) { create(:subscription, feed: feed, user: user, tag_list: tags) }
    let(:feed) { create(:feed, item_count: 1) }
    let(:tags) { %w[tag1 tag2] }
    let!(:others_subscription) { create(:subscription, user: create(:user)) }

    it 'フィード一覧を表示する' do
      action
      expect(response).to be_successful
      is_expected.to render_template('index')
    end

    context 'JSON形式をリクエストしたとき' do
      let(:format) { 'json' }

      it 'JSONを返す' do
        action
        is_expected.to respond_with(:ok)

        expect(response.media_type).to eq('application/json')

        data = JSON.parse(response.body, symbolize_names: true)

        data[:subscriptions][0].tap do |s|
          expect(s[:id]).to eq(subscription.id)
          expect(s[:userTitle]).to eq(subscription.user_title)

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

      context 'タグが与えられたとき' do
        let(:params) { super().merge(tag: %w[tag1]) }
        let!(:subscriptions) { %w[tag1 tag2].map { |tag| create(:subscription, user: user, tag_list: tag) } }

        it '特定のタグがついたSubscriptionだけに絞り込める' do
          action
          expect(response).to be_successful
          expect(assigns(:subscriptions)).to eq([subscriptions[0]])
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
end
