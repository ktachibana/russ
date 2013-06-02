require 'spec_helper'

describe RootController do

  describe 'GET :index' do
    it 'サインインが必要' do
      get :index
      response.should redirect_to(new_user_session_url)
    end

    it 'サインインしていれば表示できる' do
      sign_in(create(:user))
      get :index
      response.should be_success
    end
  end
end
