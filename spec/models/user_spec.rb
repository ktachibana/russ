require 'spec_helper'

describe User do
  describe 'devise' do
    it '登録してもメールは送信されない' do
      create(:user, email: 'mail@example.com', password: 'password')
      ActionMailer::Base.deliveries.should == []
    end
  end
end
