require 'spec_helper'

describe User do
  describe 'associations' do
    it { should have_many(:rss_sources).dependent(:destroy) }
  end

  describe 'devise' do
    it '登録してもメールは送信されない' do
      create(:user, email: 'mail@example.com', password: 'password')
      ActionMailer::Base.deliveries.should == []
    end
  end
end
