# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CrawlersController, type: :controller do
  describe '#create' do
    def action
      post :create, params: params
    end

    let(:params) { { key: Rails.application.credentials.crawler_key } }

    let!(:feed) do
      create(:feed).tap do |feed|
        mock_url!(url: feed.url, body: rss_data_one_item)
      end
    end

    it 'Feedの更新処理を実行する' do
      action
      expect(feed.reload.items).to be_present
    end

    context 'keyパラメータが不正なとき' do
      let(:params) { super().merge(key: 'wrong') }

      it '更新処理を実行せず403 Forbiddenを返す' do
        action
        is_expected.to respond_with(403)
        expect(feed.reload.items).to be_empty
      end
    end
  end
end
