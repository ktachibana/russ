module RssMockHelpers
  def mock_url!(url: mock_rss_url, body: rss_data, content_type: nil)
    WebMock.stub_request(:get, url).to_return(body: body, headers: { content_type: content_type })
    url
  end

  def mock_rss!(url: mock_rss_url, body: rss_data, content_type: 'application/xml')
    mock_url!(url: url, body: body, content_type: content_type)
  end

  def mock_rss_url
    'http://test.com/rss.xml'
  end

  RSS_DATA = <<~'XML'
    <?xml version="1.0" encoding="utf-8"?>
    <rss version="2.0">
      <channel>
        <title>RSS Title</title>
        <link>http://test.com/rss.xml?rss=2.0</link>
        <description>My description</description>
      </channel>
    </rss>
  XML

  def rss_data
    RSS_DATA
  end

  RSS_DATA_ONE_ITEM = <<~XML
    <?xml version="1.0" encoding="utf-8"?>
    <rss version="2.0">
      <channel>
        <title>RSS Title</title>
        <link>http://test.com/content</link>
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
  XML

  def rss_data_one_item
    RSS_DATA_ONE_ITEM
  end

  RSS_DATA_TWO_ITEMS = <<~XML
    <?xml version="1.0" encoding="utf-8"?>
    <rss version="2.0">
      <channel>
        <title>New Title</title>
        <link>http://test.com/new-content</link>
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
  XML

  def rss_data_two_items
    RSS_DATA_TWO_ITEMS
  end

  def rss_data_relative_link
    <<~XML
      <?xml version="1.0" encoding="utf-8"?>
      <rss version="2.0">
        <channel>
          <title>RSS Title</title>
          <link>/site/mypage</link>
          <description>My description</description>

          <item>
            <title>New Title</title>
            <link>/content/1</link>
            <guid>1</guid>
            <pubDate>Wed, 22 Feb 2012 18:24:29 +0900</pubDate>
            <description><![CDATA[New item description]]></description>
          </item>
        </channel>
      </rss>
    XML
  end

  def rss_data_atom
    <<~XML
      <?xml version="1.0" encoding="utf-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <title type="text" xml:lang="en">Riding Rails</title>
        <subtitle type="text">Sub Title</subtitle>
        <link type="application/atom+xml" href="http://weblog.rubyonrails.org/feed/" rel="self"/>
        <link type="text" href="http://weblog.rubyonrails.org/" rel="alternate"/>
        <updated>2014-11-05T16:12:31+00:00</updated>
        <id>http://weblog.rubyonrails.org/</id>

        <entry>
          <title>Rails 3.2.20, 4.0.11, 4.1.7, and 4.2.0.beta3 have been released</title>
          <author>
            <name>tenderlove</name>
          </author>
          <link href="http://weblog.rubyonrails.org/2014/10/30/Rails_3_2_20_4_0_11_4_1_7_and_4_2_0_beta3_have_been_released/"/>
          <updated>2014-10-30T18:16:55+00:00</updated>
          <id>http://weblog.rubyonrails.org/2014/10/30/Rails_3_2_20_4_0_11_4_1_7_and_4_2_0_beta3_have_been_released/</id>
          <content type="html">Content 1</content>
        </entry>
      </feed>
    XML
  end

  def rss_data_atom_two_items
    <<~XML
      <?xml version="1.0" encoding="utf-8"?>
      <feed xmlns="http://www.w3.org/2005/Atom">
        <title type="text" xml:lang="en">New Title</title>
        <link type="application/atom+xml" href="http://weblog.rubyonrails.org/feed/" rel="self"/>
        <link type="text" href="http://weblog.rubyonrails.org/new" rel="alternate"/>
        <updated>2014-11-05T16:12:31+00:00</updated>
        <id>http://weblog.rubyonrails.org/</id>

        <entry>
          <title>[ANN] Rails 4.2.0.beta4 has been released!</title>
          <author>
            <name>chancancode</name>
          </author>
          <link href="http://weblog.rubyonrails.org/2014/10/30/Rails-4-2-0-beta4-has-been-released/"/>
          <updated>2014-10-30T22:00:00+00:00</updated>
          <id>http://weblog.rubyonrails.org/2014/10/30/Rails-4-2-0-beta4-has-been-released/</id>
          <content type="html">Content 2</content>
        </entry>

        <entry>
          <title>Rails 3.2.20, 4.0.11, 4.1.7, and 4.2.0.beta3 have been released</title>
          <author>
            <name>tenderlove</name>
          </author>
          <link href="http://weblog.rubyonrails.org/2014/10/30/Rails_3_2_20_4_0_11_4_1_7_and_4_2_0_beta3_have_been_released/"/>
          <updated>2014-10-30T18:16:55+00:00</updated>
          <id>http://weblog.rubyonrails.org/2014/10/30/Rails_3_2_20_4_0_11_4_1_7_and_4_2_0_beta3_have_been_released/</id>
          <content type="html">Content 1</content>
        </entry>
      </feed>
    XML
  end

  OPML_DATA = <<~'XML'
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
  XML

  def opml_data
    OPML_DATA
  end

  def mock_opml_rss!
    WebMock.stub_request(:get, 'http://test.com/rss.xml').to_return(body: rss_data)
    WebMock.stub_request(:get, 'http://category.com/rss.xml').to_return(body: rss_data)
  end
end
