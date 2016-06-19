require 'spec_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before { bypass_rescue }
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe '#create' do
    let(:user) { create(:user) }

    it '認証が通ったら200 OKでuser情報を返す' do
      post :create, user: { email: user.email, password: user.password }, format: :json
      is_expected.to respond_with(:ok)
      expect(JSON.parse(response.body, symbolize_names: true)).to include(email: user.email)
    end
  end
end
