module RssMockHelpers
  def mock_rss!(url = nil)
    url ||= mock_rss_url
    WebMock.stub_request(:get, url).to_return(body: rss_data)
    url
  end

  def mock_rss_url
    'http://test.com/rss.xml'
  end

  def rss_data
    <<-'EOS'
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>RSS Title</title>
    <link>http://test.com/rss.xml?rss=2.0</link>
    <atom:link rel="self" type="application/rss+xml" href="http://test.com/rss.xml?rss=2.0"/>
    <description>My description</description>
  </channel>
</rss>
    EOS
  end

  def rss_data_one_item
    <<-EOS
end
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

  def rss_data_two_items
    <<-EOS
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
  end

  def opml_data
    <<-'EOS'
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
  end

  def mock_opml_rss!
    WebMock.stub_request(:get, 'http://test.com/rss.xml').to_return(body: rss_data)
    WebMock.stub_request(:get, 'http://category.com/rss.xml').to_return(body: rss_data)
  end
end
