require 'spec_helper'

describe Feed do
  describe 'validations' do
    it { should validate_presence_of(:url) }
    it { should ensure_length_of(:url).is_at_most(2048) }

    it { should validate_presence_of(:title) }
    it { should ensure_length_of(:title).is_at_most(255) }

    it { should ensure_length_of(:link_url).is_at_most(2048) }

    it { should ensure_length_of(:description).is_at_most(4096) }
  end

  describe 'associations' do
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:tags) }
    it { should have_many(:subscriptions).dependent(:destroy) }
  end

  describe '.acts_as_tagging_on' do
    let(:feed) { create(:feed) }

    it '一括して追加できる' do
      feed.update_attributes!(tag_list: %w(tag1 tag2))
      feed.tags.map(&:name).should == %w(tag1 tag2)
    end

    it '削除できる' do
      feed.update_attributes!(tag_list: %w(tag1 tag2))
      ActsAsTaggableOn::Tag.pluck(:name).should == %w(tag1 tag2)

      feed.reload
      feed.update_attributes!(tag_list: %w(tag1 tag3))
      feed.tags.map(&:name).should == %w(tag1 tag3)
      ActsAsTaggableOn::Tagging.count.should == 2
    end

    it 'フィードとタグを一括して登録できる' do
      feed = Feed.create(attributes_for(:feed, tag_list: 'tagname'))
      feed.tag_list.should == %w(tagname)
      Feed.count.should == 1
      ActsAsTaggableOn::Tagging.count.should == 1
    end
  end

  describe '.search' do
    describe '.by_tag_id' do
      it '特定のタグのついたものだけに絞り込む' do
        feeds = ['tag1', 'tag1, tag2', []].map do |tags|
          create(:feed, tag_list: tags)
        end
        Feed.search(tag: %w(tag1)).should =~ feeds.values_at(0, 1)
        Feed.search(tag: %w(tag1 tag2)).should =~ feeds.values_at(1)
        Feed.search(tag: %w(tag2 tag1)).should =~ feeds.values_at(1)
      end
    end
  end

  describe '#load!' do
    before do
      WebMock.stub_request(:get, 'http://test.com/rss.xml').to_return(body: rss_data_one_item)
    end

    let!(:feed) do
      Feed.new(url: 'http://test.com/rss.xml').tap(&:load!)
    end

    it 'RSSからアイテムを読み込む' do
      feed.title.should == 'RSS Title'
      feed.url.should == 'http://test.com/rss.xml'
      feed.link_url.should == 'http://test.com/content'
      feed.description.should == 'My description'

      feed.should have(1).item
      item = feed.items.first
      item.title.should == 'Item Title'
      item.link.should == 'http://test.com/content/1'
      item.guid.should == '1'
      item.published_at.should == Time.new(2012, 2, 20, 16, 4, 19)
      item.description == 'Item description'
    end

    it '再度loadすると既存のものは更新になる' do
      feed.save!
      WebMock.stub_request(:get, 'http://test.com/rss.xml').to_return(body: rss_data_two_items)
      feed.load!

      feed.title.should == 'New Title'
      feed.description.should == 'New description'
      feed.link_url.should == 'http://test.com/new-content'
      feed.should be_changed

      feed.should have(2).items
      feed.items[0].tap do |item|
        item.title.should == 'New Title'
        item.link.should == 'http://test.com/content/2'
        item.published_at.should == Time.new(2012, 2, 22, 18, 24, 29)
        item.description == 'New item description'
      end
      feed.items[1].tap do |item|
        item.title.should == 'Item Title'
        item.link.should == 'http://test.com/content/3'
        item.published_at.should == Time.new(2012, 2, 20, 16, 4, 19)
        item.description == 'Item description'
      end
    end

    it 'guidが無い時はlinkで重複を判断する' do
      feed.save!
      WebMock.stub_request(:get, 'http://test.com/rss.xml').to_return(body: <<-EOS)
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
      feed.should have(2).items
      feed.items[0].tap do |item|
        item.link.should == 'http://test.com/content/2'
        item.description == 'New item description'
      end
      feed.items[1].tap do |item|
        item.link.should == 'http://test.com/content/1'
        item.description == 'Item description UPDATED'
      end
    end

    it 'エラーが起きたときはログを出力する' do
      Feed.stub(:load_rss).and_raise('error!')
      Rails.logger.should_receive(:error).with { |e| e.message.should == 'error!' }
      feed.load!
    end
  end

  describe '.load_all!' do
    before { Feed.stub(:sleep) }
    let!(:feed) do
      WebMock.stub_request(:get, mock_rss_url).to_return(body: rss_data_one_item)
      Feed.new(url: mock_rss_url).tap(&:load!).tap(&:save!)
    end

    it 'すべてのFeedを更新する' do
      WebMock.stub_request(:get, mock_rss_url).to_return(body: rss_data_two_items)
      expect {
        Feed.load_all!
      }.to change(Item, :count).from(1).to(2)
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

  describe '.import' do
    it 'OPML形式のファイルからRSSをインポートできる' do
      opml = <<-'EOS'
<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0">
    <head>
        <title>My Feed</title>
    </head>
    <body>
        <outline text="MyText" title="MyTitle" type="rss" xmlUrl="http://test.com/rss.xml" htmlUrl="http://test.com/content"/>
        <outline title="category title" text="category">
            <outline title="Title" type="rss" xmlUrl="http://category.com/rss.xml" htmlUrl="http://category.com/"/>
        </outline>
    </body>
</opml>
      EOS
      result = Feed.import!(create(:user), opml)
      result[0].tap do |subscription|
        subscription.feed.title.should == 'MyText'
        subscription.feed.url.should == 'http://test.com/rss.xml'
        subscription.feed.link_url.should == 'http://test.com/content'
        subscription.feed.description.should be_nil
      end
      result[1].tap do |subscription|
        subscription.feed.title.should == 'Title'
        subscription.feed.url.should == 'http://category.com/rss.xml'
        subscription.feed.link_url.should == 'http://category.com/'
        subscription.feed.description.should be_nil
        subscription.should have(1).tag
        subscription.tag_list.should == %w(category)
      end
    end
  end
end
