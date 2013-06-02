require 'spec_helper'

describe RssSource do
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
    it { should have_many(:tags).through(:taggings) }
  end

  describe '.by_url' do
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
      source = RssSource.by_url('http://test.com/rss.xml')
      source.title.should == 'RSS Title'
      source.url.should == 'http://test.com/rss.xml'
      source.link_url.should == 'http://test.com/content'
      source.description.should == 'My description'
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
      <pubDate>Mon, 20 Feb 2012 16:04:19 +0900</pubDate>
      <description><![CDATA[Item description]]></description>
    </item>
  </channel>
</rss>
      EOS
    end

    let!(:source) do
      source = RssSource.by_url('http://test.com/rss.xml')
      source.user = create(:user)
      source.save!
      source.load!
      source
    end

    it 'RSSからアイテムを読み込む' do
      source.should have(1).item
      item = source.items.first
      item.title.should == 'Item Title'
      item.link.should == 'http://test.com/content/1'
      item.published_at.should == Time.new(2012, 2, 20, 16, 4, 19)
      item.description == 'Item description'
    end

    it '再度loadすると既存のものは更新になる' do
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
      <description><![CDATA[Item description]]></description>
    </item>
  </channel>
</rss>
      EOS
      source.load!
      source.should have(2).items
      source.items.order(:published_at)[0].tap do |item|
        item.title.should == 'Item Title'
        item.link.should == 'http://test.com/content/1'
        item.published_at.should == Time.new(2012, 2, 20, 16, 4, 19)
        item.description == 'Item description'
      end
      source.items.order(:published_at)[1].tap do |item|
        item.title.should == 'New Title'
        item.link.should == 'http://test.com/content/2'
        item.published_at.should == Time.new(2012, 2, 22, 18, 24, 29)
        item.description == 'New item description'
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
      RssSource.import!(create(:user), opml)
      RssSource.find_by!(title: 'MyText').tap do |s|
        s.title.should == 'MyText'
        s.url.should == 'http://test.com/rss.xml'
        s.link_url.should == 'http://test.com/content'
        s.description.should be_nil
      end
      RssSource.find_by!(title: 'Title').tap do |s|
        s.title.should == 'Title'
        s.url.should == 'http://category.com/rss.xml'
        s.link_url.should == 'http://category.com/'
        s.tags.should have(1).tag
        s.tags[0].name.should == 'category'
        s.description.should be_nil
      end
    end
  end
end
