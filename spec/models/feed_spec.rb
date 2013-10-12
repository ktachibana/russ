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
    it { should have_many(:tags).through(:taggings) }
  end

  describe '#taggings_attributes=' do
    let(:user) { create(:user) }
    let(:feed) { create(:feed, user: user) }

    it '一括して追加できる' do
      tags = create_list(:tag, 2, user: user)
      feed.update_attributes!(taggings_attributes: tags.map { |tag| { tag_id: tag.id } })
      feed.tags.should == tags
    end

    it '削除できる' do
      tags = create_list(:tag, 4, user: user)
      feed.update_attributes!(tags: tags[0..1])
      feed.tags.should == tags.values_at(0, 1)
      feed.reload
      feed.update_attributes!(taggings_attributes: [
          { id: feed.taggings.find_by(tag: tags[0]).id, tag_id: tags[0].id },
          { id: feed.taggings.find_by(tag: tags[1]).id, _destroy: true },
          { tag_id: tags[2].id },
          { tag_id: tags[3].id, _destroy: true }
      ])
      feed.tags.should == tags.values_at(0, 2)
      Tagging.should have(2).items
    end

    it 'フィードとタグを一括して登録できる' do
      tag = create(:tag, user: user)
      feed = Feed.create(attributes_for(:feed, user_id: user.id, taggings_attributes: [{ tag_id: tag.id }]))
      feed.tags.should == [tag]
    end
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
      feed = Feed.by_url('http://test.com/rss.xml')
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
      feed = Feed.by_url('http://test.com/rss.xml')
      feed.user = create(:user)
      feed.save!
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
      <guid>1</guid>
      <pubDate>Wed, 22 Feb 2012 18:24:29 +0900</pubDate>
      <description><![CDATA[New item description]]></description>
    </item>

    <item>
      <title>Item Title</title>
      <link>http://test.com/content/1</link>
      <guid>2</guid>
      <pubDate>Mon, 20 Feb 2012 16:04:19 +0900</pubDate>
      <description><![CDATA[Item description]]></description>
    </item>
  </channel>
</rss>
      EOS
      feed.load!
      feed.should have(2).items
      feed.items.order(:published_at)[0].tap do |item|
        item.title.should == 'Item Title'
        item.link.should == 'http://test.com/content/1'
        item.published_at.should == Time.new(2012, 2, 20, 16, 4, 19)
        item.description == 'Item description'
      end
      feed.items.order(:published_at)[1].tap do |item|
        item.title.should == 'New Title'
        item.link.should == 'http://test.com/content/2'
        item.published_at.should == Time.new(2012, 2, 22, 18, 24, 29)
        item.description == 'New item description'
      end
    end

    it 'guidが無い時はlinkで重複を判断する' do
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
      feed.should have(2).items
      feed.items.order(:published_at)[0].tap do |item|
        item.link.should == 'http://test.com/content/1'
        item.description == 'Item description UPDATED'
      end
      feed.items.order(:published_at)[1].tap do |item|
        item.link.should == 'http://test.com/content/2'
        item.description == 'New item description'
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
        feed.tags.should have(1).tag
        feed.tags[0].name.should == 'category'
        feed.description.should be_nil
      end
    end
  end
end
