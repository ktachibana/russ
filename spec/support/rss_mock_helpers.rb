module RssMockHelpers
  def mock_rss!(url = nil)
    url ||= mock_rss_url
    WebMock.stub_request(:get, url).to_return(body: rss_data)
    url
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

  def mock_rss_url
    'http://test.com/rss.xml'
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
