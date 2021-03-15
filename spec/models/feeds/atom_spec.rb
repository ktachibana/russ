# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Feeds::Atom, type: :model do
  describe '.new' do
    subject(:feed) { described_class.new(doc) }

    let(:doc) { RSS::Parser.parse(source) }
    let(:source) { rss_data_atom }

    it 'RSSパーサーの実装を隠して必要な値を取得できる' do
      expect(feed.title).to eq('Riding Rails')
      expect(feed.link).to eq('http://weblog.rubyonrails.org/')
      expect(feed.description).to eq('Sub Title')
      expect(feed.items.count).to eq(1)

      item = feed.items.first
      expect(item.title).to eq('Rails 3.2.20, 4.0.11, 4.1.7, and 4.2.0.beta3 have been released')
      expect(item.link).to eq('http://weblog.rubyonrails.org/2014/10/30/Rails_3_2_20_4_0_11_4_1_7_and_4_2_0_beta3_have_been_released/')
      expect(item.guid).to eq('http://weblog.rubyonrails.org/2014/10/30/Rails_3_2_20_4_0_11_4_1_7_and_4_2_0_beta3_have_been_released/')
      expect(item.date).to eq(Time.utc(2014, 10, 30, 18, 16, 55))
      expect(item.description).to eq('Content 1')
    end

    it 'item.dateの値がto_s(:db)できる' do
      # rss gemの中で定義している Time#w3cdtf が #to_s のaliasになっており、
      # ActiveSupportのto_s(:db)を受け入れなくなっている
      feed.items.first.date.to_s(:db)
    end

    context 'alternate linkがない' do
      context 'かつ、他のタイプのlinkもない'
    end
  end
end
