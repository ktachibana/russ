require 'spec_helper'

describe RssSourcesController do
  let!(:user) { create(:user) }
  before { sign_in(user) }

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

  describe 'PUT :update_all' do
    it '全RssSourceを再読み込みできる' do
      @count = 0
      2.times { create(:rss_source, user: user) }
      RssSource.any_instance.stub(:load!){ @count += 1 }
      put :update_all
      @count.should == 2
      response.should redirect_to(root_url)
    end
  end
end
