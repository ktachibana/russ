require 'spec_helper'

describe Feed do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to ensure_length_of(:url).is_at_most(2048) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to ensure_length_of(:title).is_at_most(255) }

    it { is_expected.to ensure_length_of(:link_url).is_at_most(2048) }

    it { is_expected.to ensure_length_of(:description).is_at_most(4096) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:items).dependent(:destroy) }
    it { is_expected.to have_many(:tags) }
    it { is_expected.to have_many(:subscriptions).dependent(:destroy) }
  end

  describe '.acts_as_tagging_on' do
    let(:feed) { create(:feed) }

    it '一括して追加できる' do
      feed.update_attributes!(tag_list: %w(tag1 tag2))
      expect(feed.tags.map(&:name)).to eq(%w(tag1 tag2))
    end

    it '削除できる' do
      feed.update_attributes!(tag_list: %w(tag1 tag2))
      expect(ActsAsTaggableOn::Tag.pluck(:name)).to eq(%w(tag1 tag2))

      feed.reload
      feed.update_attributes!(tag_list: %w(tag1 tag3))
      expect(feed.tags.map(&:name)).to eq(%w(tag1 tag3))
      expect(ActsAsTaggableOn::Tagging.count).to eq(2)
    end

    it 'フィードとタグを一括して登録できる' do
      feed = Feed.create(attributes_for(:feed, tag_list: 'tagname'))
      expect(feed.tag_list).to eq(%w(tagname))
      expect(Feed.count).to eq(1)
      expect(ActsAsTaggableOn::Tagging.count).to eq(1)
    end
  end

  describe '.search' do
    describe '.by_tag_id' do
      it '特定のタグのついたものだけに絞り込む' do
        feeds = ['tag1', 'tag1, tag2', []].map do |tags|
          create(:feed, tag_list: tags)
        end
        expect(Feed.search(tag: %w(tag1))).to match_array(feeds.values_at(0, 1))
        expect(Feed.search(tag: %w(tag1 tag2))).to match_array(feeds.values_at(1))
        expect(Feed.search(tag: %w(tag2 tag1))).to match_array(feeds.values_at(1))
      end
    end
  end

  describe '#load!' do
    before { mock_rss!(url: feed.url, body: rss_data) }
    let(:feed) { build(:feed_only_url) }
    let(:rss_data) { rss_data_one_item }

    it 'RSSからアイテムを読み込む' do
      expect { feed.load! }.not_to change(feed, :url)
      expect(feed.title).to eq('RSS Title')
      expect(feed.link_url).to eq('http://test.com/content')
      expect(feed.description).to eq('My description')

      expect(feed.items.size).to eq(1)
      item = feed.items.first
      expect(item.title).to eq('Item Title')
      expect(item.link).to eq('http://test.com/content/1')
      expect(item.guid).to eq('1')
      expect(item.published_at).to eq(Time.new(2012, 2, 20, 16, 4, 19))
      expect(item.description).to eq('Item description')
    end

    context 'すでに一度load!して保存してあるとき' do
      before do
        feed.load!
        feed.save!
      end

      it '再度load!すると既存のFeedが更新される' do
        mock_rss!(url: feed.url, body: rss_data_two_items)
        feed.load!

        expect(feed.title).to eq('New Title')
        expect(feed.description).to eq('New description')
        expect(feed.link_url).to eq('http://test.com/new-content')
        expect(feed).to be_changed

        expect(feed.items.size).to eq(2)
        feed.items[0].tap do |item|
          expect(item.title).to eq('New Title')
          expect(item.link).to eq('http://test.com/content/2')
          expect(item.published_at).to eq(Time.new(2012, 2, 22, 18, 24, 29))
          item.description == 'New item description'
        end
        feed.items[1].tap do |item|
          expect(item.title).to eq('Item Title')
          expect(item.link).to eq('http://test.com/content/3')
          expect(item.published_at).to eq(Time.new(2012, 2, 20, 16, 4, 19))
          item.description == 'Item description'
        end
      end

      it 'guidが無い時はlinkで重複を判断する' do
        mock_rss!(url: feed.url, body: <<-EOS)
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>RSS Title</title>
    <link>http://test.com/content</link>
    <atom:link rel="self" type="application/rss+xml" href="http://test.com/rss.xml?rss=2.0"/>
    <description>My description</description>

    <item>
      <title>New Title</title>
      <link>http://test.com/content/2</link>
      <pubDate>Wed, 22 Feb 2012 18:24:29 +0900</pubDate>
      <description><![CDATA[New item description]]></description>
    </item>

    <item>
      <title>Item Title</title>
      <link>http://test.com/content/1</link>
      <pubDate>Mon, 20 Feb 2012 16:04:19 +0900</pubDate>
      <description><![CDATA[Item description UPDATED]]></description>
    </item>
  </channel>
</rss>
        EOS

        feed.load!
        feed.save!
        feed.reload
        expect(feed.items.size).to eq(2)
        feed.items[0].tap do |item|
          expect(item.link).to eq('http://test.com/content/2')
          item.description == 'New item description'
        end
        feed.items[1].tap do |item|
          expect(item.link).to eq('http://test.com/content/1')
          item.description == 'Item description UPDATED'
        end
      end
    end

    context 'Atom形式のとき' do
      let(:rss_data) { rss_data_atom }
      before { feed.load! }

      it 'Atomも読み込める' do
        expect(feed.title).to eq('Riding Rails')
        expect(feed.link_url).to eq('http://weblog.rubyonrails.org/')
        expect(feed.description).to eq(nil)

        expect(feed.items.size).to eq(1)

        item = feed.items[0]
        expect(item.title).to eq('Rails 3.2.20, 4.0.11, 4.1.7, and 4.2.0.beta3 have been released')
        expect(item.link).to eq('http://weblog.rubyonrails.org/2014/10/30/Rails_3_2_20_4_0_11_4_1_7_and_4_2_0_beta3_have_been_released/')
        expect(item.guid).to eq('http://weblog.rubyonrails.org/2014/10/30/Rails_3_2_20_4_0_11_4_1_7_and_4_2_0_beta3_have_been_released/')
        expect(item.published_at).to eq(Time.utc(2014, 10, 30, 18, 16, 55))
        expect(item.description).to eq('Content 1')
      end

      context 'すでに一度load!して保存してあるとき' do
        before do
          feed.save!

          mock_rss!(url: feed.url, body: rss_data_atom_two_items)
          feed.load!
        end

        it '再度load!すると既存のFeedが更新される' do
          expect(feed.title).to eq('New Title')
          expect(feed.link_url).to eq('http://weblog.rubyonrails.org/new')
          expect(feed).to be_changed

          expect(feed.items.size).to eq(2)

          items = feed.items.sort_by(&:published_at).reverse
          items[0].tap do |item|
            expect(item.title).to eq('[ANN] Rails 4.2.0.beta4 has been released!')
            expect(item.link).to eq('http://weblog.rubyonrails.org/2014/10/30/Rails-4-2-0-beta4-has-been-released/')
            expect(item.guid).to eq('http://weblog.rubyonrails.org/2014/10/30/Rails-4-2-0-beta4-has-been-released/')
            expect(item.published_at).to eq(Time.utc(2014, 10, 30, 22, 00, 00))
            expect(item.description).to eq('Content 2')
          end
          items[1].tap do |item|
            expect(item.title).to eq('Rails 3.2.20, 4.0.11, 4.1.7, and 4.2.0.beta3 have been released')
            expect(item.link).to eq('http://weblog.rubyonrails.org/2014/10/30/Rails_3_2_20_4_0_11_4_1_7_and_4_2_0_beta3_have_been_released/')
            expect(item.guid).to eq('http://weblog.rubyonrails.org/2014/10/30/Rails_3_2_20_4_0_11_4_1_7_and_4_2_0_beta3_have_been_released/')
            expect(item.published_at).to eq(Time.utc(2014, 10, 30, 18, 16, 55))
            expect(item.description).to eq('Content 1')
          end
        end
      end
    end

    it 'エラーが起きたときはログを出力する' do
      allow(Feed).to receive(:load_rss).and_raise('error!')
      expect(Rails.logger).to receive(:error).with(satisfy { |e| expect(e).to include('error!') })
      feed.load!
    end
  end

  describe '.load_all!' do
    before { allow(Feed).to receive(:sleep) }
    let!(:feed) do
      WebMock.stub_request(:get, mock_rss_url).to_return(body: rss_data_one_item)
      Feed.new(url: mock_rss_url).tap(&:load!).tap(&:save!)
    end

    it 'すべてのFeedを更新する' do
      WebMock.stub_request(:get, mock_rss_url).to_return(body: rss_data_two_items)
      expect do
        Feed.load_all!
      end.to change(Item, :count).from(1).to(2)
    end
  end

  describe '#to_item_attributes' do
    subject { feed.to_item_attributes(item) }
    let(:feed) { build(:feed) }
    let(:item) { build(:parsed_item) }

    it 'parseされたフィードの項目からItemの属性を取得する' do
      expect(subject[:link]).to eq item.link
      expect(subject[:title]).to eq item.title
      expect(subject[:published_at]).to eq item.date
      expect(subject[:description]).to eq item.description
    end

    # 遠い未来の日付が設定されていて、ソートでずっとトップに居座る項目が作られたことがあるため
    context 'dateが未来のとき' do
      before { Timecop.freeze }
      let(:item) { build(:parsed_item, date: 1.days.from_now) }

      it 'published_atは現在時刻になる' do
        expect(subject[:published_at]).to eq Time.current
      end
    end

    context 'dateがnilのとき' do
      let(:item) { build(:parsed_item, date: nil) }

      it 'published_atはnilになる' do
        expect(subject[:published_at]).to be nil
      end
    end
  end
end
