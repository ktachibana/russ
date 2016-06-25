require 'spec_helper'

RSpec.describe TagsController, type: :controller do
  before { bypass_rescue }
  render_views

  let(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET :index' do
    def action
      get :index, format: :json
    end

    it 'サインインが必要' do
      sign_out(user)
      action
      is_expected.to respond_with(:unauthorized)
    end

    it 'サインインしていれば表示できる' do
      action
      expect(response).to be_success
    end

    it 'JSONを返す' do
      subscription = create(:subscription, user: user, feed: create(:feed, item_count: 1))
      subscription.update_attributes(tag_list: %w(tag1))

      action

      expect(response.content_type).to eq('application/json')
      tags = JSON.parse(response.body, symbolize_names: true)

      expect(tags).to be_a(Array)
      tags[0].tap do |tag|
        expect(tag[:id]).to eq(subscription.tags[0].id)
        expect(tag[:name]).to eq('tag1')
        expect(tag[:count]).to eq(1)
      end
    end
  end
end
