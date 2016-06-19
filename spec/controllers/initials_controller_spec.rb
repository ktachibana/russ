require 'spec_helper'

RSpec.describe InitialsController, type: :controller do
  describe 'GET #show' do
    def action
      get :show, format: :json
    end

    let!(:user) { create(:user) }
    let!(:subscription) { create(:subscription, user: user, tag_list: %w(foo bar)) }

    context 'ログインしているとき' do
      before { sign_in(user) }

      it 'アプリケーションの初期化情報を取得できる' do
        action
        is_expected.to respond_with(:ok)

        data = JSON.parse(response.body, symbolize_names: true)
        expect(data[:user]).to include(email: user.email,
                                       authentication_token: user.authentication_token)
        expect(data[:tags]).to include(include(name: 'foo', count: 1),
                                       include(name: 'bar', count: 1))
      end
    end

    context 'ログインしていないとき' do
      it '401 Unauthorizedでエラーメッセージを返し、初期化情報は返さない' do
        action
        is_expected.to respond_with(:unauthorized)

        data = JSON.parse(response.body, symbolize_names: true)
        expect(data.keys).to eq([:error])
      end
    end
  end
end
