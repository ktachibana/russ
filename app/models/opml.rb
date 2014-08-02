class OPML
  def self.import!(opml, user)
    new(opml, user).import!
  end

  private def initialize(opml, user)
    @doc = REXML::Document.new(opml)
    @user = user
  end
  attr_reader :user

  def import!
    root = Outline.new(self, @doc.elements['opml/body'])
    root.handle_outlines
  end

  class Outline
    def initialize(opml, rexml_doc)
      @opml = opml
      @rexml_doc = rexml_doc

      attrs = rexml_doc.attributes
      @title = attrs['text'] || attrs['title']
      @url = attrs['xmlUrl']
      @link_url = attrs['htmlUrl']
    end
    attr_reader :title, :url, :link_url

    def feed?
      !!(url && title)
    end

    def create_subscription(tag_names: nil)
      feed = Feed.create!(url: url, title: title, link_url: link_url)
      @opml.user.subscriptions.create!(feed: feed, tag_list: Array.wrap(tag_names))
    end

    def nest?
      !!title
    end

    def each_child
      @rexml_doc.elements.each('outline') do |child|
        yield Outline.new(@opml, child)
      end
    end

    def handle_outlines(tag_names: [])
      enum_for(:each_child).map do |child|
        if child.feed?
          child.create_subscription(tag_names: tag_names)
        elsif child.nest?
          child.handle_outlines(tag_names: tag_names + [child.title])
        end
      end
    end
  end
end
