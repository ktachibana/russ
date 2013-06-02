require 'spec_helper'

describe RootController do
  let(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET :index' do
    it 'サインインが必要' do
      sign_out(user)
      get :index
      response.should redirect_to(new_user_session_url)
    end

    it 'サインインしていれば表示できる' do
      get :index
      response.should be_success
    end

    it '最近のItemを取得する' do
      create(:rss_source, user: user).tap do |s|
        26.times do |i|
          create(:item, rss_source: s, title: i.to_s, published_at: i.days.ago)
        end
      end

      get :index
      assigns(:items).map(&:title).should == (0...25).map(&:to_s)
    end
  end
end
