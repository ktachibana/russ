require 'spec_helper'

describe FeedsController do
  let!(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET :index' do
    render_views

    it 'Feed一覧を取得する' do
      feeds = create_list(:feed, 2, user: user)
      create(:feed, user: create(:user))
      get :index
      response.should be_success
      assigns(:feeds).should =~ feeds
    end
  end

  describe 'GET :new' do
    it 'Feedの情報をURLからロードできる' do
      mock_rss!

      get :new, url: mock_rss_url

      response.should be_success
      assigns(:feed).should be_present
    end
  end

  describe 'GET :show' do
    let(:feed) { create(:feed, user: user) }

    it 'Feedを表示できる' do
      get :show, id: feed.id
      assigns(:feed).should == feed
    end
  end

  describe 'POST :create' do
    it 'Feedを登録できる' do
      expect {
        Feed.any_instance.should_receive(:load!)
        post :create, feed: attributes_for(:feed)
      }.to change(Feed, :count).by(1)
    end

    it 'パラメータが不正だと登録されない' do
      expect {
        post :create, feed: attributes_for(:feed).except(:title)
      }.to_not change(Feed, :count)
      response.should render_template(:new)
    end

    it 'tag_idがblankの場合は無視される' do
      tag = create(:tag, user: user)
      Feed.any_instance.should_receive(:load!)
      post :create, feed: attributes_for(:feed, taggings_attributes: [{ tag_id: '' }, { tag_id: tag.id }])
      response.should redirect_to(root_url)
      assigns(:feed).reload.tags.should == [tag]
    end
  end

  describe 'POST :update' do
    let(:feed) { create(:feed, user: user) }
    let(:tag) { create(:tag, user: user) }

    it 'Feedを更新できる' do
      put :update, id: feed.id, feed: { title: 'NewTitle', taggings_attributes: { '0' => { tag_id: tag.id } } }
      feed.reload
      feed.title.should == 'NewTitle'
      feed.tags.should == [tag]
    end

    it 'Feedを削除できる' do
      feed.update_attributes!(tags: [tag])
      put :update, id: feed.id, feed: { taggings_attributes: { '0' => { id: feed.taggings.first.id, tag_id: '' } } }
      feed.reload
      feed.tags.should == []
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
