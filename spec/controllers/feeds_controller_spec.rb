require 'spec_helper'

describe FeedsController, type: :controller do
  let!(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET :index' do
    render_views

    it 'Subscription一覧を取得する' do
      subscriptions = create_list(:subscription, 2, user: user)
      create(:subscription, user: create(:user))
      get :index
      expect(response).to be_success
      expect(assigns(:subscriptions)).to match_array(subscriptions)
    end

    it '特定のタグがついたSubscriptionだけに絞り込める' do
      subscriptions = %w(tag1 tag2).map { |tag| create(:subscription, user: user, tag_list: tag) }
      get :index, tag: %w(tag1)
      expect(response).to be_success
      expect(assigns(:subscriptions)).to eq([subscriptions[0]])
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
