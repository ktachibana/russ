# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  let!(:user) { create(:user) }

  before { sign_in(user) }

  describe 'GET :show' do
    render_views
    def action
      get :show, params: { id: subscription.id, format: :json }
    end
    let(:subscription) { create(:subscription, :with_title, user: user, tag_list: %w[foo bar]) }

    it 'Subscriptionの情報を取得できる' do
      action
      is_expected.to respond_with(:ok)
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data).to be_a(Hash)
      expect(data[:title]).to eq(subscription.title)
      expect(data[:hideDefault]).to eq(subscription.hide_default?)
    end

    context 'itemsが大量にあるとき' do
      let(:subscription) { create(:subscription, user: user, feed: feed) }
      let(:feed) { create(:feed, item_count: 26) }

      it '取得件数が制限される' do
        action
        data = JSON.parse(response.body, symbolize_names: true)
        expect(data[:feed][:items].size).to eq(25)
        expect(data[:pagination]).to eq(perPage: 25, totalCount: 26)
      end
    end
  end

  describe 'GET :new' do
    render_views

    def action
      get :new, params: { url: url, format: :json }
    end
    let(:url) { mock_rss_url }

    it 'Feedの情報をURLからロードできる' do
      mock_rss!(body: rss_data_one_item)
      action

      is_expected.to respond_with(:ok)

      data = JSON.parse(response.body, symbolize_names: true)
      data[:feed].tap do |feed|
        expect(feed).to be_a(Hash)
        expect(feed[:id]).to be(nil)
        expect(feed[:url]).to eq(mock_rss_url)
        expect(feed[:title]).to eq('RSS Title')
        expect(feed[:linkUrl]).to eq('http://test.com/content')
        expect(feed[:description]).to eq('My description')

        feed[:items].tap do |items|
          expect(items.length).to eq(1)

          items[0].tap do |item|
            expect(item[:title]).to eq('Item Title')
            expect(item[:link]).to eq('http://test.com/content/1')
            expect(item[:guid]).to eq('1')
            expect(Time.zone.parse(item[:publishedAt])).to eq(Time.parse('Mon, 20 Feb 2012 16:04:19 +0900').utc)
            expect(item[:description]).to eq('Item description')
          end
        end
      end
    end

    context '登録済みのフィードのURLを指定したとき' do
      let!(:subscription) { create(:subscription, user: user, feed: feed) }
      let(:feed) { create(:feed, url: mock_rss_url) }

      it 'SubscriptionのIDをflashメッセージ付きで返す' do
        action
        expect(JSON.parse(response.body)).to eq('id' => subscription.id)
        flash_messages = JSON.parse(Rack::Utils.unescape(response.headers['X-Flash-Messages']))
        expect(flash_messages).to eq([['notice', I18n.t('messages.feed_already_registered', url: mock_rss_url)]])
      end

      it '再読み込みはしない' do
        bypass_rescue
        WebMock.stub_request(:get, mock_rss_url).to_raise('test fail')
        expect { action }.not_to raise_error
      end
    end

    context 'URLがRSSでないとき' do
      context 'RSSへのリンクを持つHTMLページのとき' do
        let(:url) { 'http://test.com/index.html' }
        let(:html) do
          <<~HTML
            <html>
            <head>
            <link rel="alternate" type="application/rss+xml" href="http://test.com/rss.xml"/>
            </head>
            </html>
          HTML
        end

        it 'HTMLからRSSを自動で探し出して読み込む' do
          mock_url!(url: url, body: html, content_type: 'text/html')
          mock_url!(url: mock_rss_url, body: rss_data, content_type: 'application.rss+xml')
          action

          data = JSON.parse(response.body, symbolize_names: true)
          feed = data[:feed]
          expect(feed[:id]).to be(nil)
          expect(feed[:url]).to eq(mock_rss_url)
          expect(feed[:title]).to eq('RSS Title')
        end
      end

      context 'RSSへのリンクがないHTMLページのとき' do
        let(:url) { 'http://test.com/index.html' }
        let(:html) { '<html></html>' }

        it 'エラーメッセージをflashで表示する' do
          mock_url!(url: url, body: html, content_type: 'text/html')
          action
          flash_messages = JSON.parse(Rack::Utils.unescape(response.headers['X-Flash-Messages']))
          expect(flash_messages).to eq([['alert', I18n.t('messages.feed_not_found')]])
        end
      end
    end
  end

  describe 'POST :create' do
    def action
      post :create, params: { subscription: subscription_params, format: :json }
    end
    let(:subscription_params) { { title: '', tag_list: '', hide_default: 'true', feed_attributes: { url: mock_rss_url } } }
    before { mock_rss! }

    it 'Subscriptionを登録できる' do
      expect { action }.to change(Subscription, :count).by(1)
      is_expected.to respond_with(:ok)

      parsed = JSON.parse(response.body)
      expect(parsed).to eq('id' => Subscription.last.id)
      expect(Subscription.find(parsed['id']).hide_default?).to be_truthy
    end

    context 'パラメータが不正なとき' do
      let(:bypass_rescue?) { false }
      let(:subscription_params) { super().merge(title: 'a' * 256) }

      it '登録されない' do
        expect { action }.not_to change(Subscription, :count)
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
        expect(assigns(:subscription).reload.tag_list).to match_array(%w[tag1 tag2])
      end
    end
  end

  describe 'PATCH :update' do
    def action
      put :update, params: { id: subscription.id, subscription: subscription_params, format: :json }
    end
    let(:subscription_params) { { title: 'NewTitle', tag_list: 'tag1, tag2', hide_default: 'true' } }
    let(:subscription) { create(:subscription, user: user, hide_default: false) }

    it 'Subscriptionを更新できる' do
      action
      subscription.reload
      expect(subscription.title).to eq('NewTitle')
      expect(subscription.tag_list).to match_array(%w[tag1 tag2])
      expect(subscription.hide_default).to be_truthy
    end

    context 'tag_listの値を削除したとき' do
      let(:subscription) { create(:subscription, user: user, tag_list: %w[tag1 tag2]) }
      let(:subscription_params) { { tag_list: 'tag1' } }

      it 'タグを削除できる' do
        action
        subscription.reload
        expect(subscription.tag_list).to eq(%w[tag1])
        expect(ActsAsTaggableOn::Tagging.count).to eq(1)
      end
    end

    context 'URLを与えたとき' do
      let(:subscription_params) { { feed_attributes: { url: 'http://new.com/rss.xml' } } }

      it 'フィードのURLは変更できない' do
        expect { action }.not_to change { subscription.reload.feed.url }
      end
    end
  end

  describe 'POST :import' do
    def action
      post :import, params: params
    end
    let(:params) { { file: upload_file } }
    let(:upload_file) { Rack::Test::UploadedFile.new(opml_file.path, 'application/xml') }
    let!(:opml_file) do
      file = Tempfile.new('opml')
      file.write(opml_data)
      file.rewind
      file
    end

    after { opml_file.close! }

    it 'OPMLをアップロードしてインポートできる' do
      expect do
        mock_opml_rss!
        action
      end.to change(Feed, :count).by(2)

      is_expected.to respond_with(:ok)
    end

    context 'アップロードするファイルを選択しなかったとき' do
      let(:params) { super().except(:file) }

      it 'エラーメッセージを返す' do
        action
        is_expected.to respond_with(:unprocessable_entity)
        expect(JSON.parse(response.body, symbolize_names: true)).to eq(error: 'Select OPML file.')
      end
    end

    context '不正なファイルを与えたとき' do
      let(:opml_data) { 'this is a invalid file.' }

      it 'エラーメッセージを返す' do
        action
        is_expected.to respond_with(:unprocessable_entity)
        expect(JSON.parse(response.body, symbolize_names: true)).to eq(error: 'Invalid file format.')
      end
    end
  end

  describe '#destroy' do
    def action
      delete :destroy, params: { id: subscription.id, format: :json }
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
