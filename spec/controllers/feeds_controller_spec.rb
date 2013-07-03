require 'spec_helper'

describe FeedsController do
  let!(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET :new' do
    it 'Feedの情報をURLからロードできる' do
      mock_rss!

      get :new, url: mock_rss_url

      response.should be_success
      assigns(:feed).should be_present
    end
  end

  describe 'POST :create' do
    it 'Feedを登録できる' do
      expect {
        post :create, feed: attributes_for(:feed)
      }.to change(Feed, :count).by(1)
    end

    it 'パラメータが不正だと登録されない' do
      expect {
        post :create, feed: attributes_for(:feed).except(:title)
      }.to_not change(Feed, :count)
      response.should render_template(:new)
    end
  end

  describe 'PUT :update_all' do
    it '全Feedを再読み込みできる' do
      @count = 0
      2.times { create(:feed, user: user) }
      Feed.any_instance.stub(:load!){ @count += 1 }
      put :update_all
      @count.should == 2
      response.should redirect_to(root_url)
    end
  end

  describe 'POST :import' do
    let!(:opml_file) do
      file = Tempfile.new('opml')
      file.write(opml_data)
      file.rewind
      Rack::Test::UploadedFile.new(file.path, 'application/xml')
    end
    after { opml_file.close! }

    it 'OPMLをアップロードしてインポートできる' do
      expect {
        mock_opml_rss!
        post :import, file: Rack::Test::UploadedFile.new(opml_file, 'application/xml')
      }.to change(Feed, :count).by(2)

      response.should redirect_to(root_url)
    end

    it 'アップロードするファイルを選択しないとflashメッセージを表示' do
      post :import
      flash[:alert].should == 'Select OPML file.'
      response.should redirect_to(upload_feeds_path)
    end
  end
end
