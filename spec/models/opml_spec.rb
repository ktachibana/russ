require 'spec_helper'

describe OPML, type: :model do
  let(:user) { create(:user) }

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
      result = OPML.import!(opml, user)
      expect(Feed.count).to eq(2)

      result[0].tap do |subscription|
        expect(subscription.feed.title).to eq('MyText')
        expect(subscription.feed.url).to eq('http://test.com/rss.xml')
        expect(subscription.feed.link_url).to eq('http://test.com/content')
        expect(subscription.feed.description).to be_nil
      end
      expect(result[1]).to be_a(Array)
      result[1][0].tap do |subscription|
        expect(subscription.feed.title).to eq('Title')
        expect(subscription.feed.url).to eq('http://category.com/rss.xml')
        expect(subscription.feed.link_url).to eq('http://category.com/')
        expect(subscription.feed.description).to be_nil
        expect(subscription.tags.size).to eq(1)
        expect(subscription.tag_list).to eq(%w(category))
      end
    end

    it 'OPML形式でないファイルを与えたらエラー' do
      expect { OPML.import!('Hello ! this is text.', user) }.to raise_error(OPML::InvalidFormat)
    end
  end
end
