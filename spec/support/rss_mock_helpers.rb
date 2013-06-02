module RssMockHelpers
  def mock_rss!
    WebMock.stub_request(:get, mock_rss_url).to_return(body: <<-EOS)
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
end
