require 'spec_helper'

describe Feed do
  describe 'validations' do
    it { should validate_presence_of(:user_id) }

    it { should validate_presence_of(:url) }
    it { should ensure_length_of(:url).is_at_most(2048) }

    it { should validate_presence_of(:title) }
    it { should ensure_length_of(:title).is_at_most(255) }

    it { should ensure_length_of(:link_url).is_at_most(2048) }

    it { should ensure_length_of(:description).is_at_most(4096) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:tags) }
  end

  describe '.acts_as_tagging_on' do
    let(:user) { create(:user) }
    let(:feed) { create(:feed, user: user) }

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
      feed = Feed.create(attributes_for(:feed, user_id: user.id, tag_list: 'tagname'))
      feed.tag_list.should == %w(tagname)
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

  describe '.load_by_url' do
    it 'urlを指定するとそのRSSをロードしてnewする' do
      WebMock.stub_request(:get, 'http://test.com/rss.xml').to_return(body: <<-EOS)
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>RSS Title</title>
    <link>http://test.com/content</link>
    <atom:link rel="self" type="application/rss+xml" href="http://test.com/rss.xml?rss=2.0"/>
    <description>My description</description>
  </channel>
</rss>
      EOS
      feed = Feed.load_by_url('http://test.com/rss.xml')
      feed.title.should == 'RSS Title'
      feed.url.should == 'http://test.com/rss.xml'
      feed.link_url.should == 'http://test.com/content'
      feed.description.should == 'My description'
    end
  end

  describe '#load!' do
    before do
      WebMock.stub_request(:get, 'http://test.com/rss.xml').to_return(body: <<-EOS)
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>RSS Title</title>
    <link>http://test.com/content</link>
    <atom:link rel="self" type="application/rss+xml" href="http://test.com/rss.xml?rss=2.0"/>
    <description>My description</description>

    <item>
      <title>Item Title</title>
      <link>http://test.com/content/1</link>
      <guid>1</guid>
      <pubDate>Mon, 20 Feb 2012 16:04:19 +0900</pubDate>
      <description><![CDATA[Item description]]></description>
    </item>
  </channel>
</rss>
      EOS
    end

    let!(:feed) do
      feed = Feed.new(url: 'http://test.com/rss.xml')
      feed.user = create(:user)
      #feed.save!
      feed.load!
      feed
    end

    it 'RSSからアイテムを読み込む' do
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
      WebMock.stub_request(:get, 'http://test.com/rss.xml').to_return(body: <<-EOS)
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>New Title</title>
    <link>http://test.com/new-content</link>
    <atom:link rel="self" type="application/rss+xml" href="http://test.com/rss.xml?rss=2.0"/>
    <description>New description</description>

    <item>
      <title>New Title</title>
      <link>http://test.com/content/2</link>
      <guid>1</guid>
      <pubDate>Wed, 22 Feb 2012 18:24:29 +0900</pubDate>
      <description><![CDATA[New item description]]></description>
    </item>

    <item>
      <title>Item Title</title>
      <link>http://test.com/content/3</link>
      <guid>2</guid>
      <pubDate>Mon, 20 Feb 2012 16:04:19 +0900</pubDate>
      <description><![CDATA[Item description]]></description>
    </item>
  </channel>
</rss>
      EOS
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
      result[0].tap do |feed|
        feed.title.should == 'MyText'
        feed.url.should == 'http://test.com/rss.xml'
        feed.link_url.should == 'http://test.com/content'
        feed.description.should be_nil
      end
      result[1].tap do |feed|
        feed.title.should == 'Title'
        feed.url.should == 'http://category.com/rss.xml'
        feed.link_url.should == 'http://category.com/'
        feed.should have(1).tag
        feed.tag_list.should == %w(category)
        feed.description.should be_nil
      end
    end
  end
end
