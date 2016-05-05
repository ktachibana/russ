require 'spec_helper'

RSpec.describe RootController, type: :controller do
  let(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET :index' do
    render_views

    def action
      get :index, params
    end
    let(:params) { nil }

    it 'サインインが必要' do
      sign_out(user)
      action
      expect(response).to redirect_to(new_user_session_url)
    end

    it 'サインインしていれば表示できる' do
      action
      expect(response).to be_success
    end

    context 'JSON形式をリクエストしたとき' do
      before do
        request.headers['HTTP_ACCEPT'] = 'application/json'
      end

      it '最近のItemを取得する' do
        create(:subscription, user: user).tap do |subscription|
          26.times do |i|
            create(:item, feed: subscription.feed, title: i.to_s, published_at: i.days.ago)
          end
        end

        action
        expect(assigns(:items).map(&:title)).to eq((0...25).map(&:to_s))
      end

      it 'JSONを返す' do
        subscription = create(:subscription, user: user, feed: create(:feed, item_count: 1))
        subscription.update_attributes(tag_list: %w(tag1))

        action

        expect(response.content_type).to eq('application/json')
        data = JSON.parse(response.body, symbolize_names: true)

        expect(data[:items][:items][0][:id]).to eq(subscription.feed.items[0].id)

        data[:tags].tap do |tags|
          expect(tags).to be_a(Array)
          data[:tags][0].tap do |tag|
            expect(tag[:id]).to eq(subscription.tags[0].id)
            expect(tag[:name]).to eq('tag1')
            expect(tag[:count]).to eq(1)
          end
        end
      end
    end
  end
end
