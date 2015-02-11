require 'spec_helper'

describe ItemsController, type: :controller do
  let(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET :index' do
    render_views

    def action
      get :index, page: page, format: :json
    end
    let(:page) { nil }
    let(:data) { JSON.parse(response.body, symbolize_names: true) }

    it 'サインインが必要' do
      sign_out(user)
      action
      is_expected.to respond_with(:unauthorized)
    end

    it 'サインインしていれば表示できる' do
      action
      is_expected.to respond_with(:ok)
    end

    it 'Itemを取得する' do
      subscription = create(:subscription, user: user)
      item = create(:item, feed: subscription.feed)

      action
      expect(data[:items][0][:id]).to eq(item.id)
      expect(data[:lastPage]).to be true
    end

    context 'itemが大量にあるとき' do
      before do
        create(:subscription, user: user).tap do |subscription|
          26.times do |i|
            create(:item, feed: subscription.feed, title: i.to_s, published_at: i.days.ago)
          end
        end
      end

      it '取得件数が制限される' do
        action
        expect(data[:items].size).to eq(25)
        expect(data[:lastPage]).to be false
      end

      context 'pageパラメータを指定したとき' do
        let(:page) { '2' }

        it '指定したページのItemを取得する' do
          action
          items = data[:items]
          expect(items.size).to eq(1)
          expect(items[0][:title]).to eq('25')
        end
      end
    end
  end
end
