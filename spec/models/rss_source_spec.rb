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
end
