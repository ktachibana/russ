require 'spec_helper'

RSpec.describe ItemsController, type: :controller do
  let(:user) { create(:user) }

  describe 'GET :index' do
    render_views

    def action
      get :index, params: { page: page, format: :json }
    end
    let(:page) { nil }
    let(:data) { JSON.parse(response.body, symbolize_names: true) }

    context 'サインインしているとき' do
      before { sign_in(user) }

      it '表示できる' do
        action
        is_expected.to respond_with(:ok)
      end

      it 'Itemを取得する' do
        subscription = create(:subscription, user: user)
        item = create(:item, feed: subscription.feed)

        action
        expect(data[:items][0][:id]).to eq(item.id)
        expect(data[:pagination]).to eq(perPage: 25, totalCount: 1)
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
          expect(data[:pagination]).to eq(perPage: 25, totalCount: 26)
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

    context 'サインインしていないとき' do
      it 'アクセスできない' do
        action
        is_expected.to respond_with(:unauthorized)
      end
    end
  end
end
