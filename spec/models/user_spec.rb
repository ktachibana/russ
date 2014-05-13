require 'spec_helper'

describe User do
  describe 'associations' do
    it { is_expected.to have_many(:subscriptions).dependent(:destroy) }
    it { is_expected.to have_many(:feeds).through(:subscriptions) }
  end

  describe 'devise' do
    it '登録してもメールは送信されない' do
      create(:user, email: 'mail@example.com', password: 'password')
      expect(ActionMailer::Base.deliveries).to eq([])
    end
  end
end
