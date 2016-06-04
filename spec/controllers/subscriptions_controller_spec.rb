require 'spec_helper'

RSpec.describe SubscriptionsController, type: :controller do
  let!(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET :show' do
    render_views
    def action
      get :show, id: subscription.id, format: :json
    end
    let(:subscription) { create(:subscription, :with_title, user: user, tag_list: %w(foo bar)) }

    it 'Subscriptionの情報を取得できる' do
      action
      is_expected.to respond_with(:ok)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data).to be_a(Hash)
      expect(data[:title]).to eq(subscription.title)
    end

    context 'itemsが大量にあるとき' do
      let(:subscription) { create(:subscription, user: user, feed: feed) }
      let(:feed) { create(:feed, item_count: 26) }

      it '取得件数が制限される' do
        action
        data = JSON.parse(response.body, symbolize_names: true)
        expect(data[:feed][:items].size).to eq(25)
        expect(data[:lastPage]).to be false
      end
    end
  end

  describe 'GET :new' do
    render_views

    def action
      get :new, url: url, format: format
    end
    let(:url) { mock_rss_url }
    let(:format) { :json }

    it 'Feedの情報をURLからロードできる' do
      mock_rss!(body: rss_data_one_item)
      action

      is_expected.to respond_with(:ok)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data).to be_a(Hash)
      expect(data[:url]).to eq(mock_rss_url)
      expect(data[:title]).to eq('RSS Title')
      expect(data[:linkUrl]).to eq('http://test.com/content')
      expect(data[:description]).to eq('My description')

      items = data[:items]
      expect(items.length).to eq(1)

      item = items[0]
      expect(item[:title]).to eq('Item Title')
      expect(item[:link]).to eq('http://test.com/content/1')
      expect(item[:guid]).to eq('1')
      expect(Time.parse(item[:publishedAt])).to eq(Time.parse('Mon, 20 Feb 2012 16:04:19 +0900').utc)
      expect(item[:description]).to eq('Item description')
    end

    context '登録済みのフィードを指定したとき' do
      let!(:subscription) { create(:subscription, user: user, feed: feed) }
      let(:feed) { create(:feed, url: mock_rss_url) }

      it '登録済みのフィードのURLを指定するとリダイレクト' do
        action
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq(I18n.t('messages.feed_already_registed', url: mock_rss_url))
      end

      it '再読み込みはしない' do
        bypass_rescue
        WebMock.stub_request(:get, mock_rss_url).to_raise('test fail')
        expect { action }.not_to raise_error
      end
    end

    context 'bookmarkletから呼び出されたとき' do
      let(:format) { :html }

      it 'フィード登録ページにリダイレクトする' do
        mock_rss!(url: url, body: rss_data, content_type: 'application/rss+xml')
        action
        is_expected.to redirect_to(root_path(anchor: '/subscriptions/new/' + Base64.strict_encode64(url)))
      end

      context 'RSSへのリンクを持つHTMLページのとき' do
        let(:url) { 'http://test.com/index.html' }
        let(:html) do
          <<-HTML
<html>
<head>
<link rel="alternate" type="application/rss+xml" href="http://test.com/rss.xml"/>
</head>
</html>
          HTML
        end

        it 'HTMLからRSSを自動で探し出す' do
          mock_url!(url: url, body: html, content_type: 'text/html')
          mock_url!(url: mock_rss_url, body: rss_data, content_type: 'application.rss+xml')
          action
          is_expected.to redirect_to(root_path(anchor: '/subscriptions/new/' + Base64.strict_encode64(mock_rss_url)))
        end
      end

      context 'RSSへのリンクがないHTMLページのとき' do
        let(:url) { 'http://test.com/index.html' }
        let(:html) { '<html></html>' }

        it 'エラーメッセージをflashで表示する' do
          mock_url!(url: url, body: html, content_type: 'text/html')
          action
          is_expected.to redirect_to(root_path)
          expect(flash[:alert]).to eq(I18n.t('messages.feed_not_found'))
        end
      end
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
      expect(JSON.parse(response.body)).to eq('id' => Subscription.last.id)
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
      let(:subscription_params) { super().merge(tag_list: 'tag1, tag2') }

      it 'タグを登録できる' do
        action
        expect(assigns(:subscription).reload.tag_list).to match_array(%w(tag1 tag2))
      end
    end
  end

  describe 'PATCH :update' do
    def action
      put :update, id: subscription.id, subscription: subscription_params
    end
    let(:subscription_params) { { title: 'NewTitle', tag_list: 'tag1, tag2' } }
    let(:subscription) { create(:subscription, user: user) }

    it 'Subscriptionを更新できる' do
      action
      subscription.reload
      expect(subscription.title).to eq('NewTitle')
      expect(subscription.tag_list).to eq(%w(tag1 tag2))
    end

    context 'tag_listの値を削除したとき' do
      let(:subscription) { create(:subscription, user: user, tag_list: %w(tag1 tag2)) }
      let(:subscription_params) { { tag_list: 'tag1' } }

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
        expect(JSON.parse(response.body)).to eq('id' => subscription.id)
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
    def action
      delete :destroy, id: subscription.id, format: :json
    end
    let!(:subscription) { create(:subscription, user: user) }

    it 'Subscriptionを削除できる' do
      expect { action }.to change(Subscription, :count).by(-1)
    end

    it 'JSONでOKを返す' do
      action
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(status: 'OK')
    end
  end
end
