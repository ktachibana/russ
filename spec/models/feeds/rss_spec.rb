# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Feeds::Rss, type: :model do
  describe '.new' do
    subject(:feed) { described_class.new(doc) }

    let(:doc) { RSS::Parser.parse(source) }
    let(:source) { rss_data_one_item }

    it 'RSSパーサーの実装を隠して必要な値を取得できる' do
      expect(feed.title).to eq('RSS Title')
      expect(feed.description).to eq('My description')
      expect(feed.link).to eq('http://test.com/content')
      expect(feed.items.count).to eq(1)

      item = feed.items.first
      expect(item.title).to eq('Item Title')
      expect(item.link).to eq('http://test.com/content/1')
      expect(item.guid).to eq('1')
      expect(item.date).to eq('Mon, 20 Feb 2012 16:04:19 +0900')
      expect(item.description).to eq('Item description')
    end

    context 'itemにguidがない'
  end
end
