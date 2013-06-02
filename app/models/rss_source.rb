require 'open-uri'
require 'rss'

class RssSource < ActiveRecord::Base
  belongs_to :user
  has_many :items, dependent: :destroy

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

  def load!
    self.class.load_rss(url) do |rss|
      rss.items.each do |loaded_item|
        i = items.find_or_initialize_by(link: loaded_item.link)
        i.link = loaded_item.link
        i.title = loaded_item.title
        i.published_at = loaded_item.date
        i.description = loaded_item.description
        i.save
      end
    end
  end

private
  def self.load_rss(url)
    open(url) do |rss_body|
      return yield RSS::Parser.parse(rss_body)
    end
  end
end
