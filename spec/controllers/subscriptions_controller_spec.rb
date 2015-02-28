require 'spec_helper'

describe SubscriptionsController, type: :controller do
  let!(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET :new' do
    render_views

    it 'Feedの情報をURLからロードできる' do
      mock_rss!

      get :new, url: mock_rss_url

      expect(response).to be_success
      subscription = assigns(:subscription)
      expect(subscription).to be_present
      expect(subscription.feed.title).to eq('RSS Title')
    end

    it '登録済みのフィードのURLを指定するとリダイレクト' do
      subscription = create(:subscription, user: user, feed: create(:feed, url: mock_rss_url))
      get :new, url: mock_rss_url
      expect(response).to redirect_to(feed_path(subscription.feed))
      expect(flash[:notice]).to eq(I18n.t('messages.feed_already_registed', url: mock_rss_url))
    end

    it '既存のフィードのURLを指定したときは再読み込みはしない' do
      feed = create(:feed)
      WebMock.stub_request(:get, feed.url).to_raise('test fail')
      get :new, url: feed.url
      expect(response).to be_success
    end
  end

  describe 'POST :create' do
    def action
      post :create, subscription: subscription_params, format: :json
    end
    let(:subscription_params) { { title: '', tag_list: '', feed_attributes: { url: mock_rss_url } } }
    before { mock_rss! }

    it 'Subscriptionを登録できる' do
      expect { action }.to change(Subscription, :count).by(1)
      is_expected.to respond_with(:ok)
    end

    context 'パラメータが不正なとき' do
      let(:subscription_params) { super().merge(title: 'a' * 256) }

      it '登録されない' do
        expect { action }.to_not change(Subscription, :count)
      end

      it 'バリデーションエラーを返す' do
        action
        is_expected.to respond_with(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('type' => 'validation')
      end
    end

    context 'タグをあたえたとき' do
      let(:subscription_params) { super().merge(tag_list: %w(tag1 tag2)) }

      it 'タグを登録できる' do
        action
        expect(assigns(:subscription).reload.tag_list).to match_array(%w(tag1 tag2))
      end
    end
  end

  describe 'POST :update' do
    def action
      put :update, id: subscription.id, subscription: subscription_params
    end
    let(:subscription_params) { { title: 'NewTitle', tag_list: %w(tag1 tag2) } }
    let(:subscription) { create(:subscription, user: user) }

    it 'Subscriptionを更新できる' do
      action
      subscription.reload
      expect(subscription.title).to eq('NewTitle')
      expect(subscription.tag_list).to eq(%w(tag1 tag2))
    end

    context 'tag_listの値を削除したとき' do
      let(:subscription) { create(:subscription, user: user, tag_list: %w(tag1 tag2)) }
      let(:subscription_params) { { tag_list: %w(tag1) } }

      it 'タグを削除できる' do
        action
        subscription.reload
        expect(subscription.tag_list).to eq(%w(tag1))
        expect(ActsAsTaggableOn::Tagging.count).to eq(1)
      end
    end

    context 'URLを与えたとき' do
      let(:subscription_params) { { feed_attributes: { url: 'http://new.com/rss.xml' } } }

      it 'フィードのURLは変更できない' do
        expect { action }.not_to change { subscription.reload.feed.url }
      end
    end

    context 'accept_typeをjsonにしたとき' do
      before { request.accept = 'application/json' }

      it 'jsonでレスポンスする' do
        action
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)).to eq('status' => 'OK')
      end
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
      expect do
        mock_opml_rss!
        post :import, file: Rack::Test::UploadedFile.new(opml_file, 'application/xml')
      end.to change(Feed, :count).by(2)

      expect(response).to redirect_to(root_url)
    end

    it 'アップロードするファイルを選択しないとflashメッセージを表示' do
      post :import
      expect(flash[:alert]).to eq('Select OPML file.')
      expect(response).to redirect_to(upload_subscriptions_path)
    end
  end

  describe '#destroy' do
    let!(:subscription) { create(:subscription, user: user) }

    it 'Subscriptionを削除できる' do
      expect do
        delete :destroy, id: subscription.id
      end.to change(Subscription, :count).by(-1)
    end

    it 'Feed一覧にリダイレクトする' do
      delete :destroy, id: subscription.id
      expect(response).to redirect_to(feeds_path)
    end
  end
end
