# frozen_string_literal: true

require 'rexml/document'
require 'nokogiri'

class OPML
  def self.import!(opml, user)
    new(opml, user).import!
  end

  private def initialize(opml, user)
    @doc = Nokogiri::XML(opml)
    @user = user
  end
  attr_reader :user

  def import!
    root = Outline.new(self, @doc.at_xpath('opml/body'))
    root.handle_outlines
  end

  class Outline
    def initialize(opml, node)
      raise(InvalidFormat) unless node

      @opml = opml
      @node = node

      @title = node['text'] || node['title']
      @url = node['xmlUrl']
      @link_url = node['htmlUrl']
    end
    attr_reader :title, :url, :link_url

    def feed?
      url && title
    end

    def create_subscription(tag_names: nil)
      feed = Feed.create!(url: url, title: title, link_url: link_url)
      @opml.user.subscriptions.create!(feed: feed, tag_list: Array.wrap(tag_names))
    end

    def nest?
      title
    end

    def each_child
      @node.xpath('outline').each do |outline|
        yield Outline.new(@opml, outline)
      end
    end

    def handle_outlines(tag_names: [])
      enum_for(:each_child).map do |child_outline|
        if child_outline.feed?
          child_outline.create_subscription(tag_names: tag_names)
        elsif child_outline.nest?
          child_outline.handle_outlines(tag_names: tag_names + [child_outline.title])
        end
      end
    end
  end

  class InvalidFormat < StandardError; end
end
