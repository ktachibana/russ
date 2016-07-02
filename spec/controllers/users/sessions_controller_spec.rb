require 'spec_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before { bypass_rescue }
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe '#create' do
    let(:user) { create(:user) }
    let!(:subscription) { create(:subscription, user: user, tag_list: %w(foo)) }

    it '認証が通ったら200 OKで初期化情報を返す' do
      post :create, params: { user: { email: user.email, password: user.password }, format: :json }

      is_expected.to respond_with(:ok)

      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:user]).to include(email: user.email)
      expect(data[:tags]).to include(include(name: 'foo', count: 1))
    end
  end
end
