# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Feed, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to validate_length_of(:url).is_at_most(2048) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(255) }

    it { is_expected.to validate_length_of(:link_url).is_at_most(2048) }

    it { is_expected.to validate_length_of(:description).is_at_most(4096) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:items).dependent(:destroy) }
    it { is_expected.to have_many(:subscriptions).dependent(:destroy) }
  end

  describe '#load!' do
    let!(:mock_request) { mock_rss!(url: feed.url, body: rss_data) }

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
      expect(item.published_at).to eq(Time.find_zone!(9).local(2012, 2, 20, 16, 4, 19))
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
          expect(item.published_at).to eq(Time.find_zone!(9).local(2012, 2, 22, 18, 24, 29))
          expect(item.description).to eq('New item description')
        end
        feed.items[1].tap do |item|
          expect(item.title).to eq('Item Title')
          expect(item.link).to eq('http://test.com/content/3')
          expect(item.published_at).to eq(Time.find_zone!(9).local(2012, 2, 20, 16, 4, 19))
          expect(item.description).to eq('Item description')
        end
      end

      it 'guidが無い時はlinkで重複を判断する' do
        mock_rss!(url: feed.url, body: <<~XML)
          <?xml version="1.0" encoding="utf-8"?>
          <rss version="2.0">
            <channel>
              <title>RSS Title</title>
              <link>http://test.com/content</link>
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
        XML

        feed.load!
        feed.save!
        feed.reload
        expect(feed.items.size).to eq(2)
        feed.items[0].tap do |item|
          expect(item.link).to eq('http://test.com/content/2')
          expect(item.description).to eq('New item description')
        end
        feed.items[1].tap do |item|
          expect(item.link).to eq('http://test.com/content/1')
          expect(item.description).to eq('Item description UPDATED')
        end
      end
    end

    context 'link_urlにホスト名が含まれないとき' do
      let(:rss_data) { rss_data_relative_link }
      let(:feed) { build(:feed_only_url, url: 'http://test.com/rss.xml') }

      it 'urlからの相対URLとして解決する' do
        feed.load!
        expect(feed.link_url).to eq('http://test.com/site/mypage')
        expect(feed.items[0].link).to eq('http://test.com/content/1')
      end
    end

    context 'Atom形式のとき' do
      let(:rss_data) { rss_data_atom }

      before { feed.load! }

      it 'Atomも読み込める' do
        expect(feed.title).to eq('Riding Rails')
        expect(feed.link_url).to eq('http://weblog.rubyonrails.org/')
        expect(feed.description).to eq('Sub Title')

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
            expect(item.published_at).to eq(Time.utc(2014, 10, 30, 22, 0o0, 0o0))
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

    context 'RSSをロードしようとしてエラーになるとき' do
      before { allow(described_class).to receive(:load_source).and_raise('error!') }

      it 'エラーになるFeedばかり最初に更新されないようloaded_atだけは設定する' do
        feed.load!
        expect(feed.loaded_at).to be_present
      end

      it 'ログを出力する', :stub_logging do
        feed.load!
        expect(log_string).to include('error!', feed.url)
      end
    end

    context 'リダイレクトが返ってきたとき' do
      let!(:mock_request) do
        WebMock.stub_request(:get, feed.url).to_return(status: 302, headers: { location: mock_url! })
      end

      it 'リダイレクト先からロードする' do
        feed.load!
        expect(feed.title).to eq('RSS Title')
      end
    end
  end

  describe '.load_all!' do
    before { allow(described_class).to receive(:sleep) }

    it 'すべてのFeedを更新する' do
      WebMock.stub_request(:get, mock_rss_url).to_return(body: rss_data_one_item)
      described_class.new(url: mock_rss_url).tap(&:load!).tap(&:save!)

      WebMock.stub_request(:get, mock_rss_url).to_return(body: rss_data_two_items)
      expect do
        described_class.load_all!
      end.to change(Item, :count).from(1).to(2)
    end

    it 'loaded_atが古い順に更新し、timeout:の時間を過ぎたら中断する' do
      now = Time.current.change(nsec: 0)
      travel_to now

      feeds = [3, 1, 2].map { |n| create(:feed, item_count: 1, loaded_at: now - n.days).reload }
      feeds.each do |feed|
        WebMock.stub_request(:get, feed.url).to_return(body: rss_data_one_item)
      end

      described_class.load_all!(
        interval_seconds: 0,
        timeout: 5.seconds,
        before_feed: ->(_) { travel(2.seconds) }
      )

      feeds.each(&:reload)
      expect(feeds[0].loaded_at).to eq(now + 2.seconds)
      expect(feeds[1].loaded_at).to eq(now - 1.day)
      expect(feeds[2].loaded_at).to eq(now + 4.seconds)
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

    context 'dateがnilのとき' do
      let(:item) { build(:parsed_item, date: nil) }

      it 'published_atはnilになる' do
        expect(subject[:published_at]).to be nil
      end
    end
  end
end
