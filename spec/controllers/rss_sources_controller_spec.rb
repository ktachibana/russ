require 'spec_helper'

describe RssSourcesController do
  let!(:user) { sign_in(create(:user)) }

  describe 'GET :new' do
    it 'RssSourceの情報をURLからロードできる' do
      mock_rss!

      get :new, url: mock_rss_url

      response.should be_success
      assigns(:rss_source).should be_present
    end
  end

  describe 'POST :create' do
    it 'RssSourceを登録できる' do
      expect {
        post :create, rss_source: attributes_for(:rss_source)
      }.to change(RssSource, :count).by(1)
    end

    it 'パラメータが不正だと登録されない' do
      expect {
        post :create, rss_source: attributes_for(:rss_source).except(:title)
      }.to_not change(RssSource, :count)
      response.should render_template(:new)
    end
  end
end
