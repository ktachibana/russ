require 'open-uri'
require 'rss'
require 'rexml/document'

class Feed < ActiveRecord::Base
  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings

  validates :user_id, presence: true
  validates :url, presence: true, length: { maximum: 2048 }
  validates :title, presence: true, length: { maximum: 255 }
  validates :link_url, presence: true, length: { maximum: 2048 }
  validates :description, length: { maximum: 4096 }

  def self.by_url(url)
    load_rss(url) do |rss|
      new do |m|
        m.url = url
        m.title = rss.channel.title
        m.description = rss.channel.description
        m.link_url = rss.channel.link
      end
    end
  end

  def self.load_all!
    find_each do |feed|
      sleep(5)
      feed.load!
    end
  end

  def load!
    self.class.load_rss(url) do |rss|
      rss.items.each do |loaded_item|
        guid = loaded_item.try(:guid).try(:content)

        item = guid && items.find_by(guid: guid)
        item ||= items.find_by(link: loaded_item.link)
        item ||= items.build
        item.link = loaded_item.link
        item.title = loaded_item.title
        item.guid = guid
        item.published_at = loaded_item.date
        item.description = loaded_item.description
        item.save
      end
    end
  rescue OpenURI::HTTPError => e
    Rails.logger.error(e)
    nil # TODO エラーハンドリング
  end

  def self.import!(user, opml)
    doc = REXML::Document.new(opml)

    result = []
    doc.elements.each('opml/body/outline') do |outline|
      attrs = outline.attributes
      title = attrs['text'] || attrs['title']
      url = attrs['xmlUrl']
      link_url = attrs['htmlUrl']

      if url && title
        result << user.feeds.create!(url: url, title: title, link_url: link_url)
      else title
        tag = user.tags.find_or_initialize_by(name: title)
        tag.save!

        outline.elements.each('outline') do |child|
          child_attrs = child.attributes
          title = child_attrs['text'] || child_attrs['title']
          url = child_attrs['xmlUrl']
          link_url = child_attrs['htmlUrl']
          feed = user.feeds.create!(url: url, title: title, link_url: link_url)
          feed.tags << tag
          result << feed
        end
      end
    end
    result
  end

  private
  def self.load_rss(url)
    open(url) do |rss_body|
      return yield RSS::Parser.parse(rss_body)
    end
  end
end
